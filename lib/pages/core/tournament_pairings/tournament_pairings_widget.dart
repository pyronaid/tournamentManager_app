import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_model.dart';

import '../../../backend/schema/pairings_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_tournament_pairing_card/no_tournament_pairings_card_widget.dart';
import '../../../components/tournament_pairing_card/tournament_pairing_card_widget.dart';


class TournamentPairingsWidget extends StatefulWidget {
  const TournamentPairingsWidget({super.key});

  @override
  State<TournamentPairingsWidget> createState() => _TournamentPairingsWidgetState();
}


class _TournamentPairingsWidgetState extends State<TournamentPairingsWidget> {

  late TournamentPairingsModel tournamentPairingsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentPairingsModel = context.read<TournamentPairingsModel>();
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
      child: Consumer<TournamentPairingsModel>(
          builder: (context, providerTournamentPairings, _) {
            print("[BUILD IN CORSO] tournament_pairings_widget.dart");
            if (providerTournamentPairings.isLoading) {
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
                    await providerTournamentPairings.onRefresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                      ////////////////
                      //Pairings SECTION HEADER
                      /////////////////


                      ////////////////
                      //Pairings SECTION INF LIST
                      /////////////////
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                        sliver: PagedSliverList<int, PairingsRecord>(
                          pagingController: providerTournamentPairings.pagingControllerPairings,
                          builderDelegate: PagedChildBuilderDelegate<PairingsRecord>(
                            itemBuilder: (context, item, index) => TournamentPairingsCardWidget(
                              key: Key('Keykia_${item.uid}_position_${index}_of_pairings'),
                              //last: index == (providerMyTournaments.pagingControllerActive.itemList!.length - 1),
                              pairingRef: item,
                              indexo: index,
                              deleteFun: (pairingsId) => providerTournamentPairings.deletePairing(pairingsId),
                            ),
                            firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                            noItemsFoundIndicatorBuilder: (_) => const NoTournamentPairingsCardWidget(
                              active: true,
                              phrase: "Nessun pairing pubblicato",
                            ),
                            newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                          ),
                          shrinkWrapFirstPageIndicators: true,
                        ),
                      ),

                      ////////////////
                      //Pairings SECTION END
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