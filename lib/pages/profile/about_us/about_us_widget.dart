import 'package:flutter/material.dart';

class AboutUsWidget extends StatefulWidget {
  const AboutUsWidget({super.key});

  @override
  State<AboutUsWidget> createState() => _AboutUsWidgetState();
}

class _AboutUsWidgetState extends State<AboutUsWidget> {
  late AboutUsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: EdgeInsets.all(24),
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
                                  FlutterFlowTheme.of(context).primary,
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
                              padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
                              child: Text(
                                'About Us',
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0,
                                    ),
                              ),
                            ),
                            /////////////////////////////
                            ///////////////////////////// CASO COVER IMAGE PRESENTE
                            /////////////////////////////
                            if (columnCompanyInformationRecord?.coverImage != null && columnCompanyInformationRecord?.coverImage != '')
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).secondaryBackground,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.network(valueOrDefault<String>(
                                          columnCompanyInformationRecord
                                              ?.coverImage,
                                          'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/meal-planner-3nia1o/assets/uw9p4b649afa/MealPlanner.png',
                                        ),
                                      ).image,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Visibility(
                                    visible: columnCompanyInformationRecord?.logo != null && columnCompanyInformationRecord?.logo != '',
                                    child: Align(
                                      alignment: AlignmentDirectional(-1, -1),
                                      child: Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(12, 12, 0, 0),
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.contain,
                                              image: Image.network(
                                                columnCompanyInformationRecord!.logo,
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
                            ///////////////////////////// CASO COVER IMAGE PRESENTE E LOGO PRESENTE 
                            /////////////////////////////
                            if ((columnCompanyInformationRecord?.logo != null && columnCompanyInformationRecord?.logo != '') &&
                                (columnCompanyInformationRecord?.coverImage == null || columnCompanyInformationRecord ?.coverImage == ''))
                              Align(
                                alignment: AlignmentDirectional(-1, -1),
                                child: Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 18),
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.contain,
                                        image: Image.network(
                                          valueOrDefault<String>(
                                            columnCompanyInformationRecord?.logo,
                                            'https://storage.googleapis.com/flutterflow-io-6f20.appspot.com/projects/meal-planner-3nia1o/assets/uw9p4b649afa/MealPlanner.png',
                                          ),
                                        ).image,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 6),
                              child: Text(
                                valueOrDefault<String>(
                                  columnCompanyInformationRecord?.name,
                                  'Company Name',
                                ),
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Inter',
                                      letterSpacing: 0,
                                ),
                              ),
                            ),
                            Text(
                              columnCompanyInformationRecord!.companyBio,
                              style: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0,
                                    lineHeight: 1.4,
                              ),
                            ),
                            /////////////////////////////
                            ///////////////////////////// CASO DEVELOPERS PRESENTI 
                            /////////////////////////////
                            if (columnCompanyInformationRecord!.devInfo.length > 0)
                              Padding(
                                padding:EdgeInsetsDirectional.fromSTEB(0, 32, 0, 0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Gli sviluppatori',
                                      style: FlutterFlowTheme.of(context)
                                          .headlineSmall
                                          .override(
                                            fontFamily: 'Inter',
                                            letterSpacing: 0,
                                          ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 0),
                                      child: Builder(
                                        builder: (context) {
                                          final devs = columnCompanyInformationRecord
                                                      ?.devInfo
                                                      ?.toList() ?? [];
                                          return Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: List.generate(devs.length, (devsIndex) {
                                              final devsItem = devs[devsIndex];
                                              return Padding(
                                                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                                                child: Row(
                                                  mainAxisSize:MainAxisSize.min,
                                                  children: [
                                                    /////////////////////////////
                                                    ///////////////////////////// CASO DEVELOPERS ABBIA IMMAGINE PROFILO 
                                                    /////////////////////////////
                                                    if (devsItem.profilePicture != null && devsItem.profilePicture !='')
                                                      Container(
                                                        width: 100,
                                                        height: 100,
                                                        decoration: BoxDecoration(
                                                          color: FlutterFlowTheme
                                                                .of(context)
                                                                .secondaryBackground,
                                                          image: DecorationImage(
                                                              fit: BoxFit.cover,
                                                              image:Image.network(
                                                                devsItem.profilePicture,
                                                              ).image,
                                                          ),
                                                          borderRadius:BorderRadius.circular(12),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                                                        child: Column(
                                                          mainAxisSize:MainAxisSize.max,
                                                          crossAxisAlignment:CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              devsItem.name,
                                                              style: FlutterFlowTheme
                                                                      .of(context)
                                                                      .titleMedium
                                                                      .override(
                                                                        fontFamily: 'Inter',
                                                                        letterSpacing: 0,
                                                              ),
                                                            ),
                                                            /////////////////////////////
                                                            ///////////////////////////// CASO DEVELOPERS ABBIA BIOGRAFIA 
                                                            /////////////////////////////
                                                            if (devsItem.bio != null && devsItem.bio != '')
                                                              Padding(
                                                                padding: EdgeInsetsDirectional.fromSTEB(0, 6, 0, 0),
                                                                child: Text(
                                                                  devsItem.bio,
                                                                  style: FlutterFlowTheme.of(context)
                                                                      .bodySmall
                                                                      .override(
                                                                        fontFamily: 'Inter',
                                                                        letterSpacing: 0,
                                                                  ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
