import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
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
  static const double listTopPadding    = 20.0;
  static const double listBottomSpacing = 100.0;
  static const double fabDistance       = 60.0;
}

class TournamentRoundsWidget extends StatelessWidget {
  const TournamentRoundsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,

        // ── FAB: rebuilds only when isTournamentOngoing or canInteractOn
        // changes — not on every model notification.
        floatingActionButton: Selector<TournamentRoundsModel,
            ({bool ongoing, bool canInteract})>(
          selector: (_, m) => (
          ongoing: m.isTournamentOngoing,
          canInteract: m.canInteractOn,
          ),
          builder: (context, state, __) {
            if (!state.ongoing || !state.canInteract) {
              return const SizedBox.shrink();
            }
            final model = context.read<TournamentRoundsModel>();
            return FabExpandableWidget(
              distance: _Dims.fabDistance,
              children: model.buildFabActions(context),
            );
          },
        ),

        // ── Body: loading gate rebuilds only when isLoading changes.
        body: SafeArea(
          top: true,
          child: Selector<TournamentRoundsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_rounds_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();
              return const _RoundsBody();
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
class _RoundsBody extends StatelessWidget {
  const _RoundsBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<TournamentRoundsModel>();

    return RefreshIndicator(
      // FIX: method tear-off — no anonymous async lambda needed.
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, _Dims.listTopPadding, 0, 0),
            sliver: _RoundsSliverList(model: model),
          ),

          // Bottom spacer so the last card is not hidden behind the FAB.
          const SliverToBoxAdapter(
            child: SizedBox(height: _Dims.listBottomSpacing),
          ),
        ],
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
    return PagedSliverList<int, RoundsRecord>(
      pagingController: model.pagingControllerRounds,
      builderDelegate: PagedChildBuilderDelegate<RoundsRecord>(
        itemBuilder: (context, item, index) {
          final itemList = model.pagingControllerRounds.itemList;
          final isLast =
              itemList != null && index == itemList.length - 1;

          return TournamentRoundsCardWidget(
            // ValueKey is more type-safe and readable than the raw Key ctor.
            key: ValueKey('round_${item.uid}_$index'),
            roundRef: item,
            indexo: index,
            deleteFun: model.deleteRound,
            // FIX: closeFun uses a safe null check on itemList instead of
            // force-unwrapping itemList! which would throw if the list is null.
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
    );
  }
}