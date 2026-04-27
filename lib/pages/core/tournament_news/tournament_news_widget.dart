import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';

import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_tournament_news_card/no_tournament_news_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Extra space at the bottom of the news list so the last card is not
  /// hidden behind the FAB.
  static const double listBottomSpacing = 100.0;

  /// Top padding before the first news card.
  static const double listTopPadding = 20.0;
}

class TournamentNewsWidget extends StatelessWidget  {
  const TournamentNewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        // ── FAB: rebuilds only when canInteractOn changes ──────────────────
        floatingActionButton: Selector<TournamentNewsModel, bool>(
          selector: (_, m) => m.canInteractOn,
          builder: (_, canInteract, __) =>
          canInteract ? const _AddNewsFab() : const SizedBox.shrink(),
        ),
        // ── Body: rebuilds only when isLoading changes ─────────────────────
        body: SafeArea(
          top: true,
          child: Selector<TournamentNewsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) =>
            isLoading ? const _LoadingBody() : const _NewsBody(),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB
// Extracted so it can be tested and reused independently.
// The model is read inside the widget to keep the parent Scaffold stable.
// ---------------------------------------------------------------------------

class _AddNewsFab extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables — parent Selector rebuilds
  const _AddNewsFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // heroTag must be unique across the widget tree to avoid Hero conflicts
      // when navigating between tabs that each have a FAB.
      heroTag: 'news_add',
      backgroundColor: CustomFlowTheme.of(context).primary,
      onPressed: () {
        // Guard: ensure the widget is still mounted before navigating.
        if (!context.mounted) return;
        final model = context.read<TournamentNewsModel>();
        context.pushNamedAuth(
          'CreateEditNews',
          context.mounted,
          pathParameters: {
            'newsId': 'NEW',
            'tournamentId': model.tournamentModel.tournamentsRef,
          }.withoutNulls,
          extra: {
            'createEditFlag': true,
          },
        );
      },
      child: Icon(Icons.add, color: CustomFlowTheme.of(context).info),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING BODY
// Simple centred indicator — no unnecessary scroll wrapper.
// ---------------------------------------------------------------------------
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ---------------------------------------------------------------------------
// NEWS BODY
// Owns the pull-to-refresh + infinite-scroll list.
// The PagingController is owned by the model, so this widget is stateless.
// ---------------------------------------------------------------------------

class _NewsBody extends StatelessWidget {
  const _NewsBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<TournamentNewsModel>();

    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── News list ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: _Dims.listTopPadding),
            sliver: _NewsSliverList(model: model),
          ),

          // ── Bottom spacer (keeps last card above the FAB) ─────────────
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
// NEWS SLIVER LIST
// Encapsulates PagedSliverList and its delegate configuration.
// Keeping this separate makes it easy to swap the pagination library later.
// ---------------------------------------------------------------------------

class _NewsSliverList extends StatelessWidget {
  const _NewsSliverList({required this.model});

  final TournamentNewsModel model;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, NewsRecord>(
      pagingController: model.pagingControllerNews,
      builderDelegate: PagedChildBuilderDelegate<NewsRecord>(
        // ── Item builder ────────────────────────────────────────────────
        itemBuilder: (context, item, index) => TournamentNewsCardWidget(
          // ValueKey is more type-safe and readable than the raw Key ctor.
          key: ValueKey('news_${item.uid}_$index'),
          newsRef: item,
          indexo: index,
          interactable: model.canInteractOn,
          deleteFun: model.deleteNews,
        ),

        // ── Placeholder states ──────────────────────────────────────────
        firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
        noItemsFoundIndicatorBuilder: (_) => const NoTournamentNewsCardWidget(
          active: true,
          phrase: 'Nessuna notizia pubblicata',
        ),
        newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
      ),
      shrinkWrapFirstPageIndicators: true,
    );
  }
}