import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_widget.dart';
import 'package:tournamentmanager/pages/core/own_tournaments/own_tournaments_model.dart';

import '../../../components/no_content_card/no_content_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double sliverAppBarExpandedHeight  = 100.0;
  static const double sliverAppBarCollapsedHeight = 70.0;
  static const double sectionFooterHeight         = 40.0;
  static const double sectionFooterRadius         = 20.0;
  static const double titlePaddingBottom          = 30.0;
  static const double titlePaddingTop             = 15.0;

  // ── Bottom spacer — derived, not guessed ──────────────────────────────────
  /// Standard Material FAB diameter.
  static const double fabSize           = 56.0;

  /// Breathing room between the last card and the FAB.
  static const double fabClearance      = 24.0;

  /// Total bottom spacing = FAB height + clearance.
  /// Derived so it stays correct if either value above changes.
  static const double listBottomSpacing = fabSize + fabClearance; // 80.0
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class OwnTournamentsWidget extends StatelessWidget {
  const OwnTournamentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<OwnTournamentsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              // FIX: model resolved here in the Selector builder and passed
              //   to _TournamentsBody as a constructor parameter.
              //   This removes context.read from inside _TournamentsBody.build
              //   and eliminates the misleading `const _TournamentsBody()` —
              //   a widget that needs a runtime model cannot be const-constructed.
              final model = context.read<OwnTournamentsModel>();
              return _TournamentsBody(model: model);
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TOURNAMENTS BODY
//
// FIX: model received as constructor parameter instead of context.read in
//   build. See rationale in root widget above.
//
// FIX: SliverToBoxAdapter bottom spacer child no longer carries
//   width: double.infinity — slivers fill the viewport cross-axis natively.
// ---------------------------------------------------------------------------

class _TournamentsBody extends StatelessWidget {
  const _TournamentsBody({required this.model});

  final OwnTournamentsModel model;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Active section ─────────────────────────────────────────────
          _SectionHeader(
            label: 'ATTIVI/FUTURI',
            backgroundColor: CustomFlowTheme.of(context).secondary,
            isExpanded: Selector<OwnTournamentsModel, bool>(
              selector: (_, m) => m.showActiveTournaments,
              builder: (_, show, __) => _ToggleIcon(show: show),
            ),
            onToggle: model.switchShowActiveTournaments,
          ),

          Selector<OwnTournamentsModel, bool>(
            selector: (_, m) => m.showActiveTournaments,
            builder: (_, show, __) => show
                ? _TournamentSliverList(
              pagingController: model.pagingControllerActive,
              listKey: 'active',
              isActive: true,
              emptyPhrase:
              'Non risultano tornei attivi o futuri. '
                  'Creane uno per gestirlo da qui!',
              model: model,
            )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Active section rounded footer
          SliverToBoxAdapter(
            child: _SectionFooter(
              color: CustomFlowTheme.of(context).secondary,
            ),
          ),

          // ── Closed section ─────────────────────────────────────────────
          _SectionHeader(
            label: 'TERMINATI',
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            isExpanded: Selector<OwnTournamentsModel, bool>(
              selector: (_, m) => m.showClosedTournaments,
              builder: (_, show, __) => _ToggleIcon(show: show),
            ),
            onToggle: model.switchShowClosedTournaments,
          ),

          Selector<OwnTournamentsModel, bool>(
            selector: (_, m) => m.showClosedTournaments,
            builder: (_, show, __) => show
                ? _TournamentSliverList(
              pagingController: model.pagingControllerClosed,
              listKey: 'closed',
              isActive: false,
              emptyPhrase: 'Non risultano tornei terminati.',
              model: model,
            )
                : const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // Bottom spacer so the last card is not hidden behind any FAB.
          const SliverToBoxAdapter(
            child: SizedBox(height: _Dims.listBottomSpacing),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION HEADER
// Accepts a pre-built widget for isExpanded so the caller can wrap it in a
// Selector without this widget needing to know about the model.
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.backgroundColor,
    required this.isExpanded,
    required this.onToggle,
  });

  final String label;
  final Color backgroundColor;
  final Widget isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: _Dims.sliverAppBarExpandedHeight,
      collapsedHeight: _Dims.sliverAppBarExpandedHeight,
      backgroundColor: backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          label,
          style: CustomFlowTheme.of(context).headlineLarge,
          textAlign: TextAlign.center,
        ),
        expandedTitleScale: 1,
        titlePadding: const EdgeInsetsDirectional.fromSTEB(
          0,
          _Dims.titlePaddingTop,
          0,
          _Dims.titlePaddingBottom,
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: isExpanded,
          onPressed: onToggle,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// TOGGLE ICON
// ---------------------------------------------------------------------------

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Icon(
      show ? Icons.remove_circle : Icons.add_circle,
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION FOOTER
//
// FIX: width: double.infinity removed from the inner SizedBox.
//   DecoratedBox inside SliverToBoxAdapter already fills the sliver
//   cross-axis — the explicit width on the child SizedBox had no effect.
// ---------------------------------------------------------------------------

class _SectionFooter extends StatelessWidget {
  const _SectionFooter({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_Dims.sectionFooterRadius),
          bottomRight: Radius.circular(_Dims.sectionFooterRadius),
        ),
      ),
      child: const SizedBox(height: _Dims.sectionFooterHeight),
    );
  }
}

// ---------------------------------------------------------------------------
// TOURNAMENT SLIVER LIST
// ---------------------------------------------------------------------------

class _TournamentSliverList extends StatelessWidget {
  const _TournamentSliverList({
    required this.pagingController,
    required this.listKey,
    required this.isActive,
    required this.emptyPhrase,
    required this.model,
  });

  final PagingController<int, TournamentsRecord> pagingController;
  final String listKey;
  final bool isActive;
  final String emptyPhrase;
  final OwnTournamentsModel model;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: pagingController,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, TournamentsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<TournamentsRecord>(
          itemBuilder: (context, item, index) {
            final itemList = pagingController.items;
            final isLast =
                itemList != null && index == itemList.length - 1;
            return TournamentCardWidget(
              key: ValueKey('tournament_${item.uid}_${listKey}_$index'),
              last: isLast,
              tournamentRef: item,
              active: isActive,
            );
          },
          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => NoContentCard(
            type: NoContentType.tournament,
            active: true,
            phrase: emptyPhrase,
          ),
          newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}
