import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/profile/about_us/about_us_model.dart';
import 'package:tournamentmanager/pages/profile/about_us/about_us_widget.dart';

class AboutUsContainer extends StatelessWidget {
  const AboutUsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AboutUsModel>(
      create: (_) {
        return AboutUsModel();
      },
      child: const AboutUsWidget(),
    );
  }
}
