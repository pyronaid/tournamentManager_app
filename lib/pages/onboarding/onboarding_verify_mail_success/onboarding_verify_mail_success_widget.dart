
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';

import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import 'onboarding_verify_mail_success_model.dart';

class OnboardingVerifyMailSuccessWidget extends StatefulWidget {
  const OnboardingVerifyMailSuccessWidget({super.key});

  @override
  State<OnboardingVerifyMailSuccessWidget> createState() =>
      _OnboardingVerifyMailSuccessWidgetState();
}

class _OnboardingVerifyMailSuccessWidgetState extends State<OnboardingVerifyMailSuccessWidget> {
  late OnboardingVerifyMailSuccessModel _model;
  late String? _email;

  final animationsMap = <String, AnimationInfo>{};
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _email = currentUserEmail;
    _model = createModel(context, () => OnboardingVerifyMailSuccessModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_VerifyMailSuccess'});
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
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
                  ////////////////
                  //CUSTOM BAR
                  /////////////////
                  wrapWithModel(
                    model: _model.customAppbarModel,
                    updateCallback: () => setState(() {}),
                    child: CustomAppbarWidget(
                      backButton: true,
                      actionButton: false,
                      actionButtonAction: () async {},
                      optionsButtonAction: () async {},
                    ),
                  ),
                  ////////////////
                  //IMAGE LOGO 
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 24),
                    child: Center(
                      child: Lottie.asset(
                        'assets/animation/confirm_animation.json',
                        fit: BoxFit.cover,
                        width: 80.w, // Adjust the width and height as needed
                        height: 60.w,
                        repeat: true, // Set to true if you want the animation to loop
                      ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!),
                    ),
                  ),
                  ////////////////
                  //PAGE TITLE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Text(
                      'Account verificato con successo!',
                      style: CustomFlowTheme.of(context).headlineSmall,
                    ),
                  ),
                  ////////////////
                  //MAIL INDICATION 
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Center(
                      child: Text(
                        _email ?? "@@NO_MAIL_PASSED@@",
                        style: CustomFlowTheme.of(context).titleSmall,
                      ),
                    ),
                  ),
                  ////////////////
                  //PAGE TITLE
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Center(
                      child: Text(
                        'Benvenuto nell\'app di TournamentManager. Qui potrai gestire i tuoi tornei, vedere lo storico e iscriverti ai prossimi eventi dei tuoi giochi preferiti.',
                        style: CustomFlowTheme.of(context).titleSmall.override(color: CustomFlowTheme.of(context).secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  ////////////////
                  //CONTINUE BUTTON
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: AFButtonWidget(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        logFirebaseEvent('ONBOARDING_VERIFY_MAIL_SUCCESS_CONTINUE');
                        logFirebaseEvent('Button_haptic_feedback');
                        HapticFeedback.lightImpact();
                        logFirebaseEvent('Button_continue');

                        logFirebaseEvent('Button_navigate_to');
                        context.goNamedAuth('Dashboard', context.mounted);
                      },
                      text: 'Continua',
                      options: AFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: CustomFlowTheme.of(context).primary,
                        textStyle: CustomFlowTheme.of(context).titleSmall,
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
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
