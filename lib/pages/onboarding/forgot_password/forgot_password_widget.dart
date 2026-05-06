import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/onboarding/forgot_password/forgot_password_model.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
}

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    context.read<ForgotPasswordModel>().initContextVars(context);
  }

  @override
  Widget build(BuildContext context) {
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
                child: Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(onUpdate: () => setState(() {})),
                        _FormSection(formKey: _formKey),
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

class _Header extends StatelessWidget {
  const _Header({required this.onUpdate});
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wrapWithModel(
          model: context.read<ForgotPasswordModel>().customAppbarModel,
          updateCallback: onUpdate,
          child: CustomAppbarWidget(
            backButton: true,
            actionButton: false,
            actionButtonAction: () async {},
            optionsButtonAction: () async {},
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Text(
            'Password dimenticata',
            style: CustomFlowTheme.of(context).displaySmall,
          ),
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    final model = context.read<ForgotPasswordModel>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ti manderemo una mail per il reset della password.',
                  textAlign: TextAlign.start,
                  style: CustomFlowTheme.of(context).labelLarge,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                  child: Text(
                    'Email',
                    textAlign: TextAlign.start,
                    style: CustomFlowTheme.of(context).bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                  child: TextFormField(
                    controller: model.emailAddressTextController,
                    focusNode: model.emailAddressFocusNode,
                    autofocus: false,
                    autofillHints: const [AutofillHints.name],
                    textCapitalization: TextCapitalization.none,
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
                    style: CustomFlowTheme.of(context).titleSmall.override(
                          fontWeight: FontWeight.w500,
                          lineHeight: 1,
                        ),
                    minLines: 1,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: CustomFlowTheme.of(context).primary,
                    validator: model.emailAddressTextControllerValidator
                        .asValidator(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: AFButtonWidget(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('FORGOT_PASSWORD_RESET_PASSWORD_BTN_ON_TA');
              logFirebaseEvent('Button_validate_form');
              if (formKey.currentState == null ||
                  !formKey.currentState!.validate()) return;
              logFirebaseEvent('Button_haptic_feedback');
              HapticFeedback.lightImpact();
              logFirebaseEvent('Button_auth');
              final m = context.read<ForgotPasswordModel>();
              if (m.emailAddressTextController.text.isEmpty) {
                m.showResetPasswordIssueSnackBar();
              } else {
                await pocketAuthManager
                    .resetPassword(m.emailAddressTextController.text);
                logFirebaseEvent('Button_navigate_back');
                if (context.mounted) context.safePop();
              }
            },
            text: 'Reset Password',
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
        ),
      ],
    );
  }
}
