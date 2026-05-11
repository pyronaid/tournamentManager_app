import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';

import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';

// ---------------------------------------------------------------------------
// CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Standard Material FAB diameter.
  static const double fabSize = 56.0;

  /// Breathing room between the last card and the FAB.
  static const double fabClearance = 24.0;

  /// Total bottom spacing = FAB height + clearance.
  /// Derived so it stays correct if either value above changes.
  static const double listBottomSpacing = fabSize + fabClearance; // 80.0

  /// Top padding before the first news card.
  static const double listTopPadding = 20.0;
}

abstract class _Routes {
  /// Route name for the create/edit news screen.
  static const String createEditNews = 'CreateEditNews';

  /// Sentinel value that signals "create a new record" to the target screen.
  /// Defined here so it never appears as a raw string literal in build methods.
  static const String newRecordId = 'NEW';
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class TournamentNewsWidget extends StatelessWidget {
  const TournamentNewsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,

        // ── FAB: rebuilds only when canInteractOn changes ──────────────────
        // The model is read here and passed as a parameter so _AddNewsFab
        // can be a honest const-constructible widget.  It receives only the
        // data it needs (tournamentRef + the navigation trigger) rather than
        // the entire model — reducing its coupling and making it testable in
        // isolation.
        floatingActionButton: Selector<TournamentNewsModel, bool>(
          selector: (_, m) => m.canInteractOn,
          builder: (_, canInteract, __) {
            if (!canInteract) return const SizedBox.shrink();

            // Read is safe here: we are inside a Selector builder that
            // already fired because canInteractOn changed — the model is
            // guaranteed to be present and we do not need to listen to it.
            final tournamentRef = context.read<TournamentNewsModel>().tournamentModel.tournamentsRef;

            return _AddNewsFab(tournamentRef: tournamentRef!);
          },
        ),

        // ── Body: rebuilds only when isLoading changes ─────────────────────
        body: SafeArea(
          top: true,
          child: Selector<TournamentNewsModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              if (isLoading) return const _LoadingBody();

              // Pass the model explicitly so _NewsBody does not need to call
              // context.read/watch inside its own build method.
              final model = context.read<TournamentNewsModel>();
              return _NewsBody(model: model);
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FAB
//
// FIX 1: removed the suppressed lint comment
//   `// ignore: prefer_const_constructors_in_immutables`.
//   The original widget took no parameters yet called context.read inside
//   build — making the const constructor misleading.  Now tournamentRef is
//   received as an immutable parameter so the widget is genuinely const.
//
// FIX 2: the raw string literal 'NEW' is replaced with _Routes.newRecordId.
// ---------------------------------------------------------------------------

class _AddNewsFab extends StatelessWidget {
  const _AddNewsFab({required this.tournamentRef});

  /// The tournament identifier forwarded to the create/edit screen.
  final String tournamentRef;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      // heroTag must be unique across the widget tree to avoid Hero conflicts
      // when navigating between tabs that each have a FAB.
      heroTag: 'news_add',
      backgroundColor: CustomFlowTheme.of(context).primary,
      onPressed: () {
        if (!context.mounted) return;
        context.pushNamedAuth(
          _Routes.createEditNews,
          context.mounted,
          pathParameters: {
            'newsId': _Routes.newRecordId,
            'tournamentId': tournamentRef,
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
//
// FIX: model is now received as a constructor parameter instead of being
//   obtained via context.read() inside build().
//
//   context.read() inside build() is an anti-pattern documented by the
//   Provider team: it does not subscribe to changes (fine here since we use
//   Selector above), but more importantly it will throw if the widget
//   rebuilds during a frame where the model is briefly absent (e.g. during
//   hot-reload or a tree restructure).  Passing the model explicitly makes
//   the dependency visible and eliminates the runtime risk.
// ---------------------------------------------------------------------------

class _NewsBody extends StatelessWidget {
  const _NewsBody({required this.model});

  final TournamentNewsModel model;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          // ── News list ──────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.only(top: _Dims.listTopPadding),
            sliver: _NewsSliverList(model: model),
          ),

          // ── Bottom spacer (keeps last card clear of the FAB) ──────────
          // FIX: removed `width: double.infinity` from the inner SizedBox.
          //   Slivers always expand to fill the cross-axis of the viewport;
          //   an explicit width has no effect and adds visual noise.
          const SliverToBoxAdapter(
            child: SizedBox(height: _Dims.listBottomSpacing),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// NEWS SLIVER LIST
// ---------------------------------------------------------------------------

class _NewsSliverList extends StatelessWidget {
  const _NewsSliverList({required this.model});

  final TournamentNewsModel model;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: model.pagingControllerNews,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, NewsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<NewsRecord>(
          // ── Item builder ──────────────────────────────────────────────
          itemBuilder: (context, item, index) => TournamentNewsCardWidget(
            key: ValueKey('news_${item.uid}_$index'),
            newsRef: item,
            index: index,
            interactable: model.canInteractOn,
            deleteFun: model.deleteNews,
          ),

          // ── Placeholder states ──────────────────────────────────────────
          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => const NoContentCard(
            type: NoContentType.news,
            active: true,
            phrase: 'Nessuna notizia pubblicata',
          ),
          newPageProgressIndicatorBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}
