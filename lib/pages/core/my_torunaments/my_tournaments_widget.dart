import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../backend/backend.dart';
import '../../../components/custom_appbar_widget.dart';
import 'my_tournaments_model.dart';

class MyTournamentsWidget extends StatefulWidget {
  const MyTournamentsWidget({super.key});

  @override
  State<MyTournamentsWidget> createState() => _CreateOwnWidgetState();
}


class _CreateOwnWidgetState extends State<MyTournamentsWidget> with TickerProviderStateMixin {
  late MyTournamentsModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MyTournamentsModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'My_Tournaments'});

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
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child:  SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ////////////////
                  //ACTIVE SECTION
                  /////////////////
                  Container(
                    decoration: BoxDecoration(
                      color: CustomFlowTheme.of(context).secondary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20.0),
                        bottomRight: Radius.circular(20.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 48, 24, 54),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                              child: Text(
                                'ATTIVI/FUTURI',
                                style: CustomFlowTheme.of(context).headlineLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          StreamBuilder<List<TournamentsRecord>>(
                            stream: queryTournamentsRecord(
                              queryBuilder: (tournamentsRecord) => tournamentsRecord.where(
                                'field',
                                isEqualTo: valueOrDefault(value, defaultValue)
                              )
                            ),
                            builder: builder
                          ),
                          // look as example todo and  LISTA AZIONI in profile_widget


                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ////////////////
                                //DATE
                                /////////////////
                                SizedBox(
                                  width: 15.w,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '23',
                                        style: CustomFlowTheme.of(context).titleLarge,
                                      ),
                                      Text(
                                        'may',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      Text(
                                        '2024',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                ////////////////
                                //NAME & ADDRESS
                                /////////////////
                                SizedBox(
                                  width: 60.w,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                          style: CustomFlowTheme.of(context).bodySmall,
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          'address placeholder here',
                                          style: CustomFlowTheme.of(context).labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ////////////////
                                //STATE
                                /////////////////
                                SizedBox(
                                  width: 12.w,
                                  child: Text(
                                    'IN CORSO',
                                    style: CustomFlowTheme.of(context).bodyMicro,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: CustomFlowTheme.of(context).primaryText,
                            height: 80, // Space around the divider
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ////////////////
                                //DATE
                                /////////////////
                                SizedBox(
                                  width: 15.w,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '23',
                                        style: CustomFlowTheme.of(context).titleLarge,
                                      ),
                                      Text(
                                        'may',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      Text(
                                        '2024',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                ////////////////
                                //NAME & ADDRESS
                                /////////////////
                                SizedBox(
                                  width: 60.w,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                          style: CustomFlowTheme.of(context).bodySmall,
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          'address placeholder here',
                                          style: CustomFlowTheme.of(context).labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ////////////////
                                //STATE
                                /////////////////
                                SizedBox(
                                  width: 12.w,
                                  child: Text(
                                    'IN CORSO',
                                    style: CustomFlowTheme.of(context).bodyMicro,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            thickness: 1,
                            color: CustomFlowTheme.of(context).primaryText,
                            height: 80, // Space around the divider
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ////////////////
                                //DATE
                                /////////////////
                                SizedBox(
                                  width: 15.w,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '23',
                                        style: CustomFlowTheme.of(context).titleLarge,
                                      ),
                                      Text(
                                        'may',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      Text(
                                        '2024',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                ////////////////
                                //NAME & ADDRESS
                                /////////////////
                                SizedBox(
                                  width: 60.w,
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                          style: CustomFlowTheme.of(context).bodySmall,
                                        ),
                                        const SizedBox(height: 10.0),
                                        Text(
                                          'address placeholder here',
                                          style: CustomFlowTheme.of(context).labelMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ////////////////
                                //STATE
                                /////////////////
                                SizedBox(
                                  width: 12.w,
                                  child: Text(
                                    'IN CORSO',
                                    style: CustomFlowTheme.of(context).bodyMicro,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ////////////////
                  //PAST SECTION
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 54, 24, 54),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                            child: Text(
                              'PASSATI',
                              style: CustomFlowTheme.of(context).headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ////////////////
                              //DATE
                              /////////////////
                              SizedBox(
                                width: 15.w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '23',
                                      style: CustomFlowTheme.of(context).titleLarge,
                                    ),
                                    Text(
                                      'may',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                    Text(
                                      '2024',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              ////////////////
                              //NAME & ADDRESS
                              /////////////////
                              SizedBox(
                                width: 60.w,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        'address placeholder here',
                                        style: CustomFlowTheme.of(context).labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ////////////////
                              //STATE
                              /////////////////
                              SizedBox(
                                width: 12.w,
                                child: Text(
                                  'IN CORSO',
                                  style: CustomFlowTheme.of(context).bodyMicro,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: CustomFlowTheme.of(context).primary,
                          height: 80, // Space around the divider
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ////////////////
                              //DATE
                              /////////////////
                              SizedBox(
                                width: 15.w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '23',
                                      style: CustomFlowTheme.of(context).titleLarge,
                                    ),
                                    Text(
                                      'may',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                    Text(
                                      '2024',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              ////////////////
                              //NAME & ADDRESS
                              /////////////////
                              SizedBox(
                                width: 60.w,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        'address placeholder here',
                                        style: CustomFlowTheme.of(context).labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ////////////////
                              //STATE
                              /////////////////
                              SizedBox(
                                width: 12.w,
                                child: Text(
                                  'IN CORSO',
                                  style: CustomFlowTheme.of(context).bodyMicro,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: CustomFlowTheme.of(context).primary,
                          height: 80, // Space around the divider
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ////////////////
                              //DATE
                              /////////////////
                              SizedBox(
                                width: 15.w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      '23',
                                      style: CustomFlowTheme.of(context).titleLarge,
                                    ),
                                    Text(
                                      'may',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                    Text(
                                      '2024',
                                      style: CustomFlowTheme.of(context).bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              ////////////////
                              //NAME & ADDRESS
                              /////////////////
                              SizedBox(
                                width: 60.w,
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NOME TORNEO PLACEHOLD molto lungo per capire come',
                                        style: CustomFlowTheme.of(context).bodySmall,
                                      ),
                                      const SizedBox(height: 10.0),
                                      Text(
                                        'address placeholder here',
                                        style: CustomFlowTheme.of(context).labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              ////////////////
                              //STATE
                              /////////////////
                              SizedBox(
                                width: 12.w,
                                child: Text(
                                  'IN CORSO',
                                  style: CustomFlowTheme.of(context).bodyMicro,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}
