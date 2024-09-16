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
import '../../../components/no_tournament_news_card/no_tournament_news_card_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentNewsWidget extends StatefulWidget {
  const TournamentNewsWidget({super.key});

  @override
  State<TournamentNewsWidget> createState() => _TournamentNewsWidgetState();
}


class _TournamentNewsWidgetState extends State<TournamentNewsWidget> with TickerProviderStateMixin {

  late TournamentNewsModel tournamentNewsModel;
  late TournamentModel tournamentModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentModel = context.read<TournamentModel>();
    tournamentNewsModel = context.read<TournamentNewsModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tournamentNewsModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(tournamentNewsModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentModel>(
        builder: (context, providerTournament, _) {
          print("[REBUILD IN CORSO] tournament_news_widget.dart");
          if (tournamentModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            floatingActionButton: FloatingActionButton.extended(
              elevation: 4.0,
              icon: Icon(
                Icons.add,
                color: CustomFlowTheme.of(context).info,
              ),
              label: Text(
                'Crea una nuova notizia',
                style: CustomFlowTheme.of(context).titleSmall,
              ),
              backgroundColor: CustomFlowTheme.of(context).primary,
              onPressed: () {
                context.pushNamedAuth(
                  'CreateEditNews', context.mounted,
                  pathParameters: {
                    'newsId': 'NEW',
                  }.withoutNulls,
                  extra: {
                    'tournamentId': providerTournament.tournamentId,
                    'createEditFlag': true,
                  },
                );
              },
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation
                .centerDocked,
            body: SafeArea(
              top: true,
              child: SingleChildScrollView(
                child: Container(
                  width: 100.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if(tournamentModel.tournamentNews.isEmpty)
                        const NoTournamentNewsCardWidget(
                          active: true,
                          phrase: "Nessuna notizia pubblicata",
                        )
                      else
                        Text("£asasasas")

                    ],
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}


//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////// FUNCTIONS
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
