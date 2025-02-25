import 'package:flutter/material.dart';

import '../app_flow/app_flow_util.dart';

class Placeholder2Widget extends StatelessWidget {
  const Placeholder2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    for (final match in  GoRouter.of(context).routerDelegate.currentConfiguration.matches) {
      print('hellooooooooooooooooooooooooo2_   ' + match.matchedLocation); // Prints each page in the stack
    }

    return const Scaffold(
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Text(
          "Home Page 2",
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent),
        ),
      ),
    );
  }
}