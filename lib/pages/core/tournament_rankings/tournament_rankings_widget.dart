import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_model.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../backend/schema/rankings_record.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_tournament_ranking_card/no_tournament_rankings_card_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../components/tournament_ranking_card/tournament_ranking_card_widget.dart';


class TournamentRankingsWidget extends StatefulWidget {
  const TournamentRankingsWidget({super.key});

  @override
  State<TournamentRankingsWidget> createState() => _TournamentRankingsWidgetState();
}


class _TournamentRankingsWidgetState extends State<TournamentRankingsWidget> {

  late TournamentRankingsModel tournamentRankingsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentRankingsModel = context.read<TournamentRankingsModel>();
    tournamentRankingsModel.initContextVars(context);
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentRankingsModel>(
          builder: (context, providerTournamentRankings, _) {
            print("[BUILD IN CORSO] tournament_rankings_widget.dart");
            if (providerTournamentRankings.isLoading) {
              return Scaffold(
                key: _scaffoldKey,
                backgroundColor: CustomFlowTheme.of(context).primaryBackground,
                body: const SafeArea(
                  top: true,
                  child: SingleChildScrollView(
                      child: Center(child: CircularProgressIndicator())
                  ),
                ),
              );
            }

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomFlowTheme.of(context).primaryBackground,
              body: SafeArea(
                top: true,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await providerTournamentRankings.onRefresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                      ////////////////
                      //Rankings SECTION HEADER
                      /////////////////
                      SliverAppBar(
                        automaticallyImplyLeading: false,
                        pinned: true,
                        snap: false,
                        floating: false,
                        expandedHeight: 250.0,
                        collapsedHeight: 250.0,
                        backgroundColor: CustomFlowTheme.of(context).secondary,
                        flexibleSpace: Padding(
                          padding: const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 15),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              wrapWithModel(
                                model: providerTournamentRankings.customAppbarModel,
                                updateCallback: () => setState(() {}),
                                child: CustomAppbarWidget(
                                  backButton: true,
                                  actionButton: false,
                                  actionButtonAction: () async {},
                                  optionsButtonAction: () async {},
                                ),
                              ),
                              ////////////////
                              //PAGE TITLE
                              /////////////////
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
                                child: Text(
                                  'Ranking',
                                  style: CustomFlowTheme.of(context).displaySmall,
                                ),
                              ),
                              ////////////////
                              //research box
                              /////////////////
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 65.w,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 5),
                                      child: TextField(
                                        controller: providerTournamentRankings.playerNameTextController,
                                        focusNode: providerTournamentRankings.playerNameFocusNode,
                                        autofocus: false,
                                        obscureText: false,
                                        decoration: standardInputDecoration(
                                          context,
                                          prefixIcon: Icon(
                                            Icons.person,
                                            color: CustomFlowTheme.of(context).secondaryText,
                                            size: 18,
                                          ),
                                        ),
                                        style: CustomFlowTheme.of(context).bodyLarge.override(
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1,
                                        ),
                                        minLines: 1,
                                        cursorColor: CustomFlowTheme.of(context).primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      ////////////////
                      //Rankings SECTION INF LIST
                      /////////////////
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        sliver: PagedSliverList<int, RankingsRecord>(
                          pagingController: providerTournamentRankings.pagingControllerRankings,
                          builderDelegate: PagedChildBuilderDelegate<RankingsRecord>(
                            itemBuilder: (context, item, index) => TournamentRankingsCardWidget(
                              key: Key('Keykia_${item.uid}_position_${index}_of_rankings'),
                              //last: index == (providerMyTournaments.pagingControllerActive.itemList!.length - 1),
                              rankingRef: item,
                              indexo: index,
                            ),
                            firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                            noItemsFoundIndicatorBuilder: (_) => const NoTournamentRankingsCardWidget(
                              active: true,
                              phrase: "Nessun player in classifica",
                            ),
                            newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                          ),
                          shrinkWrapFirstPageIndicators: true,
                        ),
                      ),

                      ////////////////
                      //Rankings SECTION END
                      /////////////////
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 100,
                          width: 100.w,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}