import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/custom_functions.dart' as functions;
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/backend.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  late ProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProfileModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Profile'});
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      logFirebaseEvent('PROFILE_PAGE_Profile_ON_INIT_STATE');
      logFirebaseEvent('Profile_haptic_feedback');
      HapticFeedback.mediumImpact();
    });

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
        backgroundColor: CustomFlowTheme
            .of(context)
            .primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 6),
                          child: Text(
                            valueOrDefault<String>(functions.returnProfileGreeting(getCurrentTimestamp),'Ciao,',),
                            style: CustomFlowTheme.of(context).labelLarge,
                          ),
                        ),
                        AuthUserStreamWidget(
                          builder: (context) => Text(
                            currentUserDisplayName,
                            style: CustomFlowTheme.of(context).displaySmall,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: CustomFlowTheme.of(context).primary,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: CustomFlowTheme.of(context).accent1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Clicca qui se vuoi supportarci!',
                                    style: CustomFlowTheme.of(context).titleMedium,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                    child: Text(
                                      'Da parte del team ti ringraziamo del tuo supporto e speriamo che l\'app possa esserti utile',
                                      style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).info),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        //////////////////////////////
                        ///////// QR CODE SPACE
                        //////////////////////////////
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 20.0),
                          child: Center(
                              child: QrImageView(
                                data: currentUserUid,
                                version: QrVersions.auto,
                                size: 200.0,
                                eyeStyle: QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: CustomFlowTheme.of(context).primaryText,
                                ),
                                dataModuleStyle: QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: CustomFlowTheme.of(context).primaryText,
                                ),
                              )
                          ),
                        ),
                        //////////////////////////////
                        /////////LISTA AZIONI
                        //////////////////////////////
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        CustomFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              List<CompanyInformationRecord> columnCompanyInformationRecordList = snapshot.data!;
                              // Return an empty Container when the item does not exist.
                              if (snapshot.data!.isEmpty) {
                                return Container();
                              }
                              final columnCompanyInformationRecord = columnCompanyInformationRecordList.isNotEmpty
                                  ? columnCompanyInformationRecordList.first
                                  : null;

                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ///////////////////////////////////////
                                  /////////////////////////////////////// EDIT PROFILE + DIVIDER
                                  ///////////////////////////////////////
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      logFirebaseEvent('PROFILE_PAGE_EditProfileTile_ON_TAP');
                                      logFirebaseEvent('EditProfileTile_navigate_to');

                                      context.pushNamedAuth('EditProfile', context.mounted);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: CustomFlowTheme.of(context).accent1,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.person_outline_rounded,
                                                    color:CustomFlowTheme.of(context).primary,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 0, 0),
                                                child: Text(
                                                  'Edit Profile',
                                                  style: CustomFlowTheme.of(context).bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                          color: CustomFlowTheme.of(context).primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ///////////////////////////////////////
                                  /////////////////////////////////////// ABOUT US + DIVIDER
                                  ///////////////////////////////////////
                                  if ((columnCompanyInformationRecord?.name != null && columnCompanyInformationRecord?.name != '') &&
                                      (columnCompanyInformationRecord?.companyBio != null && columnCompanyInformationRecord?.companyBio !=''))
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        logFirebaseEvent('PROFILE_PAGE_AboutUsTile_ON_TAP');
                                        logFirebaseEvent('AboutUsTile_navigate_to');

                                        context.pushNamedAuth('AboutUs', context.mounted);
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: CustomFlowTheme.of(context).accent1,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.info_outlined,
                                                      color: CustomFlowTheme.of(context).primary,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 0, 0),
                                                  child: Text(
                                                    'About Us',
                                                    style: CustomFlowTheme.of(context).bodyLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1,
                                            color: CustomFlowTheme.of(context).primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ///////////////////////////////////////
                                  /////////////////////////////////////// CONTACT US + DIVIDER
                                  ///////////////////////////////////////
                                  if ((columnCompanyInformationRecord?.email != null && columnCompanyInformationRecord?.email != '') ||
                                      (columnCompanyInformationRecord?.phone != null && columnCompanyInformationRecord?.phone != ''))
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        logFirebaseEvent('PROFILE_PAGE_ContactUsTile_ON_TAP');
                                        if (columnCompanyInformationRecord?.email != null && columnCompanyInformationRecord?.email != '') {
                                          logFirebaseEvent('ContactUsTile_send_email');
                                          await launchUrl(Uri(
                                            scheme: 'mailto',
                                            path: columnCompanyInformationRecord!.email,
                                          ));
                                        } else {
                                          logFirebaseEvent('ContactUsTile_call_number');
                                          await launchUrl(Uri(
                                            scheme: 'tel',
                                            path: columnCompanyInformationRecord!.phone,
                                          ));
                                        }
                                      },
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    color: CustomFlowTheme.of(context).accent1,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(4),
                                                    child: Icon(
                                                      Icons.mail_outlined,
                                                      color:CustomFlowTheme.of(context).primary,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 0, 0),
                                                  child: Text(
                                                    'Contact Us',
                                                    style: CustomFlowTheme.of(context).bodyLarge,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Divider(
                                            thickness: 1,
                                            color: CustomFlowTheme.of(context).primary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ///////////////////////////////////////
                                  /////////////////////////////////////// CREATE OWN + DIVIDER
                                  ///////////////////////////////////////
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      logFirebaseEvent('PROFILE_PAGE_CreateOwnTile_ON_TAP');
                                      logFirebaseEvent('CreateOwnTile_navigate_to');

                                      context.pushNamedAuth('CreateOwn', context.mounted);
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Padding(
                                          padding:const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: CustomFlowTheme.of(context).accent1,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(4),
                                                  child: Icon(
                                                    Icons.person_outline_rounded,
                                                    color:CustomFlowTheme.of(context).primary,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(18, 0, 0, 0),
                                                child: Text(
                                                  'Create Own',
                                                  style: CustomFlowTheme.of(context).bodyLarge,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1,
                                          color: CustomFlowTheme.of(context).primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ///////////////////////////////////////
                                  /////////////////////////////////////// LOGOUT
                                  ///////////////////////////////////////
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
                                    child: InkWell(
                                      splashColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () async {
                                        logFirebaseEvent('PROFILE_PAGE_LogoutTile_ON_TAP');
                                        logFirebaseEvent('LogoutTile_auth');
                                        GoRouter.of(context).prepareAuthEvent();
                                        await authManager.signOut();
                                        GoRouter.of(context).clearRedirectLocation();

                                        context.goNamedAuth('Splash', context.mounted);
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            width: 40.0,
                                            height: 40.0,
                                            decoration: BoxDecoration(
                                              color: CustomFlowTheme.of(context).accent1,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4.0),
                                              child: Icon(
                                                Icons.logout,
                                                color: CustomFlowTheme.of(context).primary,
                                                size: 18.0,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding:const EdgeInsetsDirectional.fromSTEB(18.0, 0.0, 0.0, 0.0),
                                            child: Text(
                                              'Log out',
                                              style: CustomFlowTheme.of(context).bodyLarge,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ].addToEnd(const SizedBox(height: 44.0)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
