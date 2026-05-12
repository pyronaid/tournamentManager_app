// components/generic_loading/generic_loading_widget.dart

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
//   Using a screen-width percentage for a loading animation is fragile:
//   on a narrow phone (320dp) 25% = 80dp (too small to see clearly);
//   on a tablet (800dp) 25% = 200dp (oversized for a spinner).
//
//   The new approach uses LayoutBuilder to resolve the available width at
//   build time and caps the animation with animationFraction (25% of
//   available width) plus a maxSize ceiling so it never grows too large
//   on wide screens.  The result is visually identical on phones but
//   correctly bounded on tablets and foldables.
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// The animation fills this fraction of the available width.
  static const double animationFraction = 0.25;

  /// Hard cap so the spinner never grows oversized on large screens.
  static const double animationMaxSize  = 120.0;
}

/// Full-screen centered loading animation.
/// Lottie manages its own playback state — no StatefulWidget needed.
class GenericLoadingWidget extends StatelessWidget {
  const GenericLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = (constraints.maxWidth * _Dims.animationFraction)
              .clamp(0.0, _Dims.animationMaxSize);
          return Lottie.asset(
            'assets/animation/loading.json',
            fit: BoxFit.contain,
            width: size,
            height: size,
            repeat: true,
          );
        },
      ),
    );
  }
}
