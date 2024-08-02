import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/backend.dart';
import '../../../components/custom_appbar_widget.dart';
import 'onboarding_create_account_model.dart';

class OnboardingCreateAccountWidget extends StatefulWidget {
  const OnboardingCreateAccountWidget({super.key});

  @override
  State<OnboardingCreateAccountWidget> createState() =>
      _OnboardingCreateAccountWidgetState();
}

class _OnboardingCreateAccountWidgetState extends State<OnboardingCreateAccountWidget> {
  late OnboardingCreateAccountModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingCreateAccountModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_CreateAccount'});
    _model.fullNameTextController ??= TextEditingController();
    _model.fullNameFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

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
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ////////////////
                  //CUSTOM BAR
                  /////////////////
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
                  ////////////////
                  //PAGE TITLE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'Registrati',
                      style: CustomFlowTheme.of(context).displaySmall,
                    ),
                  ),
                  ////////////////
                  //FORM
                  /////////////////
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
                                  'Nome completo',
                                  style: CustomFlowTheme.of(context).bodyMedium,
                                ),
                              ),
                              TextFormField(
                                controller: _model.fullNameTextController,
                                focusNode: _model.fullNameFocusNode,
                                autofocus: false,
                                autofillHints: const [AutofillHints.name],
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: standardInputDecoration(context),
                                style: CustomFlowTheme.of(context).bodyLarge.override(
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1,
                                ),
                                minLines: 1,
                                cursorColor: CustomFlowTheme.of(context).primary,
                                validator: _model
                                    .fullNameTextControllerValidator
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
                                decoration: standardInputDecoration(context),
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
                                autofillHints: const [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                obscureText: !_model.passwordVisibility,
                                decoration: standardInputDecoration(
                                  context,
                                  suffixIcon: InkWell(
                                    onTap: () => setState(
                                      () => _model.passwordVisibility =
                                          !_model.passwordVisibility,
                                    ),
                                    focusNode: FocusNode(skipTraversal: true),
                                    child: Icon(
                                      _model.passwordVisibility
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: CustomFlowTheme.of(context)
                                          .secondaryText,
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
                  ////////////////
                  //VALIDATION BUTTON
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: AFButtonWidget(
                      onPressed: () async {
                        logFirebaseEvent('ONBOARDING_CREATE_ACCOUNT_CREATE_ACCOUNT');
                        logFirebaseEvent('Button_validate_form');
                        if (_model.formKey.currentState == null ||
                            !_model.formKey.currentState!.validate()) {
                          return;
                        }
                        logFirebaseEvent('Button_haptic_feedback');
                        HapticFeedback.lightImpact();
                        logFirebaseEvent('Button_auth');
                        GoRouter.of(context).prepareAuthEvent();

                        //REGISTRATION
                        final user = await authManager.createAccountWithEmail(
                          context,
                          _model.emailAddressTextController.text,
                          _model.passwordTextController.text,
                        );
                        if (user == null) {
                          return;
                        }
                        //REGISTRATION
                        await UsersRecord.collection.doc(user.uid).update({
                          ...createUsersRecordData(
                            displayName: _model.fullNameTextController.text,
                            createdTime: DateTime.now(),
                          ),
                          /*
                          ...mapToFirestore(
                            {
                            },
                          ),*/
                        });

                        logFirebaseEvent('Button_navigate_to');
                        context.goNamedAuth('VerifyMail', context.mounted);
                      },
                      text: 'Crea Account',
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
                  ////////////////
                  //STRING INTERACTIVE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: StreamBuilder<List<CompanyInformationRecord>>(
                            stream: queryCompanyInformationRecord(
                              singleRecord: true,
                            ),
                            builder: (context, snapshot) {
                            // Customize what your widget looks like when it's loading.
                              if (!snapshot.hasData) {
                                return Center(
                                  child: SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(CustomFlowTheme.of(context).primary,),
                                    ),
                                  ),
                                );
                              }
                              List<CompanyInformationRecord> richTextCompanyInformationRecordList = snapshot.data!;

                              // Return an empty Container when the item does not exist.
                              if (snapshot.data!.isEmpty) {
                                return Container();
                              }
                              final richTextCompanyInformationRecord = richTextCompanyInformationRecordList.isNotEmpty
                                      ? richTextCompanyInformationRecordList
                                          .first
                                      : null;
                              return InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  logFirebaseEvent('ONBOARDING_CREATE_ACCOUNT_RichText_t8sm7');
                                  logFirebaseEvent('RichText_launch_u_r_l');
                                  await launchURL(richTextCompanyInformationRecord!.termsURL);
                                },
                                child: RichText(
                                  textScaler: MediaQuery.of(context).textScaler,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Cliccando "Crea Account," accetti i ',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      TextSpan(
                                        text: 'Termini contrattuali',
                                        style: CustomFlowTheme.of(context).bodySmall.override(decoration: TextDecoration.underline,),
                                      ),
                                      const TextSpan(
                                        text: ' di Petsy.',
                                        style: TextStyle(),
                                      ),
                                    ],
                                    style: CustomFlowTheme.of(context).bodySmall,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
