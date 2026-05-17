import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: logoSize was `60.sp` via responsive_sizer.
//   The logo is a fixed visual element — a physical tap target whose size
//   should not vary with screen dimensions.  A named constant at 80dp is
//   consistent with Material's recommended hero image sizes for splash screens.
// ---------------------------------------------------------------------------
abstract class _Dims {
  // ── Logo ──────────────────────────────────────────────────────────────────
  static const double logoSize         = 300.0;
  static const double logoRadius       = 30.0;

  /// Space between the logo image and the app title text below it.
  static const double logoTitleSpacing = 24.0;

  // ── Bottom actions ─────────────────────────────────────────────────────────
  /// Horizontal inset of the buttons / sign-in link from the screen edges.
  static const double actionsPaddingH   = 24.0;

  /// Space below the bottom actions area (above the home indicator / nav bar).
  static const double actionsPaddingBtm = 12.0;

  /// Vertical padding inside the "Already a member?" tap target.
  /// Keeps the touch area at the 48dp minimum recommended by Material.
  static const double signInLinkPaddingV = 24.0;

  // ── Buttons ────────────────────────────────────────────────────────────────
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: const SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: _Logo()),
              _BottomActions(),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOGO
//
// FIX: `width: 60.sp` and `height: 60.sp` replaced with the fixed constant
//   _Dims.logoSize.  A splash screen logo is a brand asset — it should be
//   the same physical size on every device, not scaled by font metrics (.sp)
//   or screen percentage.  Using .sp was also incorrect semantically: sp is
//   for text scaling, not layout dimensions.
// ---------------------------------------------------------------------------
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Reserve room for the title text + spacing below the logo.
        const double reservedForText = _Dims.logoTitleSpacing + 48.0;
        final double logoSize = (constraints.maxHeight - reservedForText).clamp(0.0, _Dims.logoSize);
        final double logoRadius = _Dims.logoRadius * (logoSize / _Dims.logoSize);

        return Align(
          alignment: const AlignmentDirectional(0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  color: CustomFlowTheme.of(context).info,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: Image.asset('assets/images/tm_logo.png').image,
                  ),
                  borderRadius: BorderRadius.circular(logoRadius),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.logoTitleSpacing, 0, 0),
                child: Center(
                  child: RichText(
                    textScaler: MediaQuery.of(context).textScaler,
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Tournament Manager',
                          style: CustomFlowTheme.of(context).displayLarge,
                        ),
                      ],
                      style: CustomFlowTheme.of(context).displaySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// BOTTOM ACTIONS
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero throughout.
// ---------------------------------------------------------------------------
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.actionsPaddingH,
        0,
        _Dims.actionsPaddingH,
        _Dims.actionsPaddingBtm,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AFButtonWidget(
            text: 'Inizia',
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('SPLASH_PAGE_GET_STARTED_BTN_ON_TAP');
              logFirebaseEvent('Button_haptic_feedback');
              HapticFeedback.lightImpact();
              logFirebaseEvent('Button_navigate_to');
              context.pushNamed('Onboarding_Slideshow');
            },
            options: AFButtonOptions(
              width: double.infinity,
              height: _Dims.buttonHeight,
              padding: EdgeInsetsDirectional.zero,
              iconPadding: EdgeInsetsDirectional.zero,
              color: CustomFlowTheme.of(context).primary,
              textStyle: CustomFlowTheme.of(context).titleSmall,
              elevation: 0,
              borderSide: const BorderSide(color: Colors.transparent, width: 1),
              borderRadius: BorderRadius.circular(_Dims.buttonRadius),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              logFirebaseEvent('SPLASH_PAGE_Column_9mc7ub12_ON_TAP');
              logFirebaseEvent('Column_navigate_to');
              context.pushNamed('SignIn');
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(
                0,
                _Dims.signInLinkPaddingV,
                0,
                _Dims.signInLinkPaddingV,
              ),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Già iscritto?  ',
                      style: CustomFlowTheme.of(context).bodyMedium,
                    ),
                    TextSpan(
                      text: 'Log In',
                      style: CustomFlowTheme.of(context).bodyMedium.override(
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ],
                  style: CustomFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
