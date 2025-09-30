import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/tournament_pairing_card/tournament_pairing_card_model.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../backend/schema/pairings_record.dart';
import '../../backend/schema/rounds_record.dart';

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
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ValueKey(widget.indexo),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context){
                context.goNamed(
                    'DialogDeletePairing',
                    pathParameters: {
                      'tournamentId': widget.pairingRef!.tournamentId,
                    }.withoutNulls,
                    extra: {
                      'req' : _model.showDeletePairingAlertRequest(widget.pairingRef!.uid),
                    }
                );
              },
              backgroundColor: CustomFlowTheme.of(context).error,
              foregroundColor: CustomFlowTheme.of(context).info,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          width: 1000,
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).tertiary,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight, // Makes it behave like Expanded
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/icons/versus.png',
                        width: 20.w,
                        height: 20.w,
                        fit: BoxFit.cover,
                      ),
                      Text(
                        widget.pairingRef!.roundKind.desc,
                        style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                        softWrap: true,
                      ),
                      Text(
                        widget.pairingRef!.roundKind == RoundKind.topcut ?
                        "CUT ${widget.pairingRef!.size}" :
                        "ROUND ${widget.pairingRef!.index}",
                        style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            widget.pairingRef!.completed ?
                              'assets/images/icons/completed.png' :
                              'assets/images/icons/ongoing.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.pairingRef!.completed ?
                              "Completato" :
                              "In corso",
                              style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/player.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Giocatori del round : ${widget.pairingRef!.size}",
                              style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                              maxLines: null,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/icons/round.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Pairing completati : ${widget.pairingRef!.matchCompleted} / ${widget.pairingRef!.matchAll}",
                              style: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).cardMain),
                              maxLines: null,
                              softWrap: true,
                            ),
                          ),
                        ],
                      )
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