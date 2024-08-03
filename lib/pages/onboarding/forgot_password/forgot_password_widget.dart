
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../forgot_password/forgot_password_model.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  late ForgotPasswordModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ForgotPasswordModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'ForgotPassword'});
    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
      _model.unfocusNode.canRequestFocus
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
                child: Align(
                  alignment: const AlignmentDirectional(0, 0),
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
                        Form(
                          key: _model.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Padding(
                                padding:const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
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
                                        controller: _model.emailAddressTextController,
                                        focusNode: _model.emailAddressFocusNode,
                                        autofocus: false,
                                        autofillHints: const [AutofillHints.name],
                                        textCapitalization: TextCapitalization.none,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: standardInputDecoration(context),
                                        style: CustomFlowTheme.of(context).titleSmall.override(
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
                              logFirebaseEvent('FORGOT_PASSWORD_RESET_PASSWORD_BTN_ON_TA');
                              logFirebaseEvent('Button_validate_form');
                              if (_model.formKey.currentState == null ||
                                  !_model.formKey.currentState!.validate()) {
                                return;
                              }
                              logFirebaseEvent('Button_haptic_feedback');
                              HapticFeedback.lightImpact();
                              logFirebaseEvent('Button_auth');
                              if (_model.emailAddressTextController!.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Email necessaria!',
                                    ),
                                  ),
                                );
                                return;
                              }
                              await authManager.resetPassword(
                                email: _model.emailAddressTextController!.text,
                                context: context,
                              );
                              logFirebaseEvent('Button_navigate_back');
                              context.pop();
                            },
                            text: 'Reset Password',
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
