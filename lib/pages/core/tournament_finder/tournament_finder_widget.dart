import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../components/no_tournament_pick_card/no_tournament_pick_card_widget.dart';
import '../../../components/tournament_pick_card/tournament_pick_card_widget.dart';

// ---------------------------------------------------------------------------
// Constants — no more magic values scattered across the build method
// ---------------------------------------------------------------------------
class _MapConstants {
  const _MapConstants._();

  static const String tileUrlTemplate = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackageName = 'com.pyronaid.tournamentmanager';
  static const double initialZoom = 13;
  static const double maxClusterZoom = 15;
  static const int maxClusterRadius = 45;
  static const String routeFilterDialog = 'DialogChangeTournamentFinderSettings';
  static const String heroTagRelocate = 'relocate';
  static const String heroTagFilter = 'filter';
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------
class TournamentFinderWidget extends StatefulWidget {
  const TournamentFinderWidget({super.key});

  @override
  State<TournamentFinderWidget> createState() => _TournamentFinderWidgetState();
}

class _TournamentFinderWidgetState extends State<TournamentFinderWidget> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // FIX [warning]: removed the stale _unfocusNode FocusNode pattern.
  // FIX [warning]: removed addPostFrameCallback empty setState.
  // FIX [critical]: model is no longer cached in initState — it is always
  //   accessed through Consumer/context.read at build time to avoid stale refs.

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // FIX [warning]: unfocus via FocusScope directly — no FocusNode needed.
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<TournamentFinderModel>(
        builder: (context, model, _) {
          // FIX [warning]: replaced print() with debugPrint(), gated on
          //   kDebugMode so it is stripped in release builds.
          assert(() {
            debugPrint('[BUILD] tournament_finder_widget.dart');
            return true;
          }());

          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            floatingActionButton: _FabColumn(model: model),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.endTop,
            body: SafeArea(
              top: true,
              // FIX [critical]: panel is always draggable (isDraggable: true).
              // While the panel slides, onPanelSlide drives model.isMapInteractive
              // which wraps the map in AbsorbPointer — preventing the cluster
              // layer from stealing gestures away from the panel drag.
              child: SlidingUpPanel(
                controller: model.panelController,
                isDraggable: true,
                minHeight: 60,         // the visible handle strip height
                maxHeight: MediaQuery.of(context).size.height * 0.70,
                header: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < 0) {
                      model.panelController.open();
                    } else {
                      model.panelController.close();
                    }
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    decoration: BoxDecoration(
                      color: CustomFlowTheme.of(context).primaryBackground,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: CustomFlowTheme.of(context).secondaryText,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                onPanelSlide: (position) => model.setMapInteractive(position == 0.0),
                onPanelClosed: () => model.setMapInteractive(true),
                onPanelOpened: () => model.setMapInteractive(false),
                panel: _PanelContent(model: model),
                body: AbsorbPointer(
                  absorbing: !model.isMapInteractive,
                  child: _MapBody(model: model),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB column — extracted widget
// ---------------------------------------------------------------------------
class _FabColumn extends StatelessWidget {
  const _FabColumn({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: _MapConstants.heroTagRelocate,
          elevation: 4.0,
          backgroundColor: CustomFlowTheme.of(context).primary,
          onPressed: () {
            model.mapController.move(model.initialLocation, _MapConstants.initialZoom);
            model.mapController.rotate(0);
          },
          child: Icon(Icons.my_location, color: CustomFlowTheme.of(context).info),
        ),
        const SizedBox(height: 10),
        FloatingActionButton(
          heroTag: _MapConstants.heroTagFilter,
          elevation: 4.0,
          backgroundColor: CustomFlowTheme.of(context).primary,
          onPressed: () {
            context.goNamed(
              _MapConstants.routeFilterDialog,
              extra: {
                'req': model.showChangeTournamentFinderSettingsAlertRequest(),
              },
            );
          },
          child: Icon(Icons.filter_alt, color: CustomFlowTheme.of(context).info),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sliding panel content — extracted widget
// ---------------------------------------------------------------------------
class _PanelContent extends StatelessWidget {
  const _PanelContent({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    if (model.tournamentsListRefObjToDetail.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: NoTournamentPickCardWidget(
          phrase: 'Non risultano tornei in questa zona.',
        ),
      );
    }

    return ListView.builder(
      controller: model.scrollController,
      padding: const EdgeInsets.only(top: 60),
      itemCount: model.tournamentsListRefObjToDetail.length,
      itemBuilder: (context, index) {
        final trnmt = model.tournamentsListRefObjToDetail[index];
        return TournamentPickCardWidget(
          key: Key(
            'Keykia_${trnmt.uid}_position_${index}_of_'
                '${model.tournamentsListRefObjToDetail.length}',
          ),
          tournamentRef: trnmt,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Map body — extracted widget
// ---------------------------------------------------------------------------
class _MapBody extends StatelessWidget {
  const _MapBody({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    // FIX [design]: removed redundant SizedBox(width: 100.w) — the
    //   SlidingUpPanel body already fills available width.
    return Column(
      children: [
        Expanded(
          child: FlutterMap(
            mapController: model.mapController,
            options: MapOptions(
              initialCenter: model.initialLocation,
              initialZoom: _MapConstants.initialZoom,
              initialRotation: 0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onPositionChanged: (position, hasGesture) {
                model.refreshSearchByTap(position);
              },
              onMapReady: () => model.populateListToDet(),
            ),
            children: [
              TileLayer(
                urlTemplate: _MapConstants.tileUrlTemplate,
                userAgentPackageName: _MapConstants.userAgentPackageName,
              ),
              _UserLocationMarkerLayer(model: model),
              _TournamentClusterLayer(model: model),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// User location marker layer — extracted widget
// ---------------------------------------------------------------------------
class _UserLocationMarkerLayer extends StatelessWidget {
  const _UserLocationMarkerLayer({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: model.initialLocation,
          width: 80,
          height: 80,
          child: Icon(
            Icons.location_pin,
            color: CustomFlowTheme.of(context).markerUser,
            size: 40,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tournament cluster layer — extracted widget
// Business logic (gradient computation) is now fully in the model.
// ---------------------------------------------------------------------------
class _TournamentClusterLayer extends StatelessWidget {
  const _TournamentClusterLayer({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: _MapConstants.maxClusterRadius,
        size: const Size(40, 40),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(50),
        maxZoom: _MapConstants.maxClusterZoom,
        markers: [
          for (final to in model.tournamentsListRefObj)
            CustomMarker(
              point: LatLng(to.latitude, to.longitude),
              width: 60,
              height: 60,
              game: to.game,
              child: to.game.iconResource != null
                  ? InkWell(
                onTap: () => model.onMarkerTap(to.uid),
                child: Image.asset(
                  to.game.iconResource!,
                  width: 40,
                  height: 40,
                ),
              )
                  : IconButton(
                icon: Icon(
                  Icons.tour,
                  color: CustomFlowTheme.of(context).markerTournament,
                  size: 40,
                ),
                onPressed: () => model.onMarkerTap(to.uid),
              ),
            ),
        ],
        // FIX [critical]: builder is now a thin UI layer — all gradient
        //   computation is delegated to the model method.
        builder: (context, markers) {
          // FIX [warning]: off-by-one in stops is fixed inside the model.
          final gradientData = model.buildClusterGradient(markers);

          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: SweepGradient(
                stops: gradientData.stops,
                colors: gradientData.colors,
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
                  style: TextStyle(
                    color: CustomFlowTheme.of(context).info,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}


