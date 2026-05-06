// sub_page_waiting_people/tournament_waiting_people_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../../../../backend/schema/enrollments_record.dart';
import '../tournament_people_shared_widget.dart';

class TournamentWaitingPeopleWidget extends StatelessWidget {
  const TournamentWaitingPeopleWidget({super.key});

  static const _config = PeoplePageConfig(
    listType: ListType.waiting,
    countLabel: "In lista d'attesa",
    canPromote: true,
    addRoute: 'AddPeople',
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<TournamentWaitingPeopleModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_waiting_people_widget.dart');
                return true;
              }());
              return isLoading
                  ? const PeopleLoadingBody()
                  : const PeopleBody<TournamentWaitingPeopleModel>(config: _config,);
            },
          ),
        ),
      ),
    );
  }
}