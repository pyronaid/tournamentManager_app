import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';

import '../../app_flow/app_flow_theme.dart';
import 'no_tournament_pick_card_model.dart';

class NoTournamentPickCardWidget extends StatefulWidget {
  const NoTournamentPickCardWidget({
    super.key,
    required this.phrase,
  });

  final String phrase;

  @override
  State<NoTournamentPickCardWidget> createState() => _NoTournamentPickCardWidgetState();
}

class _NoTournamentPickCardWidgetState extends State<NoTournamentPickCardWidget> {
  late NoTournamentPickCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NoTournamentPickCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.all(10),
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).primary,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icons/empty-box.png',
                  height: 30.sp,
                  fit: BoxFit.cover,
                ),
                Flexible(
                  child: Text(
                    widget.phrase,
                    style: CustomFlowTheme.of(context).bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}