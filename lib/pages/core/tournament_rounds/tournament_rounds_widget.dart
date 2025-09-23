import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';

import '../../../backend/schema/rounds_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_tournament_round_card/no_tournament_rounds_card_widget.dart';
import '../../../components/tournament_round_card/tournament_rounds_card_widget.dart';


class TournamentRoundsWidget extends StatefulWidget {
  const TournamentRoundsWidget({super.key});

  @override
  State<TournamentRoundsWidget> createState() => _TournamentRoundsWidgetState();
}


class _TournamentRoundsWidgetState extends State<TournamentRoundsWidget> {

  late TournamentRoundsModel tournamentRoundsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentRoundsModel = context.read<TournamentRoundsModel>();
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
      child: Consumer<TournamentRoundsModel>(
          builder: (context, providerTournamentRounds, _) {
            print("[BUILD IN CORSO] tournament_rounds_widget.dart");
            if (providerTournamentRounds.isLoading) {
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
              floatingActionButton: providerTournamentRounds.isTournamentOngoing ? FabExpandableWidget(
                distance: 60,
                children: providerTournamentRounds.buildFabActions(context),
              ) : null,
              body: SafeArea(
                top: true,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await providerTournamentRounds.onRefresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                      ////////////////
                      //ROUNDS SECTION HEADER
                      /////////////////


                      ////////////////
                      //ROUNDS SECTION INF LIST
                      /////////////////
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        sliver: PagedSliverList<int, RoundsRecord>(
                          pagingController: providerTournamentRounds.pagingControllerRounds,
                          builderDelegate: PagedChildBuilderDelegate<RoundsRecord>(
                            itemBuilder: (context, item, index) => TournamentRoundsCardWidget(
                              key: Key('Keykia_${item.uid}_position_${index}_of_rounds'),
                              //last: index == (providerMyTournaments.pagingControllerActive.itemList!.length - 1),
                              roundRef: item,
                              indexo: index,
                              deleteFun: (roundsId) => providerTournamentRounds.deleteRound(roundsId),
                            ),
                            firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                            noItemsFoundIndicatorBuilder: (_) => const NoTournamentRoundsCardWidget(
                              active: true,
                              phrase: "Nessun round pubblicato",
                            ),
                            newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                          ),
                          shrinkWrapFirstPageIndicators: true,
                        ),
                      ),

                      ////////////////
                      //ROUNDS SECTION END
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