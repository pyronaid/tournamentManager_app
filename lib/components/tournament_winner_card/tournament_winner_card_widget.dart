import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_model.dart';
import 'package:tournamentmanager/components/tournament_winner_card/tournament_winner_card_model.dart';

import '../../backend/schema/enrollments_record.dart';

class TournamentWinnerCardWidget extends StatefulWidget {

  const TournamentWinnerCardWidget({
    super.key,
    required this.name,
    required this.surname,
    required this.username,
    required this.userId,
  });

  final String name;
  final String surname;
  final String username;
  final String userId;

  @override
  State<TournamentWinnerCardWidget> createState() => _TournamentWinnerCardWidgetState();
}

class _TournamentWinnerCardWidgetState extends State<TournamentWinnerCardWidget> {
  late TournamentWinnerCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentWinnerCardModel());

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
              Text(
                widget.username,
                style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).cardMain),
              ),
              Text(
                '${widget.name} ${widget.surname}',
                style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardSecond),
              ),
              Text(
                widget.userId,
                style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
              ),
            ],
          ),
        ),
      ),
    );
  }
}