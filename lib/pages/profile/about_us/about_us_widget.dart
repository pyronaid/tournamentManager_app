import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/backend/schema/developer_information_record.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'about_us_model.dart';

class AboutUsWidget extends StatefulWidget {
  const AboutUsWidget({super.key});

  @override
  State<AboutUsWidget> createState() => _AboutUsWidgetState();
}

class _AboutUsWidgetState extends State<AboutUsWidget> {
  late AboutUsModel _model;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AboutUsModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AboutUs'});
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
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: FutureBuilder<CompanyInformationRecord?>(
                    future: CompanyInformationRecord.getFirstDocumentByFilterOnce(pb, '', true),
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
                      // Return an empty Container when the item does not exist.
                      if (snapshot.data == null) {
                        return Container();
                      }
                      CompanyInformationRecord? columnCompanyInformationRecord = snapshot.data!;
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: CustomFlowTheme.of(context).secondary,
                            padding: const EdgeInsets.all(24),
                            child: Column(
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
                                ////////////////
                                //PAGE TITLE
                                /////////////////
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                  child: Text(
                                    'About Us',
                                    style: CustomFlowTheme.of(context).displaySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /////////////////////////////
                          ///////////////////////////// CASO COVER IMAGE PRESENTE
                          /////////////////////////////
                          if (columnCompanyInformationRecord.coverImage != '')
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 18),
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: CustomFlowTheme.of(context).secondaryBackground,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image.network(valueOrDefault<String>(
                                        columnCompanyInformationRecord.coverImage,
                                        'https://firebasestorage.googleapis.com/v0/b/tournament-manager-ee897.appspot.com/o/assets%2FTM_logo.png?alt=media',
                                      ),
                                    ).image,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Visibility(
                                  visible: columnCompanyInformationRecord.logo != '',
                                  child: Align(
                                    alignment: const AlignmentDirectional(-1, -1),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 0),
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.contain,
                                            image: Image.network(
                                              columnCompanyInformationRecord.logo,
                                            ).image,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          /////////////////////////////
                          ///////////////////////////// CASO COVER IMAGE ASSENTE E LOGO PRESENTE
                          /////////////////////////////
                          if (columnCompanyInformationRecord.logo != '' && columnCompanyInformationRecord .coverImage == '')
                            Align(
                              alignment: const AlignmentDirectional(-1, -1),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 18),
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.contain,
                                      image: Image.network(
                                        valueOrDefault<String>(
                                          columnCompanyInformationRecord.logo,
                                          'https://firebasestorage.googleapis.com/v0/b/tournament-manager-ee897.appspot.com/o/assets%2FTM_logo_letters.png?alt=media',
                                        ),
                                      ).image,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                              ),
                            ),
                          /////////////////////////////
                          ///////////////////////////// FINE IF
                          /////////////////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 6),
                            child: Text(
                              valueOrDefault<String>(
                                columnCompanyInformationRecord.name,
                                'Company Name',
                              ),
                              style: CustomFlowTheme.of(context).displaySmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                            child: Text(
                              columnCompanyInformationRecord.companyBio,
                              style: CustomFlowTheme.of(context).labelLarge.override(lineHeight: 1.4),
                            ),
                          ),
                          /////////////////////////////
                          ///////////////////////////// CASO DEVELOPERS PRESENTI
                          /////////////////////////////
                          if (columnCompanyInformationRecord.devInfo.isNotEmpty)
                            Padding(
                              padding:const EdgeInsetsDirectional.fromSTEB(24, 32, 24, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gli sviluppatori',
                                    style: CustomFlowTheme.of(context).headlineSmall,
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                    child: Builder(
                                      builder: (context) {
                                        final devs = columnCompanyInformationRecord.devInfo.toList();
                                        return Column(
                                          mainAxisSize: MainAxisSize.max,
                                          children: List.generate(devs.length, (devsIndex) {
                                            final DevelopersInformationRecord devsItem = devs[devsIndex];
                                            return Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                                              child: Row(
                                                mainAxisSize:MainAxisSize.min,
                                                children: [
                                                  /////////////////////////////
                                                  ///////////////////////////// CASO DEVELOPERS ABBIA IMMAGINE PROFILO
                                                  /////////////////////////////
                                                  if (devsItem.profilePic !='')
                                                    Container(
                                                      width: 100,
                                                      height: 100,
                                                      decoration: BoxDecoration(
                                                        color: CustomFlowTheme.of(context).secondaryBackground,
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image:Image.network(devsItem.profilePic,).image,
                                                        ),
                                                        borderRadius:BorderRadius.circular(12),
                                                      ),
                                                    ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                      child: Column(
                                                        mainAxisSize:MainAxisSize.max,
                                                        crossAxisAlignment:CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            devsItem.name,
                                                            style: CustomFlowTheme.of(context).titleMedium,
                                                          ),
                                                          /////////////////////////////
                                                          ///////////////////////////// CASO DEVELOPERS ABBIA BIOGRAFIA
                                                          /////////////////////////////
                                                          if (devsItem.bio != '')
                                                            Padding(
                                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                                              child: Text(
                                                                devsItem.bio,
                                                                style: CustomFlowTheme.of(context).bodyMedium,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
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
