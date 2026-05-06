import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';

import '../../../components/standard_graphics/standard_graphics_widgets.dart';

abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
}

class OnboardingVerifyMailSuccessWidget extends StatefulWidget {
  const OnboardingVerifyMailSuccessWidget({super.key});

  @override
  State<OnboardingVerifyMailSuccessWidget> createState() =>
      _OnboardingVerifyMailSuccessWidgetState();
}

class _OnboardingVerifyMailSuccessWidgetState
    extends State<OnboardingVerifyMailSuccessWidget> {
  late String? _email;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _email = currentUserEmail;
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
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
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Header(),
                  _Content(
                    email: _email,
                    animationsMap: animationsMap,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const CustomAppbarWidget(backButton: true);
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.email, required this.animationsMap});
  final String? email;
  final Map<String, AnimationInfo> animationsMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
          child: Center(
            child: Lottie.asset(
              'assets/animation/confirm_animation.json',
              fit: BoxFit.cover,
              width: 80.w,
              height: 60.w,
              repeat: true,
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Text(
            'Account verificato con successo!',
            style: CustomFlowTheme.of(context).headlineSmall,
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Center(
            child: Text(
              email ?? '@@NO_MAIL_PASSED@@',
              style: CustomFlowTheme.of(context).titleSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Center(
            child: Text(
              'Benvenuto nell\'app di TournamentManager. Qui potrai gestire i tuoi tornei, vedere lo storico e iscriverti ai prossimi eventi dei tuoi giochi preferiti.',
              style: CustomFlowTheme.of(context).titleSmall.override(
                    color: CustomFlowTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: AFButtonWidget(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('ONBOARDING_VERIFY_MAIL_SUCCESS_CONTINUE');
              logFirebaseEvent('Button_haptic_feedback');
              HapticFeedback.lightImpact();
              logFirebaseEvent('Button_navigate_to');
              context.goNamedAuth('Dashboard', context.mounted);
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
          ),
        ),
      ],
    );
  }
}
