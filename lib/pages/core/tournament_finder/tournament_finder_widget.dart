import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/components/no_content_card/no_content_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_model.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../components/tournament_pick_card/tournament_pick_card_widget.dart';

// ---------------------------------------------------------------------------
// CONSTANTS
//
// Two separate constant classes keep concerns clear:
//   _MapConfig  — non-visual configuration values (URLs, zoom levels, routes)
//   _MapDims    — all dimension / layout values, the single source of truth
//
// Rule: if a number appears more than once, or will be adjusted together with
//       another number (e.g. panelMinHeight and list topPadding), it belongs
//       here — not inline.
// ---------------------------------------------------------------------------

/// Non-visual configuration — tile server, zoom, route names, hero tags.
abstract class _MapConfig {
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackageName =
      'com.pyronaid.tournamentmanager';
  static const double initialZoom      = 13;
  static const double maxClusterZoom   = 15;
  static const int    maxClusterRadius = 45;
  static const String routeFilterDialog = 'DialogChangeTournamentFinderSettings';
  static const String heroTagRelocate  = 'relocate';
  static const String heroTagFilter    = 'filter';
}

/// All dimension values — the single source of truth for every size in
/// this file.  Changing one value here propagates everywhere automatically.
abstract class _MapDims {
  // ── Sliding panel ────────────────────────────────────────────────────────
  /// Visible "handle strip" height.  Also used as the top padding of the
  /// list inside the panel so items are never hidden under the strip.
  static const double panelMinHeight    = 60.0;

  /// Panel max height expressed as a fraction of screen height.
  /// Using a fraction (not a fixed pixel value) keeps the panel proportional
  /// on every device — LayoutBuilder resolves the actual pixels at build time.
  static const double panelMaxHeightFraction = 0.70;

  /// Corner radius of the panel's top edge.
  static const double panelBorderRadius = 16.0;

  // ── Handle pill ──────────────────────────────────────────────────────────
  static const double handleWidth  = 40.0;
  static const double handleHeight = 4.0;
  static const double handleRadius = 2.0;

  // ── FAB column ───────────────────────────────────────────────────────────
  static const double fabSpacing   = 10.0;
  static const double fabTopOffset = 10.0;

  // ── User location marker ─────────────────────────────────────────────────
  static const double userMarkerSize  = 80.0;
  static const double userIconSize    = 40.0;

  // ── Tournament marker ────────────────────────────────────────────────────
  static const double tournamentMarkerSize = 60.0;
  static const double tournamentIconSize   = 40.0;

  // ── Cluster bubble ───────────────────────────────────────────────────────
  /// Outer ring diameter (the sweep-gradient ring).
  static const double clusterOuterSize   = 80.0;
  static const double clusterOuterRadius = clusterOuterSize / 2; // 40

  /// Inner bubble diameter (the solid coloured disc with the count).
  static const double clusterInnerSize   = 70.0;
  static const double clusterInnerRadius = clusterInnerSize / 2; // 35

  /// Margin between the outer ring and the inner bubble.
  /// = (outerSize - innerSize) / 2  →  keeps the bubble centred.
  static const double clusterInnerMargin =
      (clusterOuterSize - clusterInnerSize) / 2; // 5 → visually ~7 in original

  // ── Cluster layer padding ────────────────────────────────────────────────
  static const double clusterPadding = 50.0;
}

// ---------------------------------------------------------------------------
// MAIN WIDGET
// ---------------------------------------------------------------------------

