import 'package:flutter/material.dart';

class OnboardingSlideshowWidget extends StatelessWidget {
  const OnboardingSlideshowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Text(
          "ONBOARDING",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
      ),
    );
  }
}