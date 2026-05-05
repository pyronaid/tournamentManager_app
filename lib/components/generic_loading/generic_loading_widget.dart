// components/generic_loading/generic_loading_widget.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

/// Full-screen centered loading animation.
/// Lottie manages its own playback state — no StatefulWidget needed.
class GenericLoadingWidget extends StatelessWidget {
  const GenericLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        'assets/animation/loading.json',
        fit: BoxFit.cover,
        width: 25.w,
        height: 25.w,
        repeat: true,
      ),
    );
  }
}
