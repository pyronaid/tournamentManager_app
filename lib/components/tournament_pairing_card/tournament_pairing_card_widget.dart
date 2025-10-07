import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/tournament_pairing_card/tournament_pairing_card_model.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../backend/schema/pairings_record.dart';

class TournamentPairingsCardWidget extends StatefulWidget {

  const TournamentPairingsCardWidget({
    super.key,
    required this.pairingRef,
    required this.indexo,
    required this.deleteFun,
  });

  final PairingsRecord? pairingRef;
  final int indexo;
  final Future<void> Function(String roundId) deleteFun;

  @override
  State<TournamentPairingsCardWidget> createState() => _TournamentPairingsCardWidgetState();
}

class _TournamentPairingsCardWidgetState extends State<TournamentPairingsCardWidget> {
  late TournamentPairingsCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentPairingsCardModel(widget.deleteFun, widget.pairingRef!.uid));

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        child: Container(
          width: 1000,
          color: CustomFlowTheme.of(context).tertiary,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0), bottomRight: Radius.circular(10.0)),
                      color: widget.pairingRef!.completed
                          ? CustomFlowTheme.of(context).completed
                          : CustomFlowTheme.of(context).ongoing,
                    ),
                    width: 15,
                    height: 100,
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(5, 15, 5, 15),
                      child: Image.asset(
                        widget.pairingRef!.playerAWon ?
                          'assets/images/icons/playerWin.png':
                          'assets/images/icons/playerLose.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOME',
                            style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            widget.pairingRef!.namePlayerA,
                            style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            'COGN.',
                            style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            widget.pairingRef!.surnamePlayerA,
                            style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(5, 15, 5, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: Image.asset(
                                  'assets/images/icons/table.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Text(
                                  " ${widget.pairingRef!.tableIndex}",
                                  style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          if (widget.pairingRef!.dropPlayerA || widget.pairingRef!.dropPlayerB) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.dropPlayerA ?
                                    Image.asset(
                                      'assets/images/icons/dropped.png',
                                      fit: BoxFit.cover,
                                    ) :
                                    const SizedBox(
                                    ),
                                ),
                                const Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: SizedBox(
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.dropPlayerB ?
                                    Image.asset(
                                      'assets/images/icons/dropped.png',
                                      fit: BoxFit.cover,
                                    ) :
                                    const SizedBox(
                                    ),
                                ),
                              ],
                            ),
                          ],
                          if (widget.pairingRef!.isBye) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.playerAWon ?
                                    Image.asset(
                                      'assets/images/icons/bye.png',
                                      fit: BoxFit.cover,
                                    ) :
                                    const SizedBox(
                                    ),
                                ),
                                const Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: SizedBox(
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.playerBWon ?
                                    Image.asset(
                                      'assets/images/icons/bye.png',
                                      fit: BoxFit.cover,
                                    ) :
                                    const SizedBox(
                                    ),
                                ),
                              ],
                            ),
                          ],
                          if (widget.pairingRef!.noShow) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.playerAWon ?
                                    const SizedBox(
                                    ) :
                                    Image.asset(
                                      'assets/images/icons/noshow.png',
                                      fit: BoxFit.cover,
                                    ),
                                ),
                                const Flexible(
                                  flex: 1,
                                  fit: FlexFit.tight,
                                  child: SizedBox(
                                  ),
                                ),
                                Flexible(
                                  flex: 2,
                                  fit: FlexFit.tight,
                                  child: widget.pairingRef!.playerBWon ?
                                    const SizedBox(
                                    ) :
                                    Image.asset(
                                      'assets/images/icons/noshow.png',
                                      fit: BoxFit.cover,
                                    ),
                                ),
                              ],
                            ),
                          ]
                        ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'NOME',
                            style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            widget.pairingRef!.namePlayerB,
                            style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            'COGN.',
                            style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            widget.pairingRef!.surnamePlayerB,
                            style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(5, 15, 5, 15),
                      child: Image.asset(
                        widget.pairingRef!.playerBWon ?
                        'assets/images/icons/playerWin.png':
                        'assets/images/icons/playerLose.png',
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),

                /*
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose, // Makes it behave like Expanded
                  child: Container(
                    color: Colors.white, // Your background color
                    alignment: Alignment.center,
                    child: Text(
                      'A',
                      style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight, // Makes it behave like Expanded
                  child: Image.asset(
                    'assets/images/icons/playerA.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose, // Allows shrinking if content is smaller
                  child: Column(
                    children: [
                      Text(
                        "NOME: temp",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                      Text(
                        "COGNOME: temp",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose, // Allows shrinking if content is smaller
                  child: Column(
                    children: [
                      Text(
                        "T: X",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                      Text(
                        "VS",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose, // Allows shrinking if content is smaller
                  child: Column(
                    children: [
                      Text(
                        "NOME: temp",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                      Text(
                        "COGNOME: temp",
                        style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight, // Makes it behave like Expanded
                  child: Image.asset(
                    'assets/images/icons/playerB.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.cover,
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}