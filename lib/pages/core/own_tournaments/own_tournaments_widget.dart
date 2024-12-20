import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/auth/firebase_auth/auth_util.dart';
import 'package:tournamentmanager/backend/backend.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:tournamentmanager/components/no_tournament_card/no_tournament_card_widget.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_widget.dart';
import 'package:tournamentmanager/pages/core/own_tournaments/own_tournaments_model.dart';


class OwnTournamentsWidget extends StatefulWidget {
  const OwnTournamentsWidget({super.key});

  @override
  State<OwnTournamentsWidget> createState() => _OwnTournamentsWidgetState();
}


class _OwnTournamentsWidgetState extends State<OwnTournamentsWidget> {
  late OwnTournamentsModel _model;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => OwnTournamentsModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Own_Tournaments'});

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
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
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
                  width: 100.w,
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
                        AuthUserStreamWidget(
                          builder: (context) => StreamBuilder<List<TournamentsRecord>>(
                            stream: queryTournamentsRecord(
                              queryBuilder: (tournamentsRecord) => tournamentsRecord
                                .where('creator_uid', isEqualTo: currentUser?.uid)
                                .where('state', isNotEqualTo: StateTournament.close.name),
                            ),
                            builder: (BuildContext context, AsyncSnapshot<List<TournamentsRecord>> snapshot) {
                              /////////////////////////////////////////
                              ////////////// LOADING OPPORTUNITY
                              /////////////////////////////////////////
                              if (!snapshot.hasData) {
                                return const GenericLoadingWidget();
                              }
                              /////////////////////////////////////////
                              ////////////// EMPTY CASE
                              /////////////////////////////////////////
                              List<TournamentsRecord> tournamentsRecordList = snapshot.data!;
                              if (tournamentsRecordList.isEmpty) {
                                return const NoTournamentCardWidget(
                                  active: true,
                                  phrase: "Non risultano tornei attivi o futuri. Creane uno per gestirlo da qui!",
                                );
                              }
                              /////////////////////////////////////////
                              ////////////// STANDARD CASE
                              /////////////////////////////////////////
                              return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List.generate(
                                      tournamentsRecordList.length,
                                          (index) {
                                        final tournament = tournamentsRecordList[index];
                                        return TournamentCardWidget(
                                          key: Key('Keykia_${tournament.uid}_position_${index}_of_${tournamentsRecordList.length}'),
                                          last: index == (tournamentsRecordList.length - 1),
                                          tournamentRef: tournament,
                                          active: false,
                                        );
                                      }
                                  )
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ////////////////
                //PAST SECTION
                /////////////////
                SizedBox(
                  width: 100.w,
                  child: Padding(
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
                              'TERMINATI',
                              style: CustomFlowTheme.of(context).headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        AuthUserStreamWidget(
                          builder: (context) => StreamBuilder<List<TournamentsRecord>>(
                            stream: queryTournamentsRecord(
                              queryBuilder: (tournamentsRecord) => tournamentsRecord
                                  .where('creator_uid', isEqualTo: currentUser?.uid)
                                  .where('state', isEqualTo: StateTournament.close.name),
                            ),
                            builder: (BuildContext context, AsyncSnapshot<List<TournamentsRecord>> snapshot) {
                              /////////////////////////////////////////
                              ////////////// LOADING OPPORTUNITY
                              /////////////////////////////////////////
                              if (!snapshot.hasData) {
                                return const GenericLoadingWidget();
                              }
                              /////////////////////////////////////////
                              ////////////// EMPTY CASE
                              /////////////////////////////////////////
                              List<TournamentsRecord> tournamentsRecordList = snapshot.data!;
                              if (tournamentsRecordList.isEmpty) {
                                return const NoTournamentCardWidget(
                                  active: false,
                                  phrase: "Non risultano tornei terminati. Creane uno e gestiscilo da qui!",
                                );
                              }
                              /////////////////////////////////////////
                              ////////////// STANDARD CASE
                              /////////////////////////////////////////
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: List.generate(
                                  tournamentsRecordList.length,
                                  (index) {
                                    final tournament = tournamentsRecordList[index];
                                    return TournamentCardWidget(
                                      key: Key('Keykia_${tournament.uid}_position_${index}_of_${tournamentsRecordList.length}'),
                                      last: index == (tournamentsRecordList.length - 1),
                                      tournamentRef: tournament,
                                      active: false,
                                    );
                                  }
                                )
                              );
                            },
                          ),
                        ),
                      ],
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
