import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/tournament_round_card/tournament_rounds_card_model.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../backend/schema/rounds_record.dart';

class TournamentRoundsCardWidget extends StatefulWidget {

  const TournamentRoundsCardWidget({
    super.key,
    required this.roundRef,
    required this.indexo,
    required this.deleteFun,
  });

  final RoundsRecord? roundRef;
  final int indexo;
  final Future<void> Function(String roundId) deleteFun;

  @override
  State<TournamentRoundsCardWidget> createState() => _TournamentRoundCardWidgetState();
}

class _TournamentRoundCardWidgetState extends State<TournamentRoundsCardWidget> {
  late TournamentRoundsCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentRoundsCardModel(widget.deleteFun, widget.roundRef!.uid));

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
                    'DialogDeleteRound',
                    pathParameters: {
                      'tournamentId': widget.roundRef!.tournamentId,
                    }.withoutNulls,
                    extra: {
                      'req' : _model.showDeleteNewsAlertRequest(widget.roundRef!.uid),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    widget.roundRef!.completed ? "Completato" : "In Corso",
                    style: CustomFlowTheme.of(context).bodyMicro.override(color: CustomFlowTheme.of(context).cardDetail),
                  )
                ),
                const SizedBox(height: 10),
                Text(
                  widget.roundRef!.roundKind == RoundKind.topcut ? "${widget.roundRef!.roundKind.desc} ${widget.roundRef!.population}" : "${widget.roundRef!.roundKind.desc} ${widget.roundRef!.index}",
                  style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).cardMain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}