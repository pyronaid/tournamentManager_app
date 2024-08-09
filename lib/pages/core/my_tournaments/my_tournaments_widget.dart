import 'package:flutter/material.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/no_tournament_card/no_tournament_card_widget.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/backend.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/tournament_card/tournament_card_widget.dart';
import 'my_tournaments_model.dart';

class MyTournamentsWidget extends StatefulWidget {
  const MyTournamentsWidget({super.key});

  @override
  State<MyTournamentsWidget> createState() => _MyTournamentsWidgetState();
}


class _MyTournamentsWidgetState extends State<MyTournamentsWidget> with TickerProviderStateMixin {
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
                        AuthUserStreamWidget(
                          builder: (context) => StreamBuilder<List<TournamentsRecord>>(
                            stream: queryTournamentsRecord(
                              queryBuilder: (tournamentsRecord) => tournamentsRecord
                                .where('involved_list', arrayContains: currentUser?.uid)
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
                                  phrase: "Non risultano tornei attivi o futuri. Cercane uno e mettiti alla prova!",
                                );
                              }
                              /////////////////////////////////////////
                              ////////////// STANDARD CASE
                              /////////////////////////////////////////
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: tournamentsRecordList.length,
                                itemBuilder: (context, index) {
                                  final tournament = tournamentsRecordList[index];
                                  return TournamentCardWidget(
                                    key: Key('Keykia_${tournament.uid}_position_${index}_of_${tournamentsRecordList.length}'),
                                    last: index == (tournamentsRecordList.length -1),
                                    tournamentRef: tournament,
                                    active: true,
                                  );
                                },
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
                                .where('involved_list', arrayContains: currentUser?.uid)
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
                                phrase: "Non risultano tornei terminati. Cercane uno e mettiti alla prova!",
                              );
                            }
                            /////////////////////////////////////////
                            ////////////// STANDARD CASE
                            /////////////////////////////////////////
                            return ListView.builder(
                              itemCount: tournamentsRecordList.length,
                              itemBuilder: (context, index) {
                                final tournament = tournamentsRecordList[index];
                                return TournamentCardWidget(
                                  key: Key('Keykia_${tournament.uid}_position_${index}_of_${tournamentsRecordList.length}'),
                                  last: index == (tournamentsRecordList.length -1),
                                  tournamentRef: tournament,
                                  active: false,
                                );
                              },
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
    );
  }
}
