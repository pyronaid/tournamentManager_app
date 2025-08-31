import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class OnboardingCreateAccountWidget extends StatefulWidget {
  const OnboardingCreateAccountWidget({super.key});

  @override
  State<OnboardingCreateAccountWidget> createState() =>
      _OnboardingCreateAccountWidgetState();
}

class _OnboardingCreateAccountWidgetState extends State<OnboardingCreateAccountWidget> {
  late OnboardingCreateAccountModel _model;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OnboardingCreateAccountModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_CreateAccount'});
    _model.nameTextController ??= TextEditingController();
    _model.nameFocusNode ??= FocusNode();

    _model.surnameTextController ??= TextEditingController();
    _model.surnameFocusNode ??= FocusNode();

    _model.usernameTextController ??= TextEditingController();
    _model.usernameFocusNode ??= FocusNode();

    _model.emailAddressTextController ??= TextEditingController();
    _model.emailAddressFocusNode ??= FocusNode();

    _model.passwordTextController ??= TextEditingController();
    _model.passwordFocusNode ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    _unfocusNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
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
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          ////////////////
                          //NOME COMPLETO NOME 
                          /////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Nome',
                                    style: CustomFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                TextFormField(
                                  controller: _model.nameTextController,
                                  focusNode: _model.nameFocusNode,
                                  autofocus: false,
                                  autofillHints: const [AutofillHints.name],
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: standardInputDecoration(
                                    context,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: CustomFlowTheme.of(context).secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                  style: CustomFlowTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1,
                                  ),
                                  minLines: 1,
                                  cursorColor: CustomFlowTheme.of(context).primary,
                                  validator: _model
                                      .nameTextControllerValidator
                                      .asValidator(context),
                                  onChanged: (val) => _model.clearServerError('name'),
                                ),
                              ],
                            ),
                          ),
                          ////////////////
                          //NOME COMPLETO SURNAME
                          /////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Cognome',
                                    style: CustomFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                TextFormField(
                                  controller: _model.surnameTextController,
                                  focusNode: _model.surnameFocusNode,
                                  autofocus: false,
                                  autofillHints: const [AutofillHints.familyName],
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: standardInputDecoration(
                                    context,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: CustomFlowTheme.of(context).secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                  style: CustomFlowTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1,
                                  ),
                                  minLines: 1,
                                  cursorColor: CustomFlowTheme.of(context).primary,
                                  validator: _model
                                      .surnameTextControllerValidator
                                      .asValidator(context),
                                  onChanged: (val) => _model.clearServerError('surname'),
                                ),
                              ],
                            ),
                          ),
                          ////////////////
                          //NOME COMPLETO USERNAME
                          /////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Username',
                                    style: CustomFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                TextFormField(
                                  controller: _model.usernameTextController,
                                  focusNode: _model.usernameFocusNode,
                                  autofocus: false,
                                  autofillHints: const [AutofillHints.username],
                                  //textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: standardInputDecoration(
                                    context,
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: CustomFlowTheme.of(context).secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                  style: CustomFlowTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1,
                                  ),
                                  minLines: 1,
                                  cursorColor: CustomFlowTheme.of(context).primary,
                                  validator: _model
                                      .usernameTextControllerValidator
                                      .asValidator(context),
                                  onChanged: (val) => _model.clearServerError('username'),
                                ),
                              ],
                            ),
                          ),
                          ////////////////
                          //MAIL
                          /////////////////
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
                                  onChanged: (val) => _model.clearServerError('email'),
                                ),
                              ],
                            ),
                          ),
                          ////////////////
                          //PASSWORD
                          /////////////////
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
                                    prefixIcon: Icon(
                                      Icons.lock,
                                      color: CustomFlowTheme.of(context).secondaryText,
                                      size: 18,
                                    ),
                                    suffixIcons: [
                                      InkWell(
                                        onTap: () => setState(
                                              () => _model.passwordVisibility = !_model.passwordVisibility,
                                        ),
                                        focusNode: FocusNode(skipTraversal: true),
                                        child: Icon(
                                          _model.passwordVisibility ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                          color: CustomFlowTheme.of(context).secondaryText,
                                          size: 18,
                                        ),
                                      )
                                    ],
                                  ),
                                  style: CustomFlowTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1,
                                  ),
                                  cursorColor: CustomFlowTheme.of(context).primary,
                                  validator: _model
                                      .passwordTextControllerValidator
                                      .asValidator(context),
                                  onChanged: (val) => _model.clearServerError('password'),
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
            
                          //REGISTRATION
                          _model.clearAllServerErrors();
                          Tuple3<bool,String,String> createAccountFlag = await pocketAuthManager.createAccountWithEmail(
                            mail: _model.emailAddressTextController.text,
                            password: _model.passwordTextController.text,
                            name: _model.nameTextController.text,
                            surname: _model.surnameTextController.text,
                            username: _model.usernameTextController.text
                          );
                          if (!createAccountFlag.item1) {
                            if (createAccountFlag.item2.isNotEmpty && createAccountFlag.item3.isNotEmpty) {
                              _model.addServerError(createAccountFlag.item2, createAccountFlag.item3);
                              _formKey.currentState!.validate();
                            }
                            return;
                          }
            
                          logFirebaseEvent('Button_navigate_to');
                          context.goNamedAuth('Onboarding_VerifyMail',
                            context.mounted,
                            queryParameters: {
                              'email': serializeParam(
                                _model.emailAddressTextController.text,
                                ParamType.String,
                              ),
                            }.withoutNulls,
                          );
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
                            child: FutureBuilder<CompanyInformationRecord?>(
                              future: CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', false),
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
            
                                // Return an empty Container when the item does not exist.
                                if (snapshot.data == null) {
                                  return Container();
                                }
                                CompanyInformationRecord? richTextCompanyInformationRecord = snapshot.data!;
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {
                                    logFirebaseEvent('ONBOARDING_CREATE_ACCOUNT_RichText_t8sm7');
                                    logFirebaseEvent('RichText_launch_u_r_l');
                                    await launchURL(richTextCompanyInformationRecord.termsURL);
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
                                          style: CustomFlowTheme.of(context).bodyMedium.override(decoration: TextDecoration.underline,),
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
                    ),
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