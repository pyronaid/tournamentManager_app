// pages/core/tournament_people/tournament_people_shared_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:tournamentmanager/components/no_content_card/no_content_card_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS — defined once, shared by all three list pages.
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double appBarHeight      = 200.0;
  static const double appBarPaddingH    = 15.0;
  static const double appBarPaddingV    = 15.0;
  static const double searchBoxPercent  = 65.0;
  static const double searchBoxPaddingH = 5.0;
  static const double searchIconSize    = 18.0;
  static const double addBtnSize        = 50.0;
  static const double addBtnRadius      = 30.0;
  static const double countBoxRadius    = 8.0;
  static const double countBoxPaddingH  = 24.0;
  static const double countBoxPaddingV  = 10.0;
  static const double listPaddingH      = 24.0;
  static const double listPaddingV      = 10.0;
}

// ---------------------------------------------------------------------------
// ALERT REQUEST BUILDERS
// Private top-level functions — "top-level" means they are file-scoped,
// not tied to any class, but still private to this file (leading underscore).
//
// They live HERE because:
//   • They need TournamentPeopleBaseModel (the operations owner).
//   • They are called from _PeopleListSliver, which is also in this file.
//   • No widget class needs to own them — they are pure helper functions.
// ---------------------------------------------------------------------------

AlertRequest _buildDeleteRequest(
    TournamentPeopleModel model,
    EnrollmentsRecord player,
    ListType listType,
    ) {
  return AlertRequest(
    title: 'ATTENZIONE: Cancellazione dell\'utente in corso...',
    description: 'Sei sicuro di voler eliminare questo utente dalla lista?',
    buttonTitleCancelled: 'Annulla',
    buttonTitleConfirmed: 'Continua',
    functionConfirmed: (_) =>
        model.deletePeople(player.userId, listType: listType),
  );
}

AlertRequest _buildPromoteRequest(
    TournamentPeopleModel model,
    EnrollmentsRecord player,
    ) {
  return AlertRequest(
    title: 'ATTENZIONE: Promozione dell\'utente in corso...',
    description: 'L\'utente verrà promosso a registrato!',
    buttonTitleCancelled: 'Annulla',
    buttonTitleConfirmed: 'Continua',
    functionConfirmed: (_) => model.promotePeople(
      player.userId,
      listType: ListType.registered,
    ),
  );
}

// ---------------------------------------------------------------------------
// SHARED PAGE SCAFFOLD
// The three sub-pages each provide a typed Selector on their specific model,
// then delegate the entire body to this shared widget.
// ---------------------------------------------------------------------------

/// Configuration object — encodes everything that differs between the
/// three list pages. Adding a new list type = one new [PeoplePageConfig].
class PeoplePageConfig {
  const PeoplePageConfig({
    required this.listType,
    required this.countLabel,
    required this.canPromote,
    required this.addRoute,
  });

  final ListType listType;
  final String countLabel;
  final bool canPromote;

  /// The named route to push when the add button is tapped.
  final String addRoute;
}

