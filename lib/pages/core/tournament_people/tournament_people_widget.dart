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
// All side-effect logic (page reset on available-pages change) has been moved
// into TournamentGeneralPeopleModel._onTournamentChanged so the build method
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
    return context.read<TournamentGeneralPeopleModel>().getTotalPartecipants() < 100;
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

        return Scaffold(
          floatingActionButton: FabExpandableWidget(
            distance: _Dims.fabDistance,
            children: model.buildFabActions(),
          ),
          body: PageView.builder(
            controller: model.pageController,
            itemCount: model.availablePages.length,
            onPageChanged: model.onPageChanged,
            itemBuilder: (context, index) =>
                _pageForType(model.availablePages[index]),
          ),
        );
      },
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
