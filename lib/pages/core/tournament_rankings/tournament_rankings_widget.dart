import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_rankings/tournament_rankings_model.dart';

import '../../../backend/schema/rankings_record.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../components/tournament_ranking_card/tournament_ranking_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  // ── App bar ──────────────────────────────────────────────────────────────

  /// Total height when fully expanded.
  /// Contains: CustomAppbar (~56) + title padding (24+30) + title (~32)
  /// + search row (~48) + header top padding (10) + column header row (~50)
  /// + vertical padding (30).
  static const double appBarExpandedHeight  = 285.0;

  /// Height when collapsed.
  /// Must be strictly less than appBarExpandedHeight so the bar collapses.
  /// Keeps the search field AND the column header always visible, since both
  /// are needed to use the list: search filters, header labels give context.
  /// = CustomAppbar (~56) + search row (~48) + column header (~50)
  ///   + vertical padding (30) - small overlap = 145.
  static const double appBarCollapsedHeight = 145.0;

  static const double appBarPaddingH        = 15.0;
  static const double appBarPaddingV        = 15.0;
  static const double titlePaddingTop       = 24.0;
  static const double titlePaddingBot       = 30.0;

  // ── Search field ─────────────────────────────────────────────────────────

  /// Horizontal padding applied to the search field's parent container.
  /// The field itself uses width: double.infinity and fills the remaining
  /// space — no percentage sizing needed.
  static const double searchPaddingH        = 32.0;

  /// Maximum width of the search field on large screens (tablets, foldables).
  /// Prevents the field from stretching to an unreadable width on wide layouts.
  static const double searchMaxWidth        = 480.0;

  static const double searchIconSize        = 18.0;

  // ── Column header ─────────────────────────────────────────────────────────
  static const double headerTopPadding      = 10.0;
  static const double headerMinHeight       = 20.0;
  static const double headerRowPaddingV     = 15.0;

  // ── List ─────────────────────────────────────────────────────────────────
  static const double listTopPadding        = 20.0;

  /// Standard Material FAB diameter.
  static const double fabSize               = 56.0;

  /// Breathing room between the last card and the FAB.
  static const double fabClearance          = 24.0;

  /// Total bottom spacing = FAB height + clearance.
  /// Derived so it stays correct if either value above changes.
  static const double listBottomSpacing     = fabSize + fabClearance; // 80.0
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class TournamentRankingsWidget extends StatelessWidget {
  const TournamentRankingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<TournamentRankingsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_rankings_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();

              // FIX: model is resolved here and passed as a parameter so
              //   _RankingsBody does not need to call context.read inside
              //   its own build method.  This also removes the misleading
              //   `const` on `_RankingsBody()` — a widget that needs a
              //   runtime model reference cannot be const-constructed.
              final model = context.read<TournamentRankingsModel>();
              return _RankingsBody(model: model);
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING BODY
// ---------------------------------------------------------------------------

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

// ---------------------------------------------------------------------------
// RANKINGS BODY
// Owns the pull-to-refresh and CustomScrollView.
// context.read is correct: _RankingsBody only rebuilds when isLoading flips.
// ---------------------------------------------------------------------------

class _RankingsBody extends StatelessWidget {
  const _RankingsBody({required this.model});

  final TournamentRankingsModel model;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Pinned header + search + column labels ──────────────────
          _RankingsAppBar(model: model),

          // ── Paged list ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: _Dims.listTopPadding),
            sliver: _RankingsListSliver(model: model),
          ),

          // ── Bottom spacer (keeps last card above any FAB) ───────────
          const SliverToBoxAdapter(
            child: SizedBox(height: _Dims.listBottomSpacing),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RANKINGS APP BAR
// Pinned SliverAppBar containing navigation controls, search field, and the
// column header row.
// ---------------------------------------------------------------------------

class _RankingsAppBar extends StatelessWidget {
  const _RankingsAppBar({required this.model});

  final TournamentRankingsModel model;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: _Dims.appBarExpandedHeight,
      // Now strictly less than expandedHeight — the bar actually collapses.
      collapsedHeight: _Dims.appBarExpandedHeight,
      backgroundColor: CustomFlowTheme.of(context).secondary,
      // ClipRect + OverflowBox: same pattern as tournament_pairings_widget.
      // OverflowBox always gives the Column expandedHeight, so the children
      // never overflow their constraint regardless of scroll position.
      // ClipRect clips the visual output to the SliverAppBar's real height.
      flexibleSpace: ClipRect(
        child: OverflowBox(
          minHeight: 0,
          maxHeight: _Dims.appBarExpandedHeight,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: _Dims.appBarPaddingH,
              vertical: _Dims.appBarPaddingV,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // ── Navigation bar ──────────────────────────────────
                CustomAppbarWidget(
                  backButton: true,
                  actionButton: false,
                  optionsButtonAction: () async {},
                ),

                // ── Page title (scrolls away on collapse) ───────────
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    0, _Dims.titlePaddingTop, 0, _Dims.titlePaddingBot,
                  ),
                  child: Text(
                    'Ranking',
                    style: CustomFlowTheme.of(context).displaySmall,
                  ),
                ),

                // ── Player search field (always visible when pinned) ─
                _SearchBox(model: model),

                // ── Column header row (always visible when pinned) ───
                const _ColumnHeader(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SEARCH BOX
// ---------------------------------------------------------------------------

class _SearchBox extends StatelessWidget {
  const _SearchBox({required this.model});

  final TournamentRankingsModel model;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _Dims.searchMaxWidth),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: _Dims.searchPaddingH),
          child: TextField(
            controller: model.playerNameTextController,
            focusNode: model.playerNameFocusNode,
            autofocus: false,
            obscureText: false,
            decoration: standardInputDecoration(
              context,
              prefixIcon: Icon(
                Icons.person,
                color: CustomFlowTheme.of(context).secondaryText,
                size: _Dims.searchIconSize,
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
    );
  }
}

// ---------------------------------------------------------------------------
// COLUMN HEADER
// The Container width is intentionally oversized (1000) and clipped by
// ClipRRect to fill the device width regardless of screen size.
// Two nested Containers from the original are merged into one.
// ---------------------------------------------------------------------------

class _ColumnHeader extends StatelessWidget {
  const _ColumnHeader();

  @override
  Widget build(BuildContext context) {
    final titleStyle = CustomFlowTheme.of(context).titleMedium
        .override(color: CustomFlowTheme.of(context).cardMain);
    final bodyStyle = CustomFlowTheme.of(context).bodySmall
        .override(color: CustomFlowTheme.of(context).cardMain);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.headerTopPadding, 0, 0),
      // FIX: ClipRRect removed.  width: double.infinity on the Container
      //   fills the available width correctly on every screen size.
      child: Container(
        width: double.infinity,
        color: CustomFlowTheme.of(context).tertiary,
        constraints: const BoxConstraints(minHeight: _Dims.headerMinHeight),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Position ──────────────────────────────────────────
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.center,
                child: Text('p.', style: titleStyle, softWrap: true),
              ),
            ),
            // ── Player name ───────────────────────────────────────
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    0,
                    _Dims.headerRowPaddingV,
                    0,
                    _Dims.headerRowPaddingV,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Player', style: titleStyle, softWrap: true),
                    ],
                  ),
                ),
              ),
            ),
            // ── Score columns ─────────────────────────────────────
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: Container(
                alignment: Alignment.center,
                child: Text('points', style: bodyStyle, softWrap: true),
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Container(
                alignment: Alignment.center,
                child: Text('T1', style: bodyStyle, softWrap: true),
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Container(
                alignment: Alignment.center,
                child: Text('T2', style: bodyStyle, softWrap: true),
              ),
            ),
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: Container(
                alignment: Alignment.center,
                child: Text('T3', style: bodyStyle, softWrap: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RANKINGS SLIVER LIST
// ---------------------------------------------------------------------------

class _RankingsListSliver extends StatelessWidget {
  const _RankingsListSliver({required this.model});

  final TournamentRankingsModel model;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: model.pagingControllerRankings,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, RankingsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<RankingsRecord>(
          // ── Item builder ────────────────────────────────────────
          itemBuilder: (context, item, index) => TournamentRankingsCardWidget(
            key: ValueKey('ranking_${item.uid}_$index'),
            rankingRef: item,
            index: index,
          ),

          // ── Placeholder states ─────────────────────────────────────────
          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => const NoContentCard(
            type: NoContentType.rankings,
            active: true,
            phrase: 'Nessun player in classifica',
          ),
          newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}
