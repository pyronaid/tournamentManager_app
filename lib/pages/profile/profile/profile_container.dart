import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_model.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_widget.dart';

class ProfileContainer extends StatelessWidget {
  const ProfileContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileModel>(
      create: (_) {
        return ProfileModel();
      },
      child: const ProfileWidget(),
    );
  }
}
