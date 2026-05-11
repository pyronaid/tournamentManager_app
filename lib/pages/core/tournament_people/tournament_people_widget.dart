import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_container.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_general_people_model.dart';

import '../../../components/fab_expandable/fab_expandable_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double fabDistance = 60.0;
}

// ---------------------------------------------------------------------------
// TournamentPeopleWidget
// Kept as StatefulWidget because AutomaticKeepAliveClientMixin requires State.
// All side-effect logic (page reset on available-pages change) lives in
// TournamentGeneralPeopleModel._onTournamentChanged so the build method
// is free of mutations.
// ---------------------------------------------------------------------------

class TournamentPeopleWidget extends StatefulWidget {
  const TournamentPeopleWidget({super.key});

  @override
  State<TournamentPeopleWidget> createState() => _TournamentPeopleWidgetState();
}

class _TournamentPeopleWidgetState extends State<TournamentPeopleWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive {
    // FIX: delegate the keep-alive decision to a dedicated model property
    //   instead of calling a computation method here.  The model is read
    //   (not watched) because wantKeepAlive is not a build-time value —
    //   it is evaluated by the mixin infrastructure independently of builds.
    return context.read<TournamentGeneralPeopleModel>().keepPageAlive;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Selector<TournamentGeneralPeopleModel, bool>(
      selector: (_, m) => m.isLoading,
      builder: (_, isLoading, __) {
        assert(() {
          debugPrint('[BUILD] tournament_people_widget.dart');
          return true;
        }());

        if (isLoading) return const Center(child: CircularProgressIndicator());

        final model = context.read<TournamentGeneralPeopleModel>();
        return _PeopleScaffold(model: model);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// PEOPLE SCAFFOLD
//
// Extracted from the inline builder so:
//   1. The model is received as an explicit parameter (no context.read in
//      build).
//   2. The FAB visibility is gated on canInteractOn — consistent with the
//      rounds page pattern where the FAB is hidden when the user cannot
//      interact (e.g. tournament not in the right state).
//   3. _pageForType is co-located with the widget that uses it.
// ---------------------------------------------------------------------------

class _PeopleScaffold extends StatelessWidget {
  const _PeopleScaffold({required this.model});

  final TournamentGeneralPeopleModel model;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // FIX: FAB is only shown when the user is allowed to interact.
      //   Previously it was always visible regardless of tournament state,
      //   which could let users trigger actions (add/promote/remove people)
      //   when the tournament was closed or in a non-editable state.
      floatingActionButton: model.canInteractOn
          ? FabExpandableWidget(
        distance: _Dims.fabDistance,
        children: model.buildFabActions(),
      )
          : null,
      body: PageView.builder(
        controller: model.pageController,
        itemCount: model.availablePages.length,
        onPageChanged: model.onPageChanged,
        itemBuilder: (context, index) =>
            _pageForType(model.availablePages[index]),
      ),
    );
  }

  Widget _pageForType(ListType pageType) {
    return switch (pageType) {
      ListType.registered    => const TournamentRegisteredPeopleContainer(),
      ListType.preregistered => const TournamentPreregisteredPeopleContainer(),
      ListType.waiting       => const TournamentWaitingPeopleContainer(),
    };
  }
}
