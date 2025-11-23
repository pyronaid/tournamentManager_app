import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/app_flow/nav/nav_basics.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/components/title_with_subtitle/title_with_subtitle_widget.dart';
import 'package:tournamentmanager/pages/profile/edit_profile/edit_profile_model.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';


class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {

  late EditProfileModel editProfileModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'EditProfile'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    editProfileModel = context.read<EditProfileModel>();
    editProfileModel.initContextVars(context);
  }


  @override
  void dispose() {
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
                    wrapWithModel(
                      model: editProfileModel.customAppbarModel,
                      updateCallback: () => setState(() {}),
                      child: CustomAppbarWidget(
                        backButton: true,
                        actionButton: true,
                        actionButtonText: 'Salva',
                        actionButtonAction: () async {
                          logFirebaseEvent('EDIT_PROFILE_Container_or1jni5i_CALLBACK');
                          logFirebaseEvent('customAppbar_backend_call');
                          if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                            return;
                          }
                          editProfileModel.updateUserProfile(_formKey);
                          logFirebaseEvent('customAppbar_update_page_state');
                        },
                        optionsButtonAction: () async {},
                      ),
                    ),
                    ////////////////
                    //PAGE TITLE
                    /////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                      child: Text(
                        'Modifica Profilo',
                        style: CustomFlowTheme.of(context).displaySmall,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                          child: Form(
                            key: _formKey,
                            autovalidateMode: AutovalidateMode.disabled,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ////////////////
                                //FIRST FORM NAME
                                /////////////////
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Nome',
                                    style: CustomFlowTheme.of(context).bodyLarge,
                                  ),
                                ),
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                  child: AuthUserStreamWidget(
                                    builder: (context) => TextFormField(
                                      controller: editProfileModel.nameTextController,
                                      focusNode: editProfileModel.nameFocusNode,
                                      onChanged: (_) {
                                        EasyDebounce.debounce(
                                          '_model.fullNameTextController',
                                          const Duration(milliseconds: 2000),
                                              () async {
                                            logFirebaseEvent('EDIT_PROFILE_fullName_ON_TEXTFIELD_CHANG');
                                            logFirebaseEvent('fullName_update_page_state');
                                          },
                                        );
                                        editProfileModel.clearServerError('name');
                                      },
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
                                      validator: editProfileModel.nameTextControllerValidator?.asValidator(context),
                                    ),
                                  ),
                                ),
                                ////////////////
                                //FIRST FORM SURNAME
                                /////////////////
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Cognome',
                                    style: CustomFlowTheme.of(context).bodyLarge,
                                  ),
                                ),
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                  child: AuthUserStreamWidget(
                                    builder: (context) => TextFormField(
                                      controller: editProfileModel.surnameTextController,
                                      focusNode: editProfileModel.surnameFocusNode,
                                      onChanged: (_) {
                                        EasyDebounce.debounce(
                                          '_model.surnameTextController',
                                          const Duration(milliseconds: 2000),
                                              () async {
                                            logFirebaseEvent('EDIT_PROFILE_surname_ON_TEXTFIELD_CHANG');
                                            logFirebaseEvent('surname_update_page_state');
                                          },
                                        );
                                        editProfileModel.clearServerError('surname');
                                      },
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
                                      validator: editProfileModel.surnameTextControllerValidator?.asValidator(context),
                                    ),
                                  ),
                                ),
                                ////////////////
                                //FIRST FORM USERNAME
                                /////////////////
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Username',
                                    style: CustomFlowTheme.of(context).bodyLarge,
                                  ),
                                ),
                                Padding(
                                  padding:const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                                  child: AuthUserStreamWidget(
                                    builder: (context) => TextFormField(
                                      controller: editProfileModel.usernameTextController,
                                      focusNode: editProfileModel.usernameFocusNode,
                                      onChanged: (_) {
                                        EasyDebounce.debounce(
                                          '_model.usernameTextController',
                                          const Duration(milliseconds: 2000),
                                              () async {
                                            logFirebaseEvent('EDIT_PROFILE_username_ON_TEXTFIELD_CHANG');
                                            logFirebaseEvent('username_update_page_state');
                                          },
                                        );
                                        editProfileModel.clearServerError('username');
                                      },
                                      autofocus: false,
                                      autofillHints: const [AutofillHints.username],
                                      textCapitalization: TextCapitalization.none,
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
                                      validator: editProfileModel.usernameTextControllerValidator?.asValidator(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    ////////////////
                    //PASSWORD BUTTON
                    /////////////////
                    const TitleWithSubtitleWidget(
                      title: 'Reset Password',
                      subtitle: 'Ricevi un link via email per resettare la tua password.',
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: AFButtonWidget(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          logFirebaseEvent('EDIT_PROFILE_RESET_PASSWORD_BTN_ON_TAP');
                          logFirebaseEvent('Button_auth');
                          if (editProfileModel.emailAddressTextController.text.isEmpty) {
                            editProfileModel.showIssueSnackBar();
                          } else {
                            context.goNamed(
                                'DialogResetPassword',
                                extra: {
                                  'req' : editProfileModel.showResetPasswordAlertRequest(),
                                }
                            );
                          }
                        },
                        text: 'Reset Password',
                        options: AFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: CustomFlowTheme.of(context).primary,
                          textStyle: CustomFlowTheme.of(context).bodyMedium.override(color: CustomFlowTheme.of(context).primaryBackground),
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
                    //MAIL BUTTON
                    /////////////////
                    TitleWithSubtitleWidget(
                      title: 'Cambio Mail',
                      subtitle: 'Avvia la procedura di cambio mail: $currentUserEmail',
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                      child: AFButtonWidget(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          logFirebaseEvent('EDIT_PROFILE_CHANGE_MAIL_BTN_ON_TAP');
                          logFirebaseEvent('Button_auth');
                          if (editProfileModel.emailAddressTextController.text.isEmpty) {
                            editProfileModel.showIssueSnackBar();
                          } else {
                            context.goNamed(
                                'DialogChangeMail',
                                extra: {
                                  'req' : editProfileModel.showChangeMailAlertRequest(),
                                }
                            );
                          }
                        },
                        text: 'Change Mail',
                        options: AFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: CustomFlowTheme.of(context).primary,
                          textStyle: CustomFlowTheme.of(context).bodyMedium.override(color: CustomFlowTheme.of(context).primaryBackground),
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
                    //DELETE ACCOUNT BUTTON
                    /////////////////
                    const TitleWithSubtitleWidget(
                      title: 'Cancella Account',
                      subtitle: 'I dati del tuo account saranno cancellati senza possibilità di ripristino.',
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 48),
                      child: AFButtonWidget(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          logFirebaseEvent('EDIT_PROFILE_DELETE_ACCOUNT_BTN_ON_TAP');
                          logFirebaseEvent('Button_auth');
                          context.goNamed(
                              'DialogDeleteAccount',
                              extra: {
                                'req' : editProfileModel.showConfirmDeletionAccountAlertRequest(),
                              }
                          );
                        },
                        text: 'Cancella Account',
                        options: AFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: const Color(0xFFFFD4D4),
                          textStyle: CustomFlowTheme.of(context).bodyMedium.override(color: const Color(0xFFB74D4D)),
                          elevation: 0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: editProfileModel.emailAddressTextController,
                      focusNode: editProfileModel.emailAddressFocusNode,
                      autofocus: false,
                      textCapitalization: TextCapitalization.none,
                      readOnly: true,
                      obscureText: false,
                      decoration: const InputDecoration(
                        isDense: true,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      style: CustomFlowTheme.of(context).bodyMedium.override(
                        color: CustomFlowTheme.of(context).primaryBackground,
                        fontSize: 1,
                        fontWeight: FontWeight.w500,
                        lineHeight: 1,
                      ),
                      minLines: 1,
                      validator: editProfileModel.emailAddressTextControllerValidator.asValidator(context, ''),
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
