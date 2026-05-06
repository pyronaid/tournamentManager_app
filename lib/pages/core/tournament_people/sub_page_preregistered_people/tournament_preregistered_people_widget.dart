import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../tournament_people_shared_widget.dart';

class TournamentPreregisteredPeopleWidget extends StatelessWidget {
  const TournamentPreregisteredPeopleWidget({super.key});

  static const _config = PeoplePageConfig(
    listType: ListType.preregistered,
    countLabel: 'Pre iscritti',
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
          child: Selector<TournamentPreregisteredPeopleModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_preregistered_people_widget.dart');
                return true;
              }());
              return isLoading
                  ? const PeopleLoadingBody()
                  : const PeopleBody<TournamentPreregisteredPeopleModel>(config: _config,);
            },
          ),
        ),
      ),
    );
  }
}