import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_slideshow/onboarding_slideshow_model.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_page_indicator;

import '../../../components/standard_graphics/standard_graphics_widgets.dart';

abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
  static const double dotRadius = 10.0;
  static const double dotWidth = 10.0;
  static const double dotSpacing = 10.0;
  static const double dotExpansion = 3.0;
}

class OnboardingSlideshowWidget extends StatefulWidget {
  const OnboardingSlideshowWidget({super.key});

  @override
  State<OnboardingSlideshowWidget> createState() =>
      _OnboardingSlideshowWidgetState();
}

class _OnboardingSlideshowWidgetState
    extends State<OnboardingSlideshowWidget> {
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    context.read<OnboardingSlideshowModel>().initContextVars(context);
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
                child: Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _Header(onUpdate: () => setState(() {})),
                        Expanded(
                          child: _PageCarousel(
                            animationsMap: animationsMap,
                            onDotClicked: () => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const _ContinueButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onUpdate});
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return wrapWithModel(
      model: context.read<OnboardingSlideshowModel>().customAppbarModel,
      updateCallback: onUpdate,
      child: CustomAppbarWidget(
        backButton: true,
        actionButton: false,
        actionButtonAction: () async {},
        optionsButtonAction: () async {},
      ),
    );
  }
}

class _PageCarousel extends StatelessWidget {
  const _PageCarousel({
    required this.animationsMap,
    required this.onDotClicked,
  });
  final Map<String, AnimationInfo> animationsMap;
  final VoidCallback onDotClicked;

  @override
  Widget build(BuildContext context) {
    final model = context.read<OnboardingSlideshowModel>();
    return SizedBox(
      width: double.infinity,
      height: 500,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
            child: PageView(
              controller: model.pageViewController,
              scrollDirection: Axis.horizontal,
              children: [
                _SlideItem(
                  title: 'Storico sanitario\ndel tuo pet',
                  imagePath: 'assets/images/logo_slideshow_1.png',
                  description:
                      'Crea lo storico sanitario del tuo "pet" così che il tuo veterinario abbia sempre il contesto di tutto ciò che ha fatto',
                  titleAnim: animationsMap['textOnPageLoadAnimation1']!,
                  imageAnim: animationsMap['imageOnPageLoadAnimation1']!,
                  descAnim: animationsMap['textOnPageLoadAnimation2']!,
                  imageFit: BoxFit.fill,
                ),
                _SlideItem(
                  title: 'Foto gallery \nperiodica',
                  imagePath: 'assets/images/logo_slideshow_2.png',
                  description:
                      'Carica delle foto cadenzate per vedere come cresce nel tempo.',
                  titleAnim: animationsMap['textOnPageLoadAnimation3']!,
                  imageAnim: animationsMap['imageOnPageLoadAnimation2']!,
                  descAnim: animationsMap['textOnPageLoadAnimation4']!,
                ),
                _SlideItem(
                  title: 'Reminder personalizzati\nper cure e appuntamenti',
                  imagePath: 'assets/images/logo_slideshow_1.png',
                  description:
                      'L\'app è il tuo organizer personale per ricordarti delle somministrazioni e degli appuntamenti del veterinario.',
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
            style: CustomFlowTheme.of(context).displaySmall,
          ).animateOnPageLoad(titleAnim),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
          child: Image.asset(
            imagePath,
            height: 35.h,
            fit: imageFit,
          ).animateOnPageLoad(imageAnim),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: CustomFlowTheme.of(context).labelLarge,
          ).animateOnPageLoad(descAnim),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: AFButtonWidget(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            logFirebaseEvent('ONBOARDING_SLIDESHOW_CONTINUE_BTN_ON_TAP');
            logFirebaseEvent('Button_haptic_feedback');
            HapticFeedback.lightImpact();
            final model = context.read<OnboardingSlideshowModel>();
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
          },
          text: 'Continua',
          options: AFButtonOptions(
            width: double.infinity,
            height: _Dims.buttonHeight,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            color: CustomFlowTheme.of(context).primary,
            textStyle: CustomFlowTheme.of(context).titleSmall,
            elevation: 0,
            borderSide: const BorderSide(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(_Dims.buttonRadius),
          ),
          showLoadingIndicator: false,
        ),
      ),
    );
  }
}
