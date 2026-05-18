import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_model.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_model.dart';

import '../../../backend/schema/rounds_record.dart';
import '../../../components/fab_expandable/fab_expandable_widget.dart';
import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';
import '../../../components/tournament_round_card/tournament_rounds_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double listTopPadding = 20.0;

  // ── Bottom spacer — derived, not guessed ──────────────────────────────────
  /// Standard Material FAB diameter.
  static const double fabSize = 56.0;

  /// Breathing room between the last card and the FAB.
  static const double fabClearance = 24.0;

  /// Total bottom spacing = FAB height + clearance.
  /// Derived so it stays correct if either value above changes.
  static const double listBottomSpacing = fabSize + fabClearance; // 80.0

  // ── FAB expandable ────────────────────────────────────────────────────────
  /// The radius of the arc on which child FABs are spread when the
  /// FabExpandableWidget is open.  This is a design value that controls
  /// how far the children fan out — not related to screen size.
  static const double fabDistance = 60.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class TournamentDecklistWidget extends StatelessWidget {
  const TournamentDecklistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        // ── Body: loading gate rebuilds only when isLoading changes.
        body: SafeArea(
          top: true,
          child: Selector<TournamentDecklistModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_decklist_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();

              // FIX: model is resolved here and passed as a parameter so
              //   _RoundsBody does not need to call context.read inside its
              //   own build method.  This also removes the misleading `const`
              //   keyword that was on `_RoundsBody()` — a widget that receives
              //   a non-const model reference cannot be const-constructed.
              final model = context.read<TournamentDecklistModel>();
              return _DecklistBody(model: model);
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
// ROUNDS BODY
// Owns the RefreshIndicator and the CustomScrollView.
// context.read is correct here: _RoundsBody only rebuilds when isLoading
// flips (Selector above), so there is no stale-reference risk on the model.
// ---------------------------------------------------------------------------

class _DecklistBody extends StatelessWidget {
  const _DecklistBody({required this.model});

  final TournamentDecklistModel model;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: Center(
        child: Text(
          "Decklist page",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ROUNDS SLIVER LIST
// Encapsulates PagedSliverList and its delegate configuration.
// Extracted to keep _RoundsBody readable and to make the pagination
// delegate easy to swap independently.
// ---------------------------------------------------------------------------

class _RoundsSliverList extends StatelessWidget {
  const _RoundsSliverList({required this.model});

  final TournamentRoundsModel model;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: model.pagingControllerRounds,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, RoundsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<RoundsRecord>(
          itemBuilder: (context, item, index) {
            final itemList = model.pagingControllerRounds.items;
            final isLast =
                itemList != null && index == itemList.length - 1;

            return TournamentRoundsCardWidget(
              key: ValueKey('round_${item.uid}_$index'),
              roundRef: item,
              index: index,
              deleteFun: model.deleteRound,
              // Safe null check on itemList — avoids the force-unwrap
              // itemList! that would throw if the list is null.
              closeFun: isLast ? model.closeTournament : null,
              deepFun: (roundId) {
                context.pushNamedAuth(
                  'TournamentPairings', context.mounted,
                  pathParameters: {
                    'tournamentId': model.tournamentModel.tournamentId,
                    'roundId': roundId,
                  }.withoutNulls,
                );
              },
              editable: model.isTournamentEditable,
            );
          },
          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => const NoContentCard(
            type: NoContentType.rounds,
            active: true,
            phrase: 'Nessun round pubblicato',
          ),
          newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}
