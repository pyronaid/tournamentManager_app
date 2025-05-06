import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:tournamentmanager/components/no_tournament_card/no_tournament_card_widget.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_widget.dart';
import 'package:tournamentmanager/pages/core/my_tournaments/my_tournaments_model.dart';


class MyTournamentsWidget extends StatefulWidget {
  const MyTournamentsWidget({super.key});

  @override
  State<MyTournamentsWidget> createState() => _MyTournamentsWidgetState();
}


class _MyTournamentsWidgetState extends State<MyTournamentsWidget> {
  late MyTournamentsModel myTournamentsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'My_Tournaments'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    myTournamentsModel = context.read<MyTournamentsModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => myTournamentsModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(myTournamentsModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Consumer<MyTournamentsModel>(
              builder: (context, providerMyTournaments, _){
                if(providerMyTournaments.isLoading){
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await providerMyTournaments.onRefresh();
                  },
                  child: CustomScrollView(
                    slivers: [
                      // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                      ////////////////
                      //ACTIVE SECTION HEADER
                      /////////////////
                      SliverAppBar(
                          pinned: true,
                          snap: false,
                          floating: false,
                          expandedHeight: 100.0,
                          collapsedHeight: 70.0,
                          backgroundColor: CustomFlowTheme.of(context).secondary,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              'ATTIVI/FUTURI',
                              style: CustomFlowTheme.of(context).headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            expandedTitleScale: 1,
                            titlePadding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 30),
                            centerTitle: true,
                          ),
                          actions: <Widget>[
                            IconButton(
                              icon: providerMyTournaments.showActiveTournaments ? const Icon(Icons.remove_circle) : const Icon(Icons.add_circle),
                              tooltip: providerMyTournaments.showActiveTournaments ? 'Hide' : 'Show',
                              onPressed: () { providerMyTournaments.switchShowActiveTournaments(); },
                            ),
                          ]
                      ),

                      ////////////////
                      //ACTIVE SECTION INF LIST
                      /////////////////
                      if(providerMyTournaments.showActiveTournaments) ...[
                        PagedSliverList<String?, TournamentsRecord>(
                          pagingController: providerMyTournaments.pagingControllerActive,
                          builderDelegate: PagedChildBuilderDelegate<TournamentsRecord>(
                            itemBuilder: (context, item, index) => TournamentCardWidget(
                              key: Key('Keykia_${item.uid}_position_${index}_of_active'),
                              last: index == (providerMyTournaments.pagingControllerActive.itemList!.length - 1),
                              tournamentRef: item,
                              active: true,
                            ),
                            firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                            noItemsFoundIndicatorBuilder: (_) => const NoTournamentCardWidget(
                              active: false,
                              phrase: "Non risultano tornei attivi o futuri. Creane uno per gestirlo da qui!",
                            ),
                            newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],

                      ////////////////
                      //ACTIVE SECTION END ROUND BOTTOM BOX
                      /////////////////
                      SliverToBoxAdapter(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: CustomFlowTheme.of(context).secondary,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(20.0),
                              bottomRight: Radius.circular(20.0),
                            ),
                          ),
                          child: SizedBox(
                            height: 40,
                            width: 100.w,
                          ),
                        ),
                      ),

                      ////////////////
                      //CLOSED SECTION HEADER
                      /////////////////
                      SliverAppBar(
                          pinned: true,
                          snap: false,
                          floating: false,
                          expandedHeight: 100.0,
                          collapsedHeight: 70.0,
                          backgroundColor: CustomFlowTheme.of(context).primaryBackground,
                          flexibleSpace: FlexibleSpaceBar(
                            title: Text(
                              'TERMINATI',
                              style: CustomFlowTheme.of(context).headlineLarge,
                              textAlign: TextAlign.center,
                            ),
                            expandedTitleScale: 1,
                            titlePadding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 30),
                            centerTitle: true,
                          ),
                          actions: <Widget>[
                            IconButton(
                              icon: providerMyTournaments.showClosedTournaments ? const Icon(Icons.remove_circle) : const Icon(Icons.add_circle),
                              tooltip: providerMyTournaments.showClosedTournaments ? 'Hide' : 'Show',
                              onPressed: () { providerMyTournaments.switchShowClosedTournaments(); },
                            ),
                          ]
                      ),

                      ////////////////
                      //CLOSED SECTION INF LIST
                      /////////////////
                      if(providerMyTournaments.showClosedTournaments) ...[
                        PagedSliverList<String?, TournamentsRecord>(
                          pagingController: providerMyTournaments.pagingControllerClosed,
                          builderDelegate: PagedChildBuilderDelegate<TournamentsRecord>(
                            itemBuilder: (context, item, index) => TournamentCardWidget(
                              key: Key('Keykia_${item.uid}_position_${index}_of_closed'),
                              last: index == (providerMyTournaments.pagingControllerClosed.itemList!.length - 1),
                              tournamentRef: item,
                              active: false,
                            ),
                            firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                            noItemsFoundIndicatorBuilder: (_) => const NoTournamentCardWidget(
                              active: true,
                              phrase: "Non risultano tornei attivi o futuri. Creane uno per gestirlo da qui!",
                            ),
                            newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }
          ),
        ),
      ),
    );
  }
}
