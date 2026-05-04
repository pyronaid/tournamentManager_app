import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/profile/edit_preferences/edit_preferences_model.dart';
import 'package:tournamentmanager/pages/profile/edit_preferences/edit_preferences_widget.dart';

class EditPreferencesContainer extends StatelessWidget {
  const EditPreferencesContainer({super.key, required this.page});

  final int? page;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditPreferencesModel>(
      create: (_) {
        return EditPreferencesModel();
      },
      child: EditPreferencesWidget(page: page),
    );
  }
}