// ---------------------------------------------------------------------------
// LOADING BODY — shared across all three pages
// ---------------------------------------------------------------------------
class PeopleLoadingBody extends StatelessWidget {
  const PeopleLoadingBody({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

// ---------------------------------------------------------------------------
// MAIN BODY — shared across all three pages
// M is the concrete model type, needed only for the Selector type parameter.
// ---------------------------------------------------------------------------
class PeopleBody<M extends TournamentPeopleModel> extends StatelessWidget {
  const PeopleBody({
    super.key,
    required this.config,
  });

  final PeoplePageConfig config;

  @override
  Widget build(BuildContext context) {
    // context.read is safe: the parent Selector already rebuilt when
    // isLoading changed. This widget itself never needs to rebuild from model.
    final model = context.read<M>();

    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          _PeopleAppBar<M>(model: model, config: config),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              _Dims.listPaddingH, _Dims.listPaddingV,
              _Dims.listPaddingH, _Dims.listPaddingV,
            ),
            sliver: _PeopleListSliver(model: model, config: config),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// APP BAR
// ---------------------------------------------------------------------------
class _PeopleAppBar<M extends TournamentPeopleModel>
    extends StatelessWidget {
  const _PeopleAppBar({required this.model, required this.config});

  final TournamentPeopleModel model;
  final PeoplePageConfig config;

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
            _SearchAndAddRow(model: model, config: config),
            Selector<M, int>(
              selector: (_, m) => m.countElements,
              builder: (_, count, __) => _CountBadge(
                label: config.countLabel,
                count: count,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SEARCH AND ADD ROW
// ---------------------------------------------------------------------------
class _SearchAndAddRow extends StatelessWidget {
  const _SearchAndAddRow({required this.model, required this.config});

  final TournamentPeopleModel model;
  final PeoplePageConfig config;

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
                horizontal: _Dims.searchBoxPaddingH),
            child: TextField(
              controller: model.peopleNameTextController,
              focusNode: model.peopleNameFocusNode,
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
        if (model.isTournamentEditable)
          _AddButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('Button_load_pic');
              context.pushNamedAuth(
                config.addRoute,
                context.mounted,
                pathParameters: {
                  'tournamentId': model.tournamentModel.tournamentId,
                }.withoutNulls,
                extra: {
                  'listType': config.listType.name,
                  'provider': model,
                },
              );
              logFirebaseEvent('Button_haptic_feedback');
              HapticFeedback.lightImpact();
            },
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// ADD BUTTON
// ---------------------------------------------------------------------------
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AFButtonWidget(
        onPressed: () async => onPressed(),
        text: '',
        icon: const Icon(Icons.add_circle),
        options: AFButtonOptions(
          width: _Dims.addBtnSize,
          height: _Dims.addBtnSize,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          iconColor: Colors.white,
          iconSize: 14,
          color: CustomFlowTheme.of(context).primary,
          textStyle: CustomFlowTheme.of(context).labelLarge.override(
              color: CustomFlowTheme.of(context).info, fontSize: 0),
          elevation: 0,
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(_Dims.addBtnRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// COUNT BADGE
// ---------------------------------------------------------------------------
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.countBoxPaddingH, _Dims.countBoxPaddingV,
        _Dims.countBoxPaddingH, _Dims.countBoxPaddingV,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(_Dims.countBoxRadius),
          border: Border.all(color: CustomFlowTheme.of(context).alternate),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(_Dims.countBoxPaddingV),
          child: Text(
            '$label: $count',
            style: CustomFlowTheme.of(context).labelLarge,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PEOPLE SLIVER LIST
// This is where _buildDeleteRequest / _buildPromoteRequest are called.
// Both functions are file-scoped (same file) so they are naturally in scope.
// ---------------------------------------------------------------------------
class _PeopleListSliver extends StatelessWidget {
  const _PeopleListSliver({required this.model, required this.config});

  final TournamentPeopleModel model;
  final PeoplePageConfig config;

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: model.pagingController,
      builder: (context, state, fetchNextPage) => PagedSliverList<int, EnrollmentsRecord>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<EnrollmentsRecord>(
          itemBuilder: (context, item, index) => TournamentPeopleCardWidget(
            key: ValueKey('people_${item.uid}_$index'),
            index: index,
            listType: config.listType,
            promote: config.canPromote,
            editable: model.isTournamentEditable,
            enrollment: item,
            tournamentId: model.tournamentId,
            onDelete: () => context.goNamed(
              'DialogDeletePerson',
              pathParameters: {'tournamentId': model.tournamentId}.withoutNulls,
              extra: {
                'req': _buildDeleteRequest(model, item, config.listType),
              },
            ),
            onPromote: () => context.goNamed(
              'DialogPromotePerson',
              pathParameters: {'tournamentId': model.tournamentId}.withoutNulls,
              extra: {
                'req': _buildPromoteRequest(model, item),
              },
            ),
          ),
          firstPageProgressIndicatorBuilder: (_) =>
          const GenericLoadingWidget(),
          noItemsFoundIndicatorBuilder: (_) => const NoContentCard(
            type: NoContentType.people,
            active: true,
            phrase: 'Nessun iscritto in questa lista',
          ),
          newPageProgressIndicatorBuilder: (_) =>
          const Center(child: CircularProgressIndicator()),
        ),
        shrinkWrapFirstPageIndicators: true,
      ),
    );
  }
}