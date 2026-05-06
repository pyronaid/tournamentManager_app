import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_widget.dart';
import 'package:tournamentmanager/pages/core/my_tournaments/my_tournaments_model.dart';

import '../../../components/no_content_card/no_content_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// Centralise all magic numbers to make future adjustments trivial.
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double sliverAppBarExpandedHeight = 100.0;
  static const double sliverAppBarCollapsedHeight = 70.0;
  static const double sectionFooterHeight = 40.0;
  static const double listBottomSpacing = 100.0;
  static const double titlePaddingBottom = 30.0;
  static const double titlePaddingTop = 15.0;
  static const double sectionFooterRadius = 20.0;
}

class MyTournamentsWidget extends StatelessWidget {
  const MyTournamentsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<MyTournamentsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const _TournamentsBody();
            },
          ),
        ),
      ),
    );
  }
}

class _TournamentsBody extends StatelessWidget {
  const _TournamentsBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<MyTournamentsModel>();

    return RefreshIndicator(
      // FIX [medium]: no anonymous lambda wrapper needed — method tear-off
      // is cleaner and avoids creating a closure on every build.
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Active section ───────────────────────────────────────────────
          _SectionHeader(
            label: 'ATTIVI/FUTURI',
            backgroundColor: CustomFlowTheme.of(context).secondary,
            // Selector ensures only this header rebuilds when the flag flips.
            isExpanded: Selector<MyTournamentsModel, bool>(
              selector: (_, m) => m.showActiveTournaments,
              builder: (_, show, __) => _ToggleIcon(show: show),
            ),
            onToggle: model.switchShowActiveTournaments,
          ),

          // FIX [medium]: Selector on showActiveTournaments so the list
          // appears/disappears without rebuilding the whole scroll view.
          Selector<MyTournamentsModel, bool>(
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

          // ── Closed section ───────────────────────────────────────────────
          _SectionHeader(
            label: 'TERMINATI',
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            isExpanded: Selector<MyTournamentsModel, bool>(
              selector: (_, m) => m.showClosedTournaments,
              builder: (_, show, __) => _ToggleIcon(show: show),
            ),
            onToggle: model.switchShowClosedTournaments,
          ),

          Selector<MyTournamentsModel, bool>(
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.backgroundColor,
    required this.isExpanded,
    required this.onToggle,
  });

  final String label;
  final Color backgroundColor;
  // Accepts a pre-built widget so the caller can wrap it in a Selector
  // without this widget needing to know about the model.
  final Widget isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: _Dims.sliverAppBarExpandedHeight,
      collapsedHeight: _Dims.sliverAppBarCollapsedHeight,
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
      child: const SizedBox(
        height: _Dims.sectionFooterHeight,
        width: double.infinity,
      ),
    );
  }
}

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
  final MyTournamentsModel model;

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
              // ValueKey is type-safe and disambiguates between the two lists.
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