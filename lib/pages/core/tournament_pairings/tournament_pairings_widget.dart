import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/custom_expansion_panel/custom_expansion_panel_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_model.dart';

import '../../../backend/schema/pairings_record.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../components/tournament_pairing_card/tournament_pairing_card_widget.dart';
import '../../../components/tournament_pairing_card_expand/tournament_pairing_card_expand_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  // ── App bar ──────────────────────────────────────────────────────────────

  /// Total height when fully expanded.
  /// Contains: CustomAppbar (~56) + title padding top (24) + title (~32)
  /// + title padding bottom (30) + search row (~48) + vertical padding (30).
  /// Kept as a named constant so any resize is a one-line change.
  static const double appBarExpandedHeight  = 250.0;

  /// Height when collapsed to just the navigation bar + search field.
  /// Must be strictly less than appBarExpandedHeight so the bar actually
  /// collapses on scroll.  96 = CustomAppbar (~56) + search row (~48) - overlap.
  static const double appBarCollapsedHeight = 110.0;

  static const double appBarPaddingH        = 15.0;
  static const double appBarPaddingV        = 15.0;
  static const double titlePaddingTop       = 24.0;
  static const double titlePaddingBot       = 30.0;

  // ── Search field ─────────────────────────────────────────────────────────

  /// Horizontal padding applied to the search field's parent container.
  /// The field itself uses width: double.infinity and fills the remaining
  /// space — no percentage sizing needed.
  static const double searchPaddingH       = 32.0;

  /// Maximum width of the search field on large screens (tablets, foldables).
  /// Prevents the field from stretching to an unreadable width on wide layouts.
  static const double searchMaxWidth       = 480.0;

  static const double searchIconSize       = 18.0;

  // ── List ─────────────────────────────────────────────────────────────────
  static const double listTopPadding    = 20.0;

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

class TournamentPairingsWidget extends StatelessWidget {
  const TournamentPairingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<TournamentPairingsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_pairings_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();

              // Model is resolved here (inside the Selector builder) and
              // passed as a parameter — avoiding context.read inside a
              // descendant build method where the call site is less clear.
              final model = context.read<TournamentPairingsModel>();
              return _PairingsBody(model: model);
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
// PAIRINGS BODY
// Owns the pull-to-refresh and CustomScrollView.
// context.read is correct: _PairingsBody only rebuilds when isLoading flips.
// ---------------------------------------------------------------------------

class _PairingsBody extends StatelessWidget {
  const _PairingsBody({required this.model});

  final TournamentPairingsModel model;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Pinned header + search ────────────────────────────────────
          _PairingsAppBar(model: model),

          // ── Paged list ────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: _Dims.listTopPadding),
            sliver: _PairingsListSliver(model: model),
          ),

          // ── Bottom spacer (keeps last card above any FAB) ─────────────
          const SliverToBoxAdapter(
            child: SizedBox(height: _Dims.listBottomSpacing),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PAIRINGS APP BAR
// Pinned SliverAppBar containing navigation controls and the search field.
// ---------------------------------------------------------------------------

class _PairingsAppBar extends StatelessWidget {
  const _PairingsAppBar({required this.model});

  final TournamentPairingsModel model;

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
      // ClipRect + OverflowBox is the standard Flutter pattern for
      // SliverAppBar flexibleSpace with fixed-height content.
      //
      // Problem: as the user scrolls, SliverAppBar shrinks the flexibleSpace
      // below its expandedHeight, but the Column's children have a fixed
      // combined height — causing a RenderFlex overflow assertion.
      //
      // Solution: OverflowBox always tells the Column it has expandedHeight
      // available (so children always fit and no assertion is thrown).
      // ClipRect clips the rendered output to the SliverAppBar's real current
      // height, giving the standard "content scrolls under the collapsed bar"
      // look without any layout error.
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
                // ── Navigation bar ────────────────────────────────────
                CustomAppbarWidget(
                  backButton: true,
                  actionButton: true,
                  actionButtonText: 'Rankings',
                  actionButtonAction: () async {
                    if (!context.mounted) return;
                    context.pushNamedAuth(
                      'TournamentRankings', context.mounted,
                      pathParameters: {
                        'tournamentId': model.tournamentModel.tournamentsRef,
                        'roundId': model.roundId,
                      }.withoutNulls,
                    );
                  },
                  optionsButtonAction: () async {},
                ),

                // ── Page title ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                    0, _Dims.titlePaddingTop, 0, _Dims.titlePaddingBot,
                  ),
                  child: Text(
                    'Dettaglio Pairings',
                    style: CustomFlowTheme.of(context).displaySmall,
                  ),
                ),

                // ── Player search field ───────────────────────────────
                _SearchBox(model: model),
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

  final TournamentPairingsModel model;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _Dims.searchMaxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: _Dims.searchPaddingH),
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
// PAIRINGS SLIVER LIST
// ---------------------------------------------------------------------------

class _PairingsListSliver extends StatelessWidget {
  const _PairingsListSliver({required this.model});

  final TournamentPairingsModel model;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: model.pagingControllerPairings,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, PairingsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<PairingsRecord>(
          // ── Item builder ──────────────────────────────────────────────
          itemBuilder: (context, item, index) => CustomExpansionPanelWidget(
            isExpandable: !item.isBye && model.isTournamentEditable(item),
            expandedContentBuilder: (context) => TournamentPairingCardExpandWidget(
              pairingRef: item,
              updateFun: model.updatePairing,
            ),
            child: TournamentPairingsCardWidget(
              key: ValueKey('pairing_${item.uid}_$index'),
              pairingRef: item,
              index: index,
              deleteFun: model.deletePairing,
            ),
          ),

          // ── Placeholder states ─────────────────────────────────────────
          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => const NoContentCard(
            type: NoContentType.pairings,
            active: true,
            phrase: 'Nessun pairing pubblicato',
          ),
          newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}
