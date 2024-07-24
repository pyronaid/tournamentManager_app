import 'package:flutter/material.dart';

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
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: AlignmentDirectional(0, 0),
            child: Padding(
              padding: EdgeInsets.all(24),
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
                    padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'Registrati',
                      style: FlutterFlowTheme.of(context).displaySmall.override(
                        fontFamily: 'Inter',
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  Form(
                    key: _model.formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                child: Text(
                                  'Nome completo',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.fullNameTextController,
                                focusNode: _model.fullNameFocusNode,
                                autofocus: false,
                                autofillHints: [AutofillHints.name],
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1,
                                ),
                                minLines: 1,
                                cursorColor: FlutterFlowTheme.of(context).primary,
                                validator: _model
                                    .fullNameTextControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                child: Text(
                                  'Email',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.emailAddressTextController,
                                focusNode: _model.emailAddressFocusNode,
                                autofocus: false,
                                autofillHints: [AutofillHints.email],
                                textInputAction: TextInputAction.next,
                                obscureText: false,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1,
                                ),
                                minLines: 1,
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: FlutterFlowTheme.of(context).primary,
                                validator: _model
                                    .emailAddressTextControllerValidator
                                    .asValidator(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                child: Text(
                                  'Password',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Inter',
                                        letterSpacing: 0,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _model.passwordTextController,
                                focusNode: _model.passwordFocusNode,
                                autofocus: false,
                                autofillHints: [AutofillHints.newPassword],
                                textInputAction: TextInputAction.done,
                                obscureText: !_model.passwordVisibility,
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          FlutterFlowTheme.of(context).primary,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: FlutterFlowTheme.of(context).error,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  filled: true,
                                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
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
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Inter',
                                      fontSize: 16,
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1,
                                    ),
                                cursorColor: FlutterFlowTheme.of(context).primary,
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
                    padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: FFButtonWidget(
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
                            diet: FFAppState().userDiet,
                          ),
                          ...mapToFirestore(
                            {
                              'allergens': FFAppState().userAllergens,
                              'ingredient_dislikes':
                                  FFAppState().userIngredientDislikes,
                            },
                          ),
                        });

                        logFirebaseEvent('Button_navigate_to');

                        context.goNamedAuth('Dashboard', context.mounted);
                      },
                      text: 'Crea Account',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Inter',
                                  letterSpacing: 0,
                        ),
                        elevation: 0,
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).primary,),
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
                                        text: 'Cliccando \"Crea Account,\" accetti i ',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Termini contrattuali',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily: 'Inter',
                                              letterSpacing: 0,
                                              decoration:
                                                  TextDecoration.underline,
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'di Petsy.',
                                        style: TextStyle(),
                                      ),
                                    ],
                                    style: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .override(
                                          fontFamily: 'Inter',
                                          letterSpacing: 0,
                                    ),
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
