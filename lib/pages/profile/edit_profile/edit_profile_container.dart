import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/profile/edit_profile/edit_profile_model.dart';
import 'package:tournamentmanager/pages/profile/edit_profile/edit_profile_widget.dart';

class EditProfileContainer extends StatelessWidget {
  const EditProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<EditProfileModel>(
      create: (_) {
        return EditProfileModel();
      },
      child: const EditProfileWidget(),
    );
  }
}