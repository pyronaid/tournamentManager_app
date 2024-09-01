import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';

class TournamentNewsWidget extends StatefulWidget {
  const TournamentNewsWidget({super.key});

  @override
  State<TournamentNewsWidget> createState() => _TournamentNewsWidgetState();
}


class _TournamentNewsWidgetState extends State<TournamentNewsWidget> with TickerProviderStateMixin {

  late TournamentNewsModel tournamentNewsModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentNewsModel = context.read<TournamentNewsModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<NewsRecord> tournamentNews = context.select((TournamentNewsModel i) => i.tournamentNews);

    return GestureDetector(
      onTap: () => tournamentNewsModel.unfocusNode.canRequestFocus
      ? FocusScope.of(context).requestFocus(tournamentNewsModel.unfocusNode)
      : FocusScope.of(context).unfocus(),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: CustomFlowTheme.of(context).primaryBackground,
          body: SafeArea(
          top: true,
          child:  SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(tournamentNewsModel.tournamentNews.isEmpty)
                  Center(
                      child: Text("miao")
                  )
                else
                  Text("data")
              ],
            ),
          ),
        ),
        ),
    );
  }
}


//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////// FUNCTIONS
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
