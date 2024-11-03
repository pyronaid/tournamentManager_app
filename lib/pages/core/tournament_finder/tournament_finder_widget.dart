import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../components/no_tournament_news_card/no_tournament_news_card_widget.dart';
import '../../../components/tournament_news_card/tournament_news_card_widget.dart';
import '../../nav_bar/tournament_model.dart';

class TournamentFinderWidget extends StatefulWidget {
  const TournamentFinderWidget({super.key});

  @override
  State<TournamentFinderWidget> createState() => _TournamentFinderWidgetState();
}


class _TournamentFinderWidgetState extends State<TournamentFinderWidget> {

  late TournamentFinderModel tournamentFinderModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentFinderModel = context.read<TournamentFinderModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tournamentFinderModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(tournamentFinderModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentFinderModel>(
        builder: (context, providerTournamentFinder, _) {
          print("[BUILD IN CORSO] tournament_finder_widget.dart");
          if (tournamentFinderModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            floatingActionButton: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'relocate',
                  elevation: 4.0,
                  backgroundColor: CustomFlowTheme.of(context).primary,
                  onPressed: () async {
                    LatLng initpos = await tournamentFinderModel.initialLocation;
                    tournamentFinderModel.mapController.move(initpos, 13);
                    tournamentFinderModel.mapController.rotate(0);
                  },
                  child: Icon(
                    Icons.my_location,
                    color: CustomFlowTheme.of(context).info,
                  ),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'filter',
                  elevation: 4.0,
                  backgroundColor: CustomFlowTheme.of(context).primary,
                  onPressed: () async {
                    LatLng initpos = await tournamentFinderModel.initialLocation;
                    tournamentFinderModel.mapController.move(initpos, 13);
                    tournamentFinderModel.mapController.rotate(0);
                  },
                  child: Icon(
                    Icons.filter_alt,
                    color: CustomFlowTheme.of(context).info,
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            body: SafeArea(
              top: true,
              child: SlidingUpPanel(
                panel: const Center(child: Text("data"),),
                body: Container(
                  width: 100.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ///##################################
                            ///###################FLUTTER MAP WIDGET
                            ///##################################
                            FlutterMap(
                              mapController: tournamentFinderModel.mapController,
                              options: MapOptions(
                                initialCenter: tournamentFinderModel.initialLocation,
                                initialZoom: 13,
                                initialRotation: 0,
                                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                                onPositionChanged: (position, hasGesture) {
                                  tournamentFinderModel.refreshSearch(position);
                                },
                              ),
                              children: [
                                ///##################################
                                ///################### MAP SOURCE
                                ///##################################
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.pyronaid.tournament_manager',
                                ),
                                ///##################################
                                ///################### MARKERS SOURCE
                                ///##################################
                                MarkerLayer(
                                  markers: [
                                    //MARKER POSIZIONE INIZIALE
                                    Marker(
                                      point: tournamentFinderModel.initialLocation,
                                      width: 80,
                                      height: 80,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: CustomFlowTheme.of(context).markerUser,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                                MarkerClusterLayerWidget(
                                  options: MarkerClusterLayerOptions(
                                    maxClusterRadius: 45,
                                    size: const Size(40, 40),
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.all(50),
                                    maxZoom: 15,
                                    markers: [
                                      for(var to in tournamentFinderModel.tournamentsListRefObj)...[
                                        Marker(
                                          point: LatLng(to.latitude, to.longitude),
                                          width: 80,
                                          height: 80,
                                          child: Icon(
                                            Icons.tour,
                                            color: CustomFlowTheme.of(context).markerTournament,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ],
                                    builder: (context, markers) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: CustomFlowTheme.of(context).primary),
                                        child: Center(
                                          child: Text(
                                            markers.length.toString(),
                                            style: TextStyle(color: CustomFlowTheme.of(context).info),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
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