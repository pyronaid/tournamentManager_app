import 'package:flutter/material.dart';

class OnboardingSlideshowModel extends ChangeNotifier {
  final PageController pageViewController = PageController(initialPage: 0);

  int get pageViewCurrentIndex =>
      pageViewController.hasClients && pageViewController.page != null
          ? pageViewController.page!.round()
          : 0;

  @override
  void dispose() {
    pageViewController.dispose();
    super.dispose();
  }
}
