import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/onboarding/sign_in/sign_in_model.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double buttonHeight   = 50.0;
  static const double buttonRadius   = 25.0;
  static const double sectionRadius  = 8.0;
  static const double prefixIconSize = 18.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignInWidget> {
  final _formKey = GlobalKey<FormState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  // FIX: model resolved once in initState — not inside descendant build().
  late final SignInModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<SignInModel>();
    if (!isWeb) {
      _keyboardVisibilitySubscription =
          KeyboardVisibilityController().onChange.listen((bool visible) {
        setState(() => _isKeyboardVisible = visible);
      });
    }
  }

  @override
  void dispose() {
    if (!isWeb) _keyboardVisibilitySubscription.cancel();
    super.dispose();
  }

  // FIX: sign-in button logic extracted to a named method — consistent with
  //   _handleSave / _handleReset / _handleCreateAccount across all form pages.
  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('SIGN_IN_PAGE_SIGN_IN_BTN_ON_TAP');
    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();
    logFirebaseEvent('Button_auth');
    GoRouter.of(context).prepareAuthEvent();

    final signed = await _model.executeSignIn();
    if (signed && mounted) {
      context.goNamedAuth('Dashboard', context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisible = isWeb
        ? MediaQuery.viewInsetsOf(context).bottom > 0
        : _isKeyboardVisible;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Header(),
                      _FormSection(
                        model: _model,
                        formKey: _formKey,
                        onSignIn: _handleSignIn,
                      ),
                    ],
                  ),
                ),
              ),
              if (!keyboardVisible) const _CreateAccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppbarWidget(backButton: true),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Text(
            'Accedi',
            style: CustomFlowTheme.of(context).displaySmall,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION
//
// FIX: model received as constructor parameter — no context.read in build().
// FIX: Consumer for the password field replaced with Selector<SignInModel,bool>
//   on passwordVisibility — rebuilds only when the eye-icon flag changes,
//   not on every model notification (e.g. errorMessage updates).
// FIX: sign-in button receives onSignIn callback — inline lambda removed.
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.model,
    required this.formKey,
    required this.onSignIn,
  });

  final SignInModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // ── Email field ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                      child: Text('Email',
                          style: CustomFlowTheme.of(context).bodyMedium),
                    ),
                    TextFormField(
                      controller: model.emailAddressTextController,
                      focusNode: model.emailAddressFocusNode,
                      autofocus: false,
                      autofillHints: const [AutofillHints.email],
                      textCapitalization: TextCapitalization.none,
                      textInputAction: TextInputAction.next,
                      obscureText: false,
                      decoration: standardInputDecoration(
                        context,
                        prefixIcon: Icon(
                          Icons.email,
                          color: CustomFlowTheme.of(context).secondaryText,
                          size: _Dims.prefixIconSize,
                        ),
                      ),
                      style: CustomFlowTheme.of(context)
                          .bodyLarge
                          .override(fontWeight: FontWeight.w500, lineHeight: 1),
                      minLines: 1,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: CustomFlowTheme.of(context).primary,
                      validator: model.emailAddressTextControllerValidator
                          .asValidator(context),
                    ),
                  ],
                ),
              ),

              // ── Password field — Selector on passwordVisibility only ──
              Selector<SignInModel, bool>(
                selector: (_, m) => m.passwordVisibility,
                builder: (_, __, ___) => Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                        child: Text(
                          'Password',
                          style: CustomFlowTheme.of(context).bodyMedium,
                        ),
                      ),
                      TextFormField(
                        controller: model.passwordTextController,
                        focusNode: model.passwordFocusNode,
                        autofocus: false,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.none,
                        obscureText: !model.passwordVisibility,
                        decoration: standardInputDecoration(
                          context,
                          prefixIcon: Icon(
                            Icons.lock,
                            color: CustomFlowTheme.of(context).secondaryText,
                            size: _Dims.prefixIconSize,
                          ),
                          suffixIcons: [
                            InkWell(
                              onTap: () => model.togglePasswordVisibility(),
                              focusNode: FocusNode(skipTraversal: true),
                              child: Icon(
                                model.passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    CustomFlowTheme.of(context).secondaryText,
                                size: _Dims.prefixIconSize,
                              ),
                            ),
                          ],
                        ),
                        style: CustomFlowTheme.of(context)
                            .bodyLarge
                            .override(fontWeight: FontWeight.w500, lineHeight: 1),
                        cursorColor: CustomFlowTheme.of(context).primary,
                        validator: model.passwordTextControllerValidator
                            .asValidator(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Error message — Selector on errorMessage only ────────────────
        Selector<SignInModel, String>(
          selector: (_, m) => m.errorMessage,
          builder: (_, errorMsg, __) {
            if (errorMsg.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
              child: Text(
                errorMsg,
                style: CustomFlowTheme.of(context).bodyLarge.override(
                      fontWeight: FontWeight.w500,
                      color: CustomFlowTheme.of(context).error,
                      lineHeight: 1,
                    ),
              ),
            );
          },
        ),

        // ── Sign-in button ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: AFButtonWidget(
            onPressed: onSignIn,
            text: 'Accedi',
            options: AFButtonOptions(
              width: double.infinity,
              height: _Dims.buttonHeight,
              // FIX: fromSTEB(0,0,0,0) → zero.
              padding: EdgeInsetsDirectional.zero,
              iconPadding: EdgeInsetsDirectional.zero,
              color: CustomFlowTheme.of(context).primary,
              textStyle: CustomFlowTheme.of(context).titleSmall,
              elevation: 0,
              borderSide: const BorderSide(color: Colors.transparent, width: 1),
              borderRadius: BorderRadius.circular(_Dims.buttonRadius),
            ),
          ),
        ),

        // ── Forgot password link ──────────────────────────────────────────
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              logFirebaseEvent('SIGN_IN_PAGE_Row_4ukbm94e_ON_TAP');
              logFirebaseEvent('Row_navigate_to');
              context.pushNamed('ForgotPassword');
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                  child: Text(
                    'Non ricordo la mia password',
                    style: CustomFlowTheme.of(context).bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CREATE ACCOUNT SECTION
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
class _CreateAccountSection extends StatelessWidget {
  const _CreateAccountSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 48),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(_Dims.sectionRadius),
          border: Border.all(
            color: CustomFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                child: Text(
                  'Non hai un account?',
                  style: CustomFlowTheme.of(context).labelLarge,
                ),
              ),
              AFButtonWidget(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  logFirebaseEvent('SIGN_IN_PAGE_CREATE_ACCOUNT_BTN_ON_TAP');
                  logFirebaseEvent('Button_navigate_to');
                  context.pushNamed('Onboarding_CreateAccount');
                },
                text: 'Crea Account',
                options: AFButtonOptions(
                  width: double.infinity,
                  height: _Dims.buttonHeight,
                  padding: EdgeInsetsDirectional.zero,
                  iconPadding: EdgeInsetsDirectional.zero,
                  color: CustomFlowTheme.of(context).secondary,
                  textStyle: CustomFlowTheme.of(context).bodyMedium,
                  elevation: 0,
                  borderSide: BorderSide(
                    color: CustomFlowTheme.of(context).primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(_Dims.buttonRadius),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
