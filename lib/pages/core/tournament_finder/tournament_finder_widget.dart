import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/components/tournament_pick_card/tournament_pick_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';
import 'package:very_good_infinite_list/very_good_infinite_list.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../backend/schema/tournaments_record.dart';

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
                    tournamentFinderModel.showChangeTournamentCapacityDialog();
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
                panel: Column(
                  children: List.generate(providerTournamentFinder.tournamentsListRefObj.length, (index) {
                    final trnmt = providerTournamentFinder.tournamentsListRefObj[index];
                    return TournamentPickCardWidget(
                      key: Key('Keykia_${trnmt.uid}_position_${index}_of_${providerTournamentFinder.tournamentsListRefObj.length}'),
                      tournamentRef: trnmt,
                    );
                  }),
                ),
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
                                  tournamentFinderModel.refreshSearchByTap(position);
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
                                        CustomMarker(
                                          point: LatLng(to.latitude, to.longitude),
                                          width: 60,
                                          height: 60,
                                          game: to.game!,
                                          child: to.game!.iconResource != null ?
                                            Image.asset(
                                              to.game!.iconResource!,
                                              width: 40,
                                              height: 40,
                                            ) :
                                            Icon(
                                              Icons.tour,
                                              color: CustomFlowTheme.of(context).markerTournament,
                                              size: 40,
                                            ),
                                        ),
                                      ],
                                    ],
                                    builder: (context, markers) {
                                      List<Color> colors = [];
                                      List<double> stops = [0.0];
                                      final Map<Game, double> percentageMap = markers.map((m) => (m as CustomMarker).game)
                                        .fold<Map<Game, double>>(
                                          {}, (map, game) =>  map..update(
                                            game,
                                            (count) => count + 1,
                                            ifAbsent: () => 1,
                                          )
                                        );
                                      for (var entry in percentageMap.entries) {
                                        int index=1;
                                        Game game = entry.key;
                                        double value = entry.value;
                                        colors.add(game.color);
                                        colors.add(game.color);

                                        if(index != percentageMap.keys.length){
                                          double toAdd = (stops.last + value)/markers.length;
                                          stops.add(toAdd);
                                          stops.add(toAdd);
                                        } else {
                                          stops.add(1);
                                        }
                                        index++;
                                      }
                                      return Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            gradient: SweepGradient(
                                              stops: stops,
                                              colors: colors,
                                            ),
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.all(7),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(35),
                                              color: CustomFlowTheme.of(context).primary,
                                            ),
                                            width: 70,
                                            height: 70,
                                            child: Center(
                                              child: Text(
                                                markers.length.toString(),
                                                style: TextStyle(color: CustomFlowTheme.of(context).info),
                                              ),
                                            ),
                                          )
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