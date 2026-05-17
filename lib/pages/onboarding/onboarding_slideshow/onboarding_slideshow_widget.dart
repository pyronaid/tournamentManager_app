import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_slideshow/onboarding_slideshow_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_page_indicator;

import '../../../components/standard_graphics/standard_graphics_widgets.dart';


// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
  static const double dotRadius    = 10.0;
  static const double dotWidth     = 10.0;
  static const double dotSpacing   = 10.0;
  static const double dotExpansion = 3.0;

  // ── Slide image ────────────────────────────────────────────────────────────
  /// Aspect ratio for the slide illustration.
  /// Each slide fills its available Column height via Expanded + BoxFit.contain,
  /// so no explicit height is needed — but we constrain the image's own
  /// aspect ratio so it never distorts on wide screens.
  static const double slideImageAspectRatio = 4 / 3;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
class OnboardingSlideshowWidget extends StatefulWidget {
  const OnboardingSlideshowWidget({super.key});

  @override
  State<OnboardingSlideshowWidget> createState() =>
      _OnboardingSlideshowWidgetState();
}

class _OnboardingSlideshowWidgetState
    extends State<OnboardingSlideshowWidget> {
  final animationsMap = <String, AnimationInfo>{};

  // FIX: model resolved once in initState — not inside descendant build().
  late final OnboardingSlideshowModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<OnboardingSlideshowModel>();
    animationsMap.addAll({
      'textOnPageLoadAnimation1': standardAnimationInfo(context),
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
      'textOnPageLoadAnimation2': standardAnimationInfo(context),
      'textOnPageLoadAnimation3': standardAnimationInfo(context),
      'imageOnPageLoadAnimation2': standardAnimationInfo(context),
      'textOnPageLoadAnimation4': standardAnimationInfo(context),
      'textOnPageLoadAnimation5': standardAnimationInfo(context),
      'imageOnPageLoadAnimation3': standardAnimationInfo(context),
      'textOnPageLoadAnimation6': standardAnimationInfo(context),
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const _Header(),
                      Expanded(
                        child: _PageCarousel(
                          model: _model,
                          animationsMap: animationsMap,
                          onDotClicked: () => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _ContinueButton(model: _model),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const CustomAppbarWidget(backButton: true);
  }
}

// ---------------------------------------------------------------------------
// PAGE CAROUSEL
//
// FIX: context.read<OnboardingSlideshowModel>() removed from build() —
//   model passed as constructor parameter.
//
// FIX: SizedBox(height: 500) replaced with SizedBox.expand().
//   The parent already wraps this widget in an Expanded, so the carousel
//   fills the available space naturally without a hardcoded pixel height
//   that would overflow on small devices (e.g. iPhone SE at ~650dp).
// ---------------------------------------------------------------------------
class _PageCarousel extends StatelessWidget {
  const _PageCarousel({
    required this.model,
    required this.animationsMap,
    required this.onDotClicked,
  });

  final OnboardingSlideshowModel model;
  final Map<String, AnimationInfo> animationsMap;
  final VoidCallback onDotClicked;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
            child: PageView(
              controller: model.pageViewController,
              scrollDirection: Axis.horizontal,
              children: [
                _SlideItem(
                  title: 'Cerca ed iscriviti\nai tuoi tornei preferiti',
                  imagePath: 'assets/images/logo_slideshow_1.png',
                  description:
                      'Monitora tutti i tornei passati e futuri per tutti i giochi a cui sei interessato. '
                      'Cerca con il finder il tuo torneo oppure organizzalo tu stesso!' ,
                  titleAnim: animationsMap['textOnPageLoadAnimation1']!,
                  imageAnim: animationsMap['imageOnPageLoadAnimation1']!,
                  descAnim: animationsMap['textOnPageLoadAnimation2']!,
                  imageFit: BoxFit.fill,
                ),
                _SlideItem(
                  title: 'Gestione del torneo \nend to end',
                  imagePath: 'assets/images/logo_slideshow_2.png',
                  description:
                      'La gestione del torneo è tutta all\'interno dell\'app. '
                      'Dalla preioscrizione, allo svolgimento dei turni, alla possibilità di vedere le classifiche turno per turno con il relativo tie break. '
                      'Anche le news e le liste possono essere gestite da qui!',
                  titleAnim: animationsMap['textOnPageLoadAnimation3']!,
                  imageAnim: animationsMap['imageOnPageLoadAnimation2']!,
                  descAnim: animationsMap['textOnPageLoadAnimation4']!,
                ),
                _SlideItem(
                  title: 'ELO\nin arrivo a breve...',
                  imagePath: 'assets/images/logo_slideshow_3.png',
                  description:
                      'Scala la classifica e ottieni i migliori rank di ogni stagione.',
                  titleAnim: animationsMap['textOnPageLoadAnimation5']!,
                  imageAnim: animationsMap['imageOnPageLoadAnimation3']!,
                  descAnim: animationsMap['textOnPageLoadAnimation6']!,
                ),
              ],
            ),
          ),
          Align(
            alignment: const AlignmentDirectional(0, 1),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: smooth_page_indicator.SmoothPageIndicator(
                controller: model.pageViewController,
                count: 3,
                axisDirection: Axis.horizontal,
                onDotClicked: (i) async {
                  await model.pageViewController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                  onDotClicked();
                },
                effect: smooth_page_indicator.ExpandingDotsEffect(
                  expansionFactor: _Dims.dotExpansion,
                  spacing: _Dims.dotSpacing,
                  radius: _Dims.dotRadius,
                  dotWidth: _Dims.dotWidth,
                  dotHeight: _Dims.dotWidth,
                  dotColor: CustomFlowTheme.of(context).secondaryText,
                  activeDotColor: CustomFlowTheme.of(context).primaryText,
                  paintStyle: PaintingStyle.fill,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SLIDE ITEM
// ---------------------------------------------------------------------------
class _SlideItem extends StatelessWidget {
  const _SlideItem({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.titleAnim,
    required this.imageAnim,
    required this.descAnim,
    this.imageFit = BoxFit.contain,
  });

  final String title;
  final String imagePath;
  final String description;
  final AnimationInfo titleAnim;
  final AnimationInfo imageAnim;
  final AnimationInfo descAnim;
  final BoxFit imageFit;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: CustomFlowTheme.of(context).displaySmall,
          ).animateOnPageLoad(titleAnim),
        ),
        // Flexible(loose) so AspectRatio receives loose constraints and can
        // derive its height from the width. Expanded gives tight constraints
        // (min==max), which makes AspectRatio skip the ratio and fill the box.
        Flexible(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            child: AspectRatio(
              aspectRatio: _Dims.slideImageAspectRatio,
              child: Image.asset(
                imagePath,
                fit: imageFit,
              ).animateOnPageLoad(imageAnim),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: CustomFlowTheme.of(context).labelLarge,
          ).animateOnPageLoad(descAnim),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CONTINUE BUTTON
//
// FIX: context.read inside build() removed — model passed as parameter.
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.model});

  final OnboardingSlideshowModel model;

  Future<void> _handleContinue(BuildContext context) async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('ONBOARDING_SLIDESHOW_CONTINUE_BTN_ON_TAP');
    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();

    if (model.pageViewCurrentIndex == 2) {
      logFirebaseEvent('Button_navigate_to');
      context.pushNamed('Onboarding_CreateAccount');
    } else {
      logFirebaseEvent('Button_page_view');
      await model.pageViewController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 12),
      child: AFButtonWidget(
        onPressed: () => _handleContinue(context),
        text: 'Continua',
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
        showLoadingIndicator: false,
      ),
    );
  }
}
