import 'package:flutter/material.dart';
import 'package:tournamentmanager/backend/schema/rankings_record.dart';
import 'package:tournamentmanager/components/tournament_ranking_card/tournament_ranking_card_model.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/app_flow_theme.dart';

class TournamentRankingsCardWidget extends StatefulWidget {

  const TournamentRankingsCardWidget({
    super.key,
    required this.rankingRef,
    required this.indexo,
  });

  final RankingsRecord? rankingRef;
  final int indexo;

  @override
  State<TournamentRankingsCardWidget> createState() => _TournamentRankingsCardWidgetState();
}

class _TournamentRankingsCardWidgetState extends State<TournamentRankingsCardWidget> {
  late TournamentRankingsCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentRankingsCardModel());

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
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
      child: ClipRRect(
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
                    alignment: Alignment.center,
                    child: Text(
                      (widget.indexo + 1).toString(),
                      style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 5,
                  fit: FlexFit.tight,
                  child: Container(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.rankingRef!.userName} ${widget.rankingRef!.userSurname}',
                            style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                            softWrap: true,
                          ),
                          Text(
                            widget.rankingRef!.userUsername,
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
                    child: Text(
                      (widget.rankingRef!.points).toString(),
                      style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      (widget.rankingRef!.t1).toString(),
                      style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      (widget.rankingRef!.t2).toString(),
                      style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  fit: FlexFit.loose,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      (widget.rankingRef!.t3).toString(),
                      style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                      softWrap: true,
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
