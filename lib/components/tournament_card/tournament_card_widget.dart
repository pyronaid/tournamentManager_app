import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_model.dart';

import '../../app_flow/app_flow_animations.dart';
import '../../app_flow/app_flow_model.dart';
import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/nav/serialization_util.dart';
import '../../backend/firebase_analytics/analytics.dart';
import '../standard_graphics/standard_graphics_widgets.dart';

class TournamentCardWidget extends StatefulWidget {
  const TournamentCardWidget({
    super.key,
    this.tournamentRef,
    required this.last,
    required this.active,
  });

  final TournamentsRecord? tournamentRef;
  final bool last;
  final bool active;

  @override
  State<TournamentCardWidget> createState() => _TournamentCardWidgetState();
}

class _TournamentCardWidgetState extends State<TournamentCardWidget> with TickerProviderStateMixin {
  late TournamentCardModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentCardModel());

    animationsMap.addAll({
      'iconOnPageLoadAnimation': standardAnimationCard(context),
    });

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
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            logFirebaseEvent('TOURNAMENT_CARD_COMP_Column_7nse8gf3_ON_TAP');
            logFirebaseEvent('Column_haptic_feedback');
            HapticFeedback.lightImpact();
            logFirebaseEvent('Column_navigate_to');

            //////////////////////////////
            //////////// REDIRECT ON TAP
            //////////////////////////////
            context.pushNamed(
              'TournamentDetails',
              pathParameters: {
                'tournamentRef': serializeParam(
                  widget.tournamentRef,
                  ParamType.Document,
                ),
              }.withoutNulls,
              extra: <String, dynamic>{
                'tournamentRef': widget.tournamentRef,
              },
            );
          },
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ////////////////
                //DATE
                /////////////////
                SizedBox(
                  width: 15.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                      DateFormat('dd').format(widget.tournamentRef!.date!.toDate()),
                        style: CustomFlowTheme.of(context).titleLarge,
                      ),
                      Text(
                        DateFormat('MM').format(widget.tournamentRef!.date!.toDate()),
                        style: CustomFlowTheme.of(context).bodyMedium,
                      ),
                      Text(
                        DateFormat('yyyy').format(widget.tournamentRef!.date!.toDate()),
                        style: CustomFlowTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
                ////////////////
                //NAME & ADDRESS
                /////////////////
                SizedBox(
                  width: 60.w,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tournamentRef!.name,
                          style: CustomFlowTheme.of(context).bodyMedium,
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          widget.tournamentRef!.address,
                          style: CustomFlowTheme.of(context).labelMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                ////////////////
                //STATE
                /////////////////
                SizedBox(
                  width: 12.w,
                  child: Text(
                    widget.tournamentRef!.state!.name,
                    style: CustomFlowTheme.of(context).bodyMicro,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        //////////////////////////////////////
        //////////// optional divider
        //////////////////////////////////////
        if(!widget.last)
          Divider(
            thickness: 1,
            color: !widget.active ? CustomFlowTheme.of(context).primaryText : CustomFlowTheme.of(context).primary,
            height: 80, // Space around the divider
          ),
      ],
    );
  }
}
