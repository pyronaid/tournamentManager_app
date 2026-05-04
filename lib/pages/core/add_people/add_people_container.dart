import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../backend/schema/enrollments_record.dart';
import 'add_people_model.dart';
import 'add_people_widget.dart';

class AddPeopleContainer extends StatelessWidget {
  const AddPeopleContainer({
    super.key,
    required this.listType,
  });

  final String listType;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AddPeopleModel>(
      create: (_) => AddPeopleModel(listType: getListTypeByName(listType)),
      child: const AddPeopleWidget(),
    );
  }
}
