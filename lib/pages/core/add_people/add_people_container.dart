import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';
import 'add_people_model.dart';
import 'add_people_widget.dart';

class AddPeopleContainer extends StatefulWidget {
  const AddPeopleContainer({
    super.key,
    required this.tournamentsRef,
    required this.listType,
  });

  final String? tournamentsRef;
  final String listType;

  @override
  State<AddPeopleContainer> createState() => _AddPeopleContainerState();
}

class _AddPeopleContainerState extends State<AddPeopleContainer> {
  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AddPeople'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AddPeopleModel(listType: getListTypeByName(widget.listType), tournamentsRef: widget.tournamentsRef),
      builder: (context, child) {
        return const AddPeopleWidget();
      }
    );
  }
}
