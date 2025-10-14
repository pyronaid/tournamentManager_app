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
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
        ),
        child: Container(
          width: 1000,
          color: CustomFlowTheme.of(context).tertiaryDark,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(10),
                child: Text('data'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}