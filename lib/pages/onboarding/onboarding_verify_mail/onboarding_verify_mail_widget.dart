
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';

import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/firebase_auth/auth_util.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import 'onboarding_verify_mail_model.dart';

class OnboardingVerifyMailWidget extends StatefulWidget {

  const OnboardingVerifyMailWidget({super.key});

  @override
  State<OnboardingVerifyMailWidget> createState() =>
      _OnboardingVerifyMailWidgetState();
}

class _OnboardingVerifyMailWidgetState extends State<OnboardingVerifyMailWidget> {
  late OnboardingVerifyMailModel _model;
  late String? _email;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _email = currentUserEmail;
    _model = createModel(context, () => OnboardingVerifyMailModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_VerifyMail'});
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    checkEmailVerification();
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
        key: _scaffoldKey,
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
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: Center(
                      child: Lottie.asset(
                        'assets/animation/send_mail_animation.json',
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
                    child: Center(
                      child: Text(
                        'Verifica il tuo indirizzo mail!',
                        style: CustomFlowTheme.of(context).headlineSmall,
                      ),
                    ),
                  ),
                  ////////////////
                  //MAIL INDICATION 
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
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
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
                    child: Center(
                      child: Text(
                        'Il tuo account è stato creato ma non è utilizzabile fino a quando non confermerai la mail. Trovi il link nella mail indicata sopra. Controlla che non sia finita erroneamente in spam!',
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
                        logFirebaseEvent('ONBOARDING_VERIFY_MAIL_CONTINUE');
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
                  ////////////////
                  //RESEND MAIL BUTTON
                  /////////////////
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                    child: AFButtonWidget(
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        logFirebaseEvent('ONBOARDING_VERIFY_MAIL_RESEND_MAIL');
                        logFirebaseEvent('Button_haptic_feedback');
                        HapticFeedback.lightImpact();
                        logFirebaseEvent('Button_resend_mail');
                        

                        //LOGIC
                        try{
                          await authManager.sendEmailVerification();
                        } catch (e){

                        }
                      },
                      text: 'Rimanda email di verifica',
                      options: AFButtonOptions(
                        width: double.infinity,
                        height: 50,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: CustomFlowTheme.of(context).primaryBackground,
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

  void checkEmailVerification() async{
    bool isVerified = await _model.interceptVerification();
    if (mounted && isVerified) {
      context.goNamedAuth('Onboarding_VerifyMailSuccess', context.mounted );
    }
  }
}
