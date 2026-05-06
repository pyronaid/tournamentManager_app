import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
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
  static const double appBarHeight       = 285.0;
  static const double appBarPaddingH     = 15.0;
  static const double appBarPaddingV     = 15.0;
  static const double titlePaddingTop    = 24.0;
  static const double titlePaddingBot    = 30.0;
  static const double searchBoxPercent   = 65.0; // percentage via responsive_sizer
  static const double searchBoxPaddingH  = 5.0;
  static const double searchIconSize     = 18.0;
  static const double headerTopPadding   = 10.0;
  static const double headerWidth        = 1000.0; // clipped to parent bounds
  static const double headerMinHeight    = 20.0;
  static const double headerRowPaddingV  = 15.0;
  static const double listTopPadding     = 20.0;
  static const double listBottomSpacing  = 100.0;
}

class TournamentRankingsWidget extends StatelessWidget {
  const TournamentRankingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // initContextVars is idempotent — safe to call on every build.
    context.read<TournamentRankingsModel>().initContextVars(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        // ── Body: rebuilds only when isLoading changes ─────────────────────
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
              return const _RankingsBody();
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
  const _RankingsBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<TournamentRankingsModel>();

    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Pinned header + search + column labels ──────────────────────
          _RankingsAppBar(model: model),

          // ── Paged list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, _Dims.listTopPadding, 0, 0),
            sliver: _RankingsListSliver(model: model),
          ),

          // ── Bottom spacer (keeps last card above any FAB) ───────────────
          const SliverToBoxAdapter(
            child: SizedBox(
              height: _Dims.listBottomSpacing,
              width: double.infinity,
            ),
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
// The updateCallback no-op is intentional: the appbar content is static for
// this page, so triggering a parent rebuild on appbar changes is not needed.
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
      expandedHeight: _Dims.appBarHeight,
      collapsedHeight: _Dims.appBarHeight,
      backgroundColor: CustomFlowTheme.of(context).secondary,
      flexibleSpace: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: _Dims.appBarPaddingH,
          vertical: _Dims.appBarPaddingV,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ── Navigation bar ──────────────────────────────────────────
            wrapWithModel(
              model: model.customAppbarModel,
              updateCallback: () {},
              child: CustomAppbarWidget(
                backButton: true,
                actionButton: false,
                actionButtonAction: () async {},
                optionsButtonAction: () async {},
              ),
            ),

            // ── Page title ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                0, _Dims.titlePaddingTop, 0, _Dims.titlePaddingBot,
              ),
              child: Text(
                'Ranking',
                style: CustomFlowTheme.of(context).displaySmall,
              ),
            ),

            // ── Player search field ─────────────────────────────────────
            _SearchBox(model: model),

            // ── Column header row ───────────────────────────────────────
            const _ColumnHeader(),
          ],
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _Dims.searchBoxPercent.w,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: _Dims.searchBoxPaddingH,
            ),
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
      ],
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
      child: ClipRRect(
        child: Container(
          width: _Dims.headerWidth,
          color: CustomFlowTheme.of(context).tertiary,
          constraints: const BoxConstraints(minHeight: _Dims.headerMinHeight),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Position ────────────────────────────────────────────
              Flexible(
                flex: 1, fit: FlexFit.tight,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('p.', style: titleStyle, softWrap: true),
                ),
              ),
              // ── Player name (extra vertical padding for row height) ──
              Flexible(
                flex: 5, fit: FlexFit.tight,
                child: Container(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      0, _Dims.headerRowPaddingV, 0, _Dims.headerRowPaddingV,
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
              // ── Score columns ────────────────────────────────────────
              Flexible(
                flex: 2, fit: FlexFit.loose,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('points', style: bodyStyle, softWrap: true),
                ),
              ),
              Flexible(
                flex: 3, fit: FlexFit.loose,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('T1', style: bodyStyle, softWrap: true),
                ),
              ),
              Flexible(
                flex: 3, fit: FlexFit.loose,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('T2', style: bodyStyle, softWrap: true),
                ),
              ),
              Flexible(
                flex: 2, fit: FlexFit.loose,
                child: Container(
                  alignment: Alignment.center,
                  child: Text('T3', style: bodyStyle, softWrap: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RANKINGS SLIVER LIST
// Encapsulates PagedSliverList and its delegate configuration.
// ---------------------------------------------------------------------------
class _RankingsListSliver extends StatelessWidget {
  const _RankingsListSliver({required this.model});

  final TournamentRankingsModel model;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, RankingsRecord>(
      pagingController: model.pagingControllerRankings,
      builderDelegate: PagedChildBuilderDelegate<RankingsRecord>(
        // ── Item builder ───────────────────────────────────────────────
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
    );
  }
}
