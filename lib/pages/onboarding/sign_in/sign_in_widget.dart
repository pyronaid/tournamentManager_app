import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tournamentmanager/pages/onboarding/sign_in/sign_in_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({super.key});

  @override
  State<SignInWidget> createState() => _SignInWidgetState();
}


class _SignInWidgetState extends State<SignInWidget> {
  late SignInModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  late StreamSubscription<bool> _keyboardVisibilitySubscription;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SignInModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'SignIn'});
    if (!isWeb) {
      _keyboardVisibilitySubscription = KeyboardVisibilityController().onChange.listen((bool visible) {
        setState(() {
          _isKeyboardVisible = visible;
        });
      });
    }

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    /* TODO
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
      _model.emailAddressTextController?.text = 'tsmith@email.com';
      _model.passwordTextController?.text = 'password';
    }));
    */
  }

  @override
  void dispose() {
    _model.dispose();

    if (!isWeb) {
      _keyboardVisibilitySubscription.cancel();
    }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
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
                      wrapWithModel(
                        model: _model.customAppbarModel,
                        updateCallback: () => setState(() {}),
                        child: CustomAppbarWidget(
                          backButton: true,
                          actionButton: false,
                          optionsButton: false,
                          actionButtonAction: () async {},
                          optionsButtonAction: () async {},
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                        child: Text(
                          'Accedi',
                          style: CustomFlowTheme.of(context).displaySmall,
                        ),
                      ),
                      Form(
                        key: _model.formKey,
                        autovalidateMode: AutovalidateMode.disabled,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                    child: Text(
                                      'Email',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _model.emailAddressTextController,
                                    focusNode: _model.emailAddressFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.email],
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: standardInputDecoration(
                                      context,
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: CustomFlowTheme.of(context).secondaryText,
                                        size: 18,
                                      ),
                                    ),
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                    ),
                                    minLines: 1,
                                    keyboardType: TextInputType.emailAddress,
                                    cursorColor: CustomFlowTheme.of(context).primary,
                                    validator: _model
                                        .emailAddressTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                    child: Text(
                                      'Password',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _model.passwordTextController,
                                    focusNode: _model.passwordFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.password],
                                    textInputAction: TextInputAction.done,
                                    obscureText: !_model.passwordVisibility,
                                    decoration: standardInputDecoration(
                                      context,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: CustomFlowTheme.of(context).secondaryText,
                                        size: 18,
                                      ),
                                      suffixIcon: InkWell(
                                        onTap: () => setState(
                                          () => _model.passwordVisibility =
                                              !_model.passwordVisibility,
                                        ),
                                        focusNode: FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: CustomFlowTheme.of(context).secondaryText,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                    ),
                                    cursorColor: CustomFlowTheme.of(context).primary,
                                    validator: _model
                                      .passwordTextControllerValidator
                                      .asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                        child: AFButtonWidget(
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            logFirebaseEvent('SIGN_IN_PAGE_SIGN_IN_BTN_ON_TAP');
                            logFirebaseEvent('Button_validate_form');
                            if (_model.formKey.currentState == null ||
                                !_model.formKey.currentState!.validate()) {
                              return;
                            }
                            logFirebaseEvent('Button_haptic_feedback');
                            HapticFeedback.lightImpact();
                            logFirebaseEvent('Button_auth');
                            GoRouter.of(context).prepareAuthEvent();

                            final user = await authManager.signInWithEmail(
                              context,
                              _model.emailAddressTextController.text,
                              _model.passwordTextController.text,
                            );
                            if (user == null) {
                              return;
                            }

                            context.goNamedAuth('Dashboard', context.mounted);
                          },
                          text: 'Accedi',
                          options: AFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: CustomFlowTheme.of(context).primary,
                            textStyle: CustomFlowTheme.of(context).titleSmall,
                            elevation: 0,
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
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
                                  style: CustomFlowTheme.of(context).bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!(isWeb ? MediaQuery.viewInsetsOf(context).bottom > 0 : _isKeyboardVisible))
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 48),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: CustomFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(8),
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
                            onPressed: () async {
                              FocusScope.of(context).unfocus();
                              logFirebaseEvent('SIGN_IN_PAGE_CREATE_ACCOUNT_BTN_ON_TAP');
                              logFirebaseEvent('Button_navigate_to');

                              context.pushNamed('Onboarding_CreateAccount');
                            },
                            text: 'Crea Account',
                            options: AFButtonOptions(
                              width: double.infinity,
                              height: 50,
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: CustomFlowTheme.of(context).secondary,
                              textStyle: CustomFlowTheme.of(context).bodyMedium,
                              elevation: 0,
                              borderSide: BorderSide(
                                color: CustomFlowTheme.of(context).primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
