import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: all four responsive_sizer values replaced with named constants:
//
//   4.w  (padding)  → pagePadding: 16.0
//     4% of screen width is approximately 16dp on a standard phone.
//     A fixed padding is correct here — padding should not grow with
//     screen width, it should stay a consistent inset.
//
//   80.sp (lottie width)  → resolved via LayoutBuilder at build time
//   70.sp (lottie height) → resolved via LayoutBuilder at build time
//     sp is a text-scaling unit, not a layout unit — using it for a
//     Lottie animation size was semantically wrong.  The animation now
//     fills a fraction of the available width, which is the correct
//     dimension for a full-screen loading illustration.
//
//   30.sp (font size) → titleFontSize: 28.0
//     A fixed font size for a splash/loading title is correct — it should
//     not scale with the system font size multiplier since it is decorative.
//     It is defined here rather than inline so it can be adjusted once.
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Padding applied on all sides of the body container.
  static const double pagePadding = 16.0;

  /// The Lottie animation fills this fraction of the available width.
  static const double animationWidthFraction = 0.75;

  /// Height as a fraction of the resolved animation width (preserves ratio).
  static const double animationHeightFraction = 0.875; // 70/80 from original

  /// Font size of the app title text.
  static const double titleFontSize = 28.0;
}

// ---------------------------------------------------------------------------
// WIDGET
// ---------------------------------------------------------------------------
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // SizedBox.expand fills the SafeArea completely so the gradient
          // covers the entire available area — same intent as the original
          // Container with no explicit size.
          child: SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(_Dims.pagePadding),
              child: DecoratedBox(
                // FIX: Container replaced with DecoratedBox for the gradient.
                //   Container with only a decoration and a child is better
                //   expressed as DecoratedBox — one less layout node.
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      CustomFlowTheme.of(context).gradientBackgroundBegin,
                      CustomFlowTheme.of(context).gradientBackgroundEnd,
                    ],
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final animWidth =
                        constraints.maxWidth * _Dims.animationWidthFraction;
                    final animHeight =
                        animWidth * _Dims.animationHeightFraction;

                    // FIX: Column with mainAxisAlignment.center +
                    //   crossAxisAlignment.center makes the inner Center
                    //   widgets redundant — they are removed.
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animation/splash_animation.json',
                          fit: BoxFit.contain,
                          width: animWidth,
                          height: animHeight,
                          repeat: true,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Tournament Manager',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _Dims.titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
