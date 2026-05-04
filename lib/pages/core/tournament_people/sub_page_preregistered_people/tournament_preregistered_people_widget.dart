import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../../../../app_flow/app_flow_widgets.dart';
import '../../../../backend/firebase_analytics/analytics.dart';
import '../../../../components/generic_loading/generic_loading_widget.dart';
import '../../../../components/no_tournament_people_card/no_tournament_people_card_widget.dart';
import '../../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../../components/tournament_people_card/tournament_people_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
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

class TournamentPreregisteredPeopleWidget extends StatelessWidget {
  const TournamentPreregisteredPeopleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<TournamentPreregisteredPeopleModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_preregistered_people_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();
              return const _PreregisteredBody();
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
// PREREGISTERED BODY
// context.read is correct: only rebuilds when isLoading flips (Selector above).
// ---------------------------------------------------------------------------
class _PreregisteredBody extends StatelessWidget {
  const _PreregisteredBody();

  @override
  Widget build(BuildContext context) {
    final model = context.read<TournamentPreregisteredPeopleModel>();

    return RefreshIndicator(
      onRefresh: model.onRefresh,
      child: CustomScrollView(
        slivers: [
          _PeopleAppBar(model: model),
          SliverPadding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              _Dims.listPaddingH, _Dims.listPaddingV,
              _Dims.listPaddingH, _Dims.listPaddingV,
            ),
            sliver: _PeopleListSliver(model: model),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PEOPLE APP BAR
// ---------------------------------------------------------------------------
class _PeopleAppBar extends StatelessWidget {
  const _PeopleAppBar({required this.model});

  final TournamentPreregisteredPeopleModel model;

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
            _SearchAndAddRow(model: model),
            Selector<TournamentPreregisteredPeopleModel, int>(
              selector: (_, m) => m.countElements,
              builder: (_, count, __) => _CountBadge(
                label: 'Pre iscritti',
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
  const _SearchAndAddRow({required this.model});

  final TournamentPreregisteredPeopleModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: _Dims.searchBoxPercent.w,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _Dims.searchBoxPaddingH),
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
                'AddPeople', context.mounted,
                pathParameters: {
                  'tournamentId': model.tournamentModel.tournamentId,
                }.withoutNulls,
                extra: {
                  'listType': ListType.preregistered.name,
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
          textStyle: CustomFlowTheme.of(context)
              .labelLarge
              .override(color: CustomFlowTheme.of(context).info, fontSize: 0),
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
// ---------------------------------------------------------------------------
class _PeopleListSliver extends StatelessWidget {
  const _PeopleListSliver({required this.model});

  final TournamentPreregisteredPeopleModel model;

  @override
  Widget build(BuildContext context) {
    return PagedSliverList<int, EnrollmentsRecord>(
      pagingController: model.pagingController,
      builderDelegate: PagedChildBuilderDelegate<EnrollmentsRecord>(
        itemBuilder: (context, item, index) => TournamentPeopleCardWidget(
          key: ValueKey('people_${item.uid}_$index'),
          userRef: item,
          indexo: index,
          listType: ListType.preregistered,
          peopleModel: model,
          promote: true,
          tournamentRef: model.tournamentModel.tournamentId!,
          editable: model.isTournamentEditable,
        ),
        firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
        noItemsFoundIndicatorBuilder: (_) => const NoTournamentPeopleCardWidget(
          active: true,
          phrase: 'Nessun iscritto in questa lista',
        ),
        newPageProgressIndicatorBuilder: (_) =>
            const Center(child: CircularProgressIndicator()),
      ),
      shrinkWrapFirstPageIndicators: true,
    );
  }
}
