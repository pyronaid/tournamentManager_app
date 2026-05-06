import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

abstract class _Dims {
  static const double logoRadius = 30.0;
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
}

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

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.sp,
            height: 60.sp,
            decoration: BoxDecoration(
              color: CustomFlowTheme.of(context).primary,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: Image.asset('assets/images/petsy_logo_paw.png').image,
              ),
              borderRadius: BorderRadius.circular(_Dims.logoRadius),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
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
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          AFButtonWidget(
            text: 'Get Started',
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
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              color: CustomFlowTheme.of(context).primary,
              textStyle: CustomFlowTheme.of(context).titleSmall,
              elevation: 0.0,
              borderSide: const BorderSide(color: Colors.transparent, width: 1.0),
              borderRadius: BorderRadius.circular(_Dims.buttonRadius),
            ),
          ),
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              logFirebaseEvent('SPLASH_PAGE_Column_9mc7ub12_ON_TAP');
              logFirebaseEvent('Column_navigate_to');
              context.pushNamed('SignIn');
            },
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 24.0),
              child: RichText(
                textScaler: MediaQuery.of(context).textScaler,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Already a member?  ',
                      style: CustomFlowTheme.of(context).bodyMedium,
                    ),
                    TextSpan(
                      text: 'Sign In',
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
