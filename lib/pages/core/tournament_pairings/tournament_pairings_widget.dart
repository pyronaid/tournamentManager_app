import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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
  static const double appBarHeight      = 250.0;
  static const double appBarPaddingH    = 15.0;
  static const double appBarPaddingV    = 15.0;
  static const double titlePaddingTop   = 24.0;
  static const double titlePaddingBot   = 30.0;
  static const double searchBoxPercent  = 65.0; // percentage via responsive_sizer
  static const double searchBoxPaddingH = 5.0;
  static const double searchIconSize    = 18.0;
  static const double listTopPadding    = 20.0;
  static const double listBottomSpacing = 100.0;
}

class TournamentPairingsWidget extends StatelessWidget {
  const TournamentPairingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        // ── Body: rebuilds only when isLoading changes ─────────────────────
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
              return const _PairingsBody();
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
  const _PairingsBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<TournamentPairingsModel>();

    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── Pinned header + search ──────────────────────────────────────
          _PairingsAppBar(model: model),

          // ── Paged list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, _Dims.listTopPadding, 0, 0),
            sliver: _PairingsListSliver(model: model),
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

            // ── Page title ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                0, _Dims.titlePaddingTop, 0, _Dims.titlePaddingBot,
              ),
              child: Text(
                'Dettaglio Pairings',
                style: CustomFlowTheme.of(context).displaySmall,
              ),
            ),

            // ── Player search field ─────────────────────────────────────
            _SearchBox(model: model),
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

  final TournamentPairingsModel model;

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
// PAIRINGS SLIVER LIST
// Encapsulates PagedSliverList and its delegate configuration.
// Keeping this separate makes it easy to swap the pagination library later.
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
          // ── Item builder ───────────────────────────────────────────────
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