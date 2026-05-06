import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_registered_people/tournament_registered_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../tournament_people_shared_widget.dart';

class TournamentRegisteredPeopleWidget extends StatelessWidget {
  const TournamentRegisteredPeopleWidget({super.key});

  static const _config = PeoplePageConfig(
    listType: ListType.registered,
    countLabel: 'Registrati',
    canPromote: false,
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
          child: Selector<TournamentRegisteredPeopleModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_registered_people_widget.dart');
                return true;
              }());
              return isLoading
                  ? const PeopleLoadingBody()
                  : const PeopleBody<TournamentRegisteredPeopleModel>(config: _config,);
            },
          ),
        ),
      ),
    );
  }
}