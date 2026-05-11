import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/app_flow/nav/serialization_util.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tuple/tuple.dart';

import 'onboarding_create_account_model.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
  static const double loaderSize   = 25.0;
  static const double prefixIconSize = 18.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class OnboardingCreateAccountWidget extends StatefulWidget {
  const OnboardingCreateAccountWidget({super.key});

  @override
  State<OnboardingCreateAccountWidget> createState() =>
      _OnboardingCreateAccountWidgetState();
}

class _OnboardingCreateAccountWidgetState
    extends State<OnboardingCreateAccountWidget> {
  final _formKey = GlobalKey<FormState>();

  // FIX: model resolved once in initState — not inside descendant build().
  late final OnboardingCreateAccountModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<OnboardingCreateAccountModel>();
  }

  // FIX: button logic extracted from inline onPressed lambda into a named
  //   method — consistent with _handleSave / _handleReset across all form pages.
  Future<void> _handleCreateAccount() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('ONBOARDING_CREATE_ACCOUNT_CREATE_ACCOUNT');
    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();
    logFirebaseEvent('Button_auth');
    GoRouter.of(context).prepareAuthEvent();

    _model.clearAllServerErrors();

    final Tuple3<bool, String, String> result =
        await pocketAuthManager.createAccountWithEmail(
      mail: _model.emailAddressTextController.text,
      password: _model.passwordTextController.text,
      name: _model.nameTextController.text,
      surname: _model.surnameTextController.text,
      username: _model.usernameTextController.text,
    );

    if (!result.item1) {
      if (result.item2.isNotEmpty && result.item3.isNotEmpty) {
        _model.addServerError(result.item2, result.item3);
        _formKey.currentState!.validate();
      }
      return;
    }

    logFirebaseEvent('Button_navigate_to');
    if (mounted) {
      context.goNamedAuth(
        'Onboarding_VerifyMail',
        context.mounted,
        queryParameters: {
          'email': serializeParam(
            _model.emailAddressTextController.text,
            ParamType.String,
          ),
        }.withoutNulls,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // FIX: Align(0,0) inside SingleChildScrollView removed.
          //   SingleChildScrollView aligns to the top by default — the Align
          //   was adding a redundant layout node with no visual effect.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Text(
                    'Registrati',
                    style: CustomFlowTheme.of(context).displaySmall,
                  ),
                ),
                _FormSection(model: _model),
                _CreateAccountButton(
                  model: _model,
                  formKey: _formKey,
                  onCreateAccount: _handleCreateAccount,
                ),
                _TermsSection(model: _model),
              ],
            ),
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
    return const CustomAppbarWidget(backButton: true);
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION
//
// FIX: model received as constructor parameter — no context.read in build().
// ---------------------------------------------------------------------------
class _FormSection extends StatelessWidget {
  const _FormSection({required this.model});

  final OnboardingCreateAccountModel model;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: GlobalKey<FormState>(), // form key managed in State, passed via parent
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          _TextField(
            label: 'Nome',
            controller: model.nameTextController,
            focusNode: model.nameFocusNode,
            autofillHints: const [AutofillHints.name],
            textCapitalization: TextCapitalization.words,
            prefixIcon: Icons.person,
            validator: model.nameTextControllerValidator.asValidator(context)!,
            onChanged: (_) => model.clearServerError('name'),
          ),
          _TextField(
            label: 'Cognome',
            controller: model.surnameTextController,
            focusNode: model.surnameFocusNode,
            autofillHints: const [AutofillHints.familyName],
            textCapitalization: TextCapitalization.words,
            prefixIcon: Icons.person,
            validator: model.surnameTextControllerValidator.asValidator(context)!,
            onChanged: (_) => model.clearServerError('surname'),
          ),
          _TextField(
            label: 'Username',
            controller: model.usernameTextController,
            focusNode: model.usernameFocusNode,
            autofillHints: const [AutofillHints.username],
            prefixIcon: Icons.person,
            validator: model.usernameTextControllerValidator.asValidator(context)!,
            onChanged: (_) => model.clearServerError('username'),
          ),
          _TextField(
            label: 'Email',
            controller: model.emailAddressTextController,
            focusNode: model.emailAddressFocusNode,
            autofillHints: const [AutofillHints.email],
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: model.emailAddressTextControllerValidator.asValidator(context)!,
            onChanged: (_) => model.clearServerError('email'),
          ),
          // FIX: Consumer replaced with Selector — rebuilds only when
          //   passwordVisibility changes, not on every model notification.
          Selector<OnboardingCreateAccountModel, bool>(
            selector: (_, m) => m.passwordVisibility,
            builder: (_, __, ___) => _PasswordField(model: model),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TEXT FIELD
// ---------------------------------------------------------------------------
class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.prefixIcon,
    required this.validator,
    this.autofillHints = const [],
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData prefixIcon;
  final FormFieldValidator<String> validator;
  final List<String> autofillHints;
  final TextCapitalization textCapitalization;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
            child: Text(label, style: CustomFlowTheme.of(context).bodyMedium),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
            textInputAction: TextInputAction.next,
            obscureText: false,
            decoration: standardInputDecoration(
              context,
              prefixIcon: Icon(
                prefixIcon,
                color: CustomFlowTheme.of(context).secondaryText,
                size: _Dims.prefixIconSize,
              ),
            ),
            style: CustomFlowTheme.of(context)
                .bodyLarge
                .override(fontWeight: FontWeight.w500, lineHeight: 1),
            minLines: 1,
            keyboardType: keyboardType,
            cursorColor: CustomFlowTheme.of(context).primary,
            validator: validator,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PASSWORD FIELD
// ---------------------------------------------------------------------------
class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.model});

  final OnboardingCreateAccountModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
            child: Text('Password',
                style: CustomFlowTheme.of(context).bodyMedium),
          ),
          TextFormField(
            controller: model.passwordTextController,
            focusNode: model.passwordFocusNode,
            autofocus: false,
            autofillHints: const [AutofillHints.newPassword],
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
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
                    color: CustomFlowTheme.of(context).secondaryText,
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
            onChanged: (_) => model.clearServerError('password'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CREATE ACCOUNT BUTTON
//
// FIX: model and formKey received as parameters; onCreateAccount replaces
//   the inline async lambda.
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({
    required this.model,
    required this.formKey,
    required this.onCreateAccount,
  });

  final OnboardingCreateAccountModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: onCreateAccount,
        text: 'Crea Account',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          color: CustomFlowTheme.of(context).primary,
          textStyle: CustomFlowTheme.of(context).titleSmall,
          elevation: 0,
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(_Dims.buttonRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TERMS SECTION
//
// FIX: model received as constructor parameter — no context.read in build().
// ---------------------------------------------------------------------------
class _TermsSection extends StatelessWidget {
  const _TermsSection({required this.model});

  final OnboardingCreateAccountModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: FutureBuilder<CompanyInformationRecord?>(
              future: model.companyInfoFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: _Dims.loaderSize,
                      height: _Dims.loaderSize,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          CustomFlowTheme.of(context).primary,
                        ),
                      ),
                    ),
                  );
                }
                if (snapshot.data == null) return const SizedBox.shrink();
                final record = snapshot.data!;
                return InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    logFirebaseEvent(
                        'ONBOARDING_CREATE_ACCOUNT_RichText_t8sm7');
                    logFirebaseEvent('RichText_launch_u_r_l');
                    await launchURL(record.termsURL);
                  },
                  child: RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Cliccando "Crea Account," accetti i ',
                          style: CustomFlowTheme.of(context).bodyMedium,
                        ),
                        TextSpan(
                          text: 'Termini contrattuali',
                          style: CustomFlowTheme.of(context)
                              .bodyMedium
                              .override(decoration: TextDecoration.underline),
                        ),
                        const TextSpan(
                          text: ' di TournamentManager.',
                          style: TextStyle(),
                        ),
                      ],
                      style: CustomFlowTheme.of(context).bodyMedium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
