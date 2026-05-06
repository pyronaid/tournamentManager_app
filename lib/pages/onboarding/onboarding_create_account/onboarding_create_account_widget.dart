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

abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
  static const double loaderSize = 25.0;
}

class OnboardingCreateAccountWidget extends StatefulWidget {
  const OnboardingCreateAccountWidget({super.key});

  @override
  State<OnboardingCreateAccountWidget> createState() =>
      _OnboardingCreateAccountWidgetState();
}

class _OnboardingCreateAccountWidgetState
    extends State<OnboardingCreateAccountWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Align(
              alignment: const AlignmentDirectional(0, 0),
              child: Padding(
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
                    _FormSection(formKey: _formKey),
                    _CreateAccountButton(formKey: _formKey),
                    const _TermsSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const CustomAppbarWidget(backButton: true);
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final model = context.read<OnboardingCreateAccountModel>();
    return Form(
      key: formKey,
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
          Consumer<OnboardingCreateAccountModel>(
            builder: (context, m, _) => _PasswordField(model: m),
          ),
        ],
      ),
    );
  }
}

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
                size: 18,
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
                size: 18,
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
                    size: 18,
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

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          logFirebaseEvent('ONBOARDING_CREATE_ACCOUNT_CREATE_ACCOUNT');
          logFirebaseEvent('Button_validate_form');
          if (formKey.currentState == null ||
              !formKey.currentState!.validate()) return;
          logFirebaseEvent('Button_haptic_feedback');
          HapticFeedback.lightImpact();
          logFirebaseEvent('Button_auth');
          GoRouter.of(context).prepareAuthEvent();

          final m = context.read<OnboardingCreateAccountModel>();
          m.clearAllServerErrors();
          Tuple3<bool, String, String> result =
              await pocketAuthManager.createAccountWithEmail(
            mail: m.emailAddressTextController.text,
            password: m.passwordTextController.text,
            name: m.nameTextController.text,
            surname: m.surnameTextController.text,
            username: m.usernameTextController.text,
          );
          if (!result.item1) {
            if (result.item2.isNotEmpty && result.item3.isNotEmpty) {
              m.addServerError(result.item2, result.item3);
              formKey.currentState!.validate();
            }
            return;
          }

          logFirebaseEvent('Button_navigate_to');
          if (context.mounted) {
            context.goNamedAuth(
              'Onboarding_VerifyMail',
              context.mounted,
              queryParameters: {
                'email': serializeParam(
                  m.emailAddressTextController.text,
                  ParamType.String,
                ),
              }.withoutNulls,
            );
          }
        },
        text: 'Crea Account',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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

class _TermsSection extends StatelessWidget {
  const _TermsSection();

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
              future: context
                  .read<OnboardingCreateAccountModel>()
                  .companyInfoFuture,
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
