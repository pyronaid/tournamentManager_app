import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
    required this.deepFun,
    required this.editable,
    this.closeFun,
  });

  final RoundsRecord? roundRef;
  final int indexo;
  final Future<void> Function(RoundsRecord round) deleteFun;
  final Future<void> Function(RoundsRecord round)? closeFun;
  final Function(String) deepFun;
  final bool editable;

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
    _model = createModel(context, () => TournamentRoundsCardModel(
        deleteFun: widget.deleteFun,
        closeFun: widget.closeFun,
        roundUid: widget.roundRef!.uid,
        editable: widget.editable,
    ));

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
        key: ValueKey("round${widget.indexo}"),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: widget.editable ? ActionPane(
          motion: const ScrollMotion(),
          children: [
            if(widget.closeFun != null)...[
              SlidableAction(
                onPressed: (context){
                  context.goNamed(
                      'DialogDeleteRound',
                      pathParameters: {
                        'tournamentId': widget.roundRef!.tournamentId,
                      }.withoutNulls,
                      extra: {
                        'req' : _model.showDeleteRoundAlertRequest(widget.roundRef!),
                      }
                  );
                },
                backgroundColor: CustomFlowTheme.of(context).error,
                foregroundColor: CustomFlowTheme.of(context).info,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
            if(widget.closeFun != null)...[
              SlidableAction(
                onPressed: (context){
                  context.goNamed(
                      'DialogCloseTournament',
                      pathParameters: {
                        'tournamentId': widget.roundRef!.tournamentId,
                      }.withoutNulls,
                      extra: {
                        'req' : _model.showCloseTournamentAlertRequest(widget.roundRef!),
                      }
                  );
                },
                backgroundColor: CustomFlowTheme.of(context).completed,
                foregroundColor: CustomFlowTheme.of(context).info,
                icon: Icons.key,
                label: 'Chiudi\nTorneo',
              ),
            ]
          ],
        ): null,
        child: InkWell(
          onTap: (){
            widget.deepFun(widget.roundRef!.uid);
          },
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
                          widget.roundRef!.roundKind == RoundKind.swiss ? 'assets/images/icons/versus.png' : 'assets/images/icons/versus_top.png',
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                        ),
                        Text(
                          widget.roundRef!.roundKind.desc,
                          style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                          softWrap: true,
                        ),
                        Text(
                          widget.roundRef!.roundKind == RoundKind.topcut ?
                          "TOP ${widget.roundRef!.size}" :
                          "ROUND ${widget.roundRef!.index}",
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
                              widget.roundRef!.completed ?
                                'assets/images/icons/completed.png' :
                                'assets/images/icons/ongoing.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.roundRef!.completed ?
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
                                "Giocatori del round : ${widget.roundRef!.size}",
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
                                "Pairing completati : ${widget.roundRef!.matchCompleted} / ${widget.roundRef!.matchAll}",
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
      ),
    );
  }
}