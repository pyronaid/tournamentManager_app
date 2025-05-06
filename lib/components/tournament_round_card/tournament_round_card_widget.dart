

import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/components/tournament_round_card/tournament_round_card_model.dart';

import '../../app_flow/app_flow_model.dart';
import '../../backend/schema/rounds_record.dart';

class TournamentRoundCardWidget extends StatefulWidget {

  const TournamentRoundCardWidget({
    super.key,
    required this.roundRef,
    required this.indexo,
  });

  final RoundsRecord? roundRef;
  final int indexo;

  @override
  State<TournamentRoundCardWidget> createState() => _TournamentRoundCardWidgetState();
}

class _TournamentRoundCardWidgetState extends State<TournamentRoundCardWidget> {
  late TournamentRoundCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(
        context, () => TournamentRoundCardModel(widget.roundRef!.uid));

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Text("data"),
    );
  }
}