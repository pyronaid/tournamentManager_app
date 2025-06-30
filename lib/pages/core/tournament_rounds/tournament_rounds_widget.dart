import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';

import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../../components/no_tournament_round_card/no_tournament_round_card_widget.dart';
import '../../../components/tournament_round_card/tournament_round_card_widget.dart';
import '../../nav_bar/rounds_list_model.dart';


class TournamentRoundsWidget extends StatefulWidget {
  const TournamentRoundsWidget({super.key});

  @override
  State<TournamentRoundsWidget> createState() => _TournamentRoundsWidgetState();
}


class _TournamentRoundsWidgetState extends State<TournamentRoundsWidget> {

  late TournamentRoundsModel tournamentRoundsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentRoundsModel = context.read<TournamentRoundsModel>();
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
      child: Consumer<RoundListModel>(
          builder: (context, providerRoundList, _) {
            print("[BUILD IN CORSO] tournament_rounds_widget.dart");
            if (providerRoundList.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomFlowTheme.of(context).primaryBackground,
              floatingActionButton: providerRoundList.isTournamentOngoing ? FabExpandableWidget(
                distance: 60,
                children: [
                  if(!providerRoundList.hasAnyTopCutRound && !providerRoundList.hasWinner) ...[
                    //SVIZZERA
                    ActionButton(
                      onPressed: () {
                        print("ciiii");
                      },
                      icon: Icons.casino,
                      title: " Genera round di svizzera ",
                    ),
                  ],
                  if(!providerRoundList.hasWinner) ...[
                    //TOP CUT
                    ActionButton(
                      onPressed: () {
                        print("ciiii");
                      },
                      icon: Icons.sports,
                      title: " Genera round top cut ",
                    ),
                  ],
                ],
              ) : null,
              body: SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 100.w,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(providerRoundList.roundListRefObj.isEmpty)
                            const NoTournamentRoundCardWidget(
                              active: true,
                              phrase: "Nessun round pubblicato",
                            )
                          else
                            Column(
                              children: List.generate(providerRoundList.roundListRefObj.length, (index) {
                                final round = providerRoundList.roundListRefObj[index];
                                return TournamentRoundCardWidget(
                                  key: Key('Keykia_${round.uid}_position_${index}_of_${providerRoundList.roundListRefObj.length}'),
                                  roundRef: round,
                                  indexo: index,
                                );
                              },),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}