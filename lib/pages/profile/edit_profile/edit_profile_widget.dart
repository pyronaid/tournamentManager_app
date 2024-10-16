import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../app_flow/services/supportClass/AlertClasses.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../components/title_with_subtitle/title_with_subtitle_widget.dart';
import 'edit_profile_model.dart';

class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> with TickerProviderStateMixin {

  late EditProfileModel editProfileModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => editProfileModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(editProfileModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
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
                        editProfileModel.setFullName(currentUserReference);
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
                                'Nome Completo',
                                style: CustomFlowTheme.of(context).bodyLarge,
                              ),
                            ),
                            Padding(
                              padding:const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                              child: AuthUserStreamWidget(
                                builder: (context) => TextFormField(
                                  controller: editProfileModel.fullNameTextController,
                                  focusNode: editProfileModel.fullNameFocusNode,
                                  onChanged: (_) => EasyDebounce.debounce(
                                    '_model.fullNameTextController',
                                    const Duration(milliseconds: 2000),
                                    () async {
                                      logFirebaseEvent('EDIT_PROFILE_fullName_ON_TEXTFIELD_CHANG');
                                      logFirebaseEvent('fullName_update_page_state');
                                    },
                                  ),
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
                                  validator: editProfileModel.fullNameTextControllerValidator.asValidator(context),
                                ),
                              ),
                            ),
                          ],
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
                          editProfileModel.showResetPasswordIssueSnackBar();
                        } else {
                          await authManager.resetPassword(
                            email: editProfileModel.emailAddressTextController.text,
                            context: context,
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
                        AlertResponse resp = await editProfileModel.showConfirmDeletionAccountDialog();
                        if(resp.confirmed){
                          await authManager.deleteUser(context);
                          logFirebaseEvent('Button_navigate_to');
                          context.goNamed(
                            'Splash',
                            extra: <String, dynamic>{
                              kTransitionInfoKey: const TransitionInfo(
                                hasTransition: true,
                                transitionType: PageTransitionType.fade,
                                duration: Duration(milliseconds: 0),
                              ),
                            },
                          );
                        }
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
                    textCapitalization: TextCapitalization.words,
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
                    validator: editProfileModel.emailAddressTextControllerValidator.asValidator(context),
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