class TournamentFinderWidget extends StatelessWidget {
  const TournamentFinderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Consumer<TournamentFinderModel>(
        builder: (context, model, _) {
          assert(() {
            debugPrint('[BUILD] tournament_finder_widget.dart');
            return true;
          }());

          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            floatingActionButton: _FabColumn(model: model),
            floatingActionButtonLocation:
            FloatingActionButtonLocation.endTop,
            body: SafeArea(
              top: true,
              // LayoutBuilder gives us the real available height so we can
              // derive panelMaxHeight without calling MediaQuery.  This is
              // more robust because SafeArea already subtracted the status-bar
              // inset — MediaQuery.size.height would not have done that.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final panelMaxHeight =
                      constraints.maxHeight * _MapDims.panelMaxHeightFraction;

                  return SlidingUpPanel(
                    controller: model.panelController,
                    isDraggable: true,
                    minHeight: _MapDims.panelMinHeight,
                    maxHeight: panelMaxHeight,
                    // The header is a fixed-height drag handle strip that sits
                    // above the scrollable list inside the panel.
                    header: _PanelHandle(
                      availableWidth: constraints.maxWidth,
                      panelController: model.panelController,
                    ),
                    onPanelSlide: (position) => model.setMapInteractive(position == 0.0),
                    onPanelClosed: () => model.setMapInteractive(true),
                    onPanelOpened: () => model.setMapInteractive(false),
                    panel: _PanelContent(model: model),
                    body: AbsorbPointer(
                      absorbing: !model.isMapInteractive,
                      child: _MapBody(model: model),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PANEL HANDLE
//
// Two parameters are received from the parent LayoutBuilder:
//   - availableWidth   : resolves the container width without a MediaQuery call
//   - panelController  : the same PanelController owned by the model, used to
//                        open/close the panel on swipe gestures
//
// The original code tried findAncestorStateOfType<SlidingUpPanelState> which
// does not exist in the sliding_up_panel public API and would crash at runtime.
// PanelController is the correct and only supported way to programmatically
// drive the panel.
// ---------------------------------------------------------------------------

class _PanelHandle extends StatelessWidget {
  const _PanelHandle({
    required this.availableWidth,
    required this.panelController,
  });

  /// Width resolved by the parent LayoutBuilder — fills the panel exactly.
  final double availableWidth;

  /// Owned by the model; used to open/close the panel on swipe.
  final PanelController panelController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        // Swipe up → open; swipe down → close.
        // PanelController is the only supported API for programmatic control.
        if (details.delta.dy < 0) {
          panelController.open();
        } else {
          panelController.close();
        }
      },
      child: Container(
        width: availableWidth,
        height: _MapDims.panelMinHeight,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_MapDims.panelBorderRadius),
          ),
        ),
        child: Center(
          child: Container(
            width: _MapDims.handleWidth,
            height: _MapDims.handleHeight,
            decoration: BoxDecoration(
              color: CustomFlowTheme.of(context).secondaryText,
              borderRadius: BorderRadius.circular(_MapDims.handleRadius),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB COLUMN
//
// FIX: the two SizedBox(height: 10) spacers now reference _MapDims.fabSpacing
//   and _MapDims.fabTopOffset so they move together if the design changes.
// ---------------------------------------------------------------------------

class _FabColumn extends StatelessWidget {
  const _FabColumn({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: _MapDims.fabTopOffset),
        FloatingActionButton(
          heroTag: _MapConfig.heroTagRelocate,
          elevation: 4.0,
          backgroundColor: CustomFlowTheme.of(context).primary,
          onPressed: () {
            model.mapController.move(model.initialLocation, _MapConfig.initialZoom);
            model.mapController.rotate(0);
          },
          child: Icon(
            Icons.my_location,
            color: CustomFlowTheme.of(context).info,
          ),
        ),
        SizedBox(height: _MapDims.fabSpacing),
        FloatingActionButton(
          heroTag: _MapConfig.heroTagFilter,
          elevation: 4.0,
          backgroundColor: CustomFlowTheme.of(context).primary,
          onPressed: () {
            context.goNamed(
              _MapConfig.routeFilterDialog,
              extra: {
                'req': model.showChangeTournamentFinderSettingsAlertRequest(),
              },
            );
          },
          child: Icon(
            Icons.filter_alt,
            color: CustomFlowTheme.of(context).info,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PANEL CONTENT
//
// FIX: EdgeInsets.only(top: 60) replaced with
//   EdgeInsets.only(top: _MapDims.panelMinHeight).
//   Both the panel strip height and the list top-padding are now driven by
//   the same constant — change one value and both update together.
// ---------------------------------------------------------------------------

class _PanelContent extends StatelessWidget {
  const _PanelContent({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    if (model.tournamentsListRefObjToDetail.isEmpty) {
      return const Padding(
        // Offset the content below the handle strip using the shared constant.
        padding: EdgeInsets.only(top: _MapDims.panelMinHeight),
        child: NoContentCard(
          phrase: 'Non risultano tornei in questa zona.',
          type: NoContentType.pick,
          variant: NoContentVariant.pill,
        ),
      );
    }

    return ListView.builder(
      controller: model.scrollController,
      // Same constant — the list starts below the handle strip.
      padding: const EdgeInsets.only(top: _MapDims.panelMinHeight),
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
// MAP BODY
//
// FIX: removed the outer Column + Expanded wrapper.
//   SlidingUpPanel's `body` is already sized to fill the available area, so
//   wrapping FlutterMap in Column/Expanded added an unnecessary layout layer
//   with no effect on the actual dimensions.  FlutterMap fills its parent
//   natively when given no explicit size constraint.
// ---------------------------------------------------------------------------

class _MapBody extends StatelessWidget {
  const _MapBody({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: model.mapController,
      options: MapOptions(
        initialCenter: model.initialLocation,
        initialZoom: _MapConfig.initialZoom,
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
          urlTemplate: _MapConfig.tileUrlTemplate,
          userAgentPackageName: _MapConfig.userAgentPackageName,
        ),
        _UserLocationMarkerLayer(model: model),
        _TournamentClusterLayer(model: model),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// USER LOCATION MARKER LAYER
//
// FIX: magic numbers 80/80/40 replaced with _MapDims constants.
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
          width: _MapDims.userMarkerSize,
          height: _MapDims.userMarkerSize,
          child: Icon(
            Icons.location_pin,
            color: CustomFlowTheme.of(context).markerUser,
            size: _MapDims.userIconSize,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TOURNAMENT CLUSTER LAYER
//
// FIX: all inline magic numbers (80, 40, 7, 35, 70, 50, 60, 60, 40) replaced
//   with named _MapDims constants.  The cluster bubble geometry is now fully
//   described by clusterOuterSize / clusterInnerSize / clusterInnerMargin —
//   changing one value keeps the ring and bubble proportionally consistent.
// ---------------------------------------------------------------------------

class _TournamentClusterLayer extends StatelessWidget {
  const _TournamentClusterLayer({required this.model});

  final TournamentFinderModel model;

  @override
  Widget build(BuildContext context) {
    return MarkerClusterLayerWidget(
      options: MarkerClusterLayerOptions(
        maxClusterRadius: _MapConfig.maxClusterRadius,
        size: const Size(
          _MapDims.clusterOuterSize,
          _MapDims.clusterOuterSize,
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(_MapDims.clusterPadding),
        maxZoom: _MapConfig.maxClusterZoom,
        markers: [
          for (final to in model.tournamentsListRefObj)
            CustomMarker(
              point: LatLng(to.latitude, to.longitude),
              width: _MapDims.tournamentMarkerSize,
              height: _MapDims.tournamentMarkerSize,
              game: to.game,
              child: to.game.iconResource != null
                  ? InkWell(
                onTap: () => model.onMarkerTap(to.uid),
                child: Image.asset(
                  to.game.iconResource!,
                  width: _MapDims.tournamentIconSize,
                  height: _MapDims.tournamentIconSize,
                ),
              )
                  : IconButton(
                icon: Icon(
                  Icons.tour,
                  color: CustomFlowTheme.of(context).markerTournament,
                  size: _MapDims.tournamentIconSize,
                ),
                onPressed: () => model.onMarkerTap(to.uid),
              ),
            ),
        ],
        builder: (context, markers) {
          final gradientData = model.buildClusterGradient(markers);

          return Container(
            width: _MapDims.clusterOuterSize,
            height: _MapDims.clusterOuterSize,
            decoration: BoxDecoration(
              gradient: SweepGradient(
                stops: gradientData.stops,
                colors: gradientData.colors,
              ),
              borderRadius: BorderRadius.circular(_MapDims.clusterOuterRadius),
            ),
            // Inner bubble — margin keeps it centred inside the outer ring.
            child: Container(
              margin: const EdgeInsets.all(_MapDims.clusterInnerMargin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_MapDims.clusterInnerRadius),
                color: CustomFlowTheme.of(context).primary,
              ),
              // No explicit width/height needed: the margin already
              // constrains the inner container to clusterInnerSize.
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