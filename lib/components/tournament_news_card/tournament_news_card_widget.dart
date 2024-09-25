import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_model.dart';

import '../../app_flow/app_flow_animations.dart';
import '../../app_flow/app_flow_theme.dart';
import '../standard_graphics/standard_graphics_widgets.dart';

class TournamentNewsCardWidget extends StatefulWidget {
  const TournamentNewsCardWidget({
    super.key,
    required this.newsRef,
  });

  final NewsRecord? newsRef;

  @override
  State<TournamentNewsCardWidget> createState() => _TournamentNewsCardWidgetState();
}

class _TournamentNewsCardWidgetState extends State<TournamentNewsCardWidget> with TickerProviderStateMixin {
  late TournamentNewsCardModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentNewsCardModel());

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
    return Text("data");
  }
}
