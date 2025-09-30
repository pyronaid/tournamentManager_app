import 'package:flutter/cupertino.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/app_flow_theme.dart';
import 'no_tournament_pairings_card_model.dart';

class NoTournamentPairingsCardWidget extends StatefulWidget {
  const NoTournamentPairingsCardWidget({
    super.key,
    required this.active,
    required this.phrase,
  });

  final bool active;
  final String phrase;

  @override
  State<NoTournamentPairingsCardWidget> createState() => _NoTournamentPairingsCardWidgetState();
}

class _NoTournamentPairingsCardWidgetState extends State<NoTournamentPairingsCardWidget> {
  late NoTournamentPairingsCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => NoTournamentPairingsCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: widget.active ? CustomFlowTheme.of(context).secondaryBackground : CustomFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/icons/pairing.png',
                      height: 30.sp,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 20,),
                    Flexible(
                      child: Text(
                        widget.phrase,
                        style: widget.active ? CustomFlowTheme.of(context).labelLarge : CustomFlowTheme.of(context).bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ]
              ),
            ),
          ],
        ),
      ),
    );
  }
}