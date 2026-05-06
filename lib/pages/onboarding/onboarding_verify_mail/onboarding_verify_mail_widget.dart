import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_model.dart';

import '../../../components/standard_graphics/standard_graphics_widgets.dart';

abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
}

class OnboardingVerifyMailWidget extends StatefulWidget {
  const OnboardingVerifyMailWidget({super.key});

  @override
  State<OnboardingVerifyMailWidget> createState() =>
      _OnboardingVerifyMailWidgetState();
}

class _OnboardingVerifyMailWidgetState
    extends State<OnboardingVerifyMailWidget> {
  late String? _email;
  bool _isNavigating = false;
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    _email = currentUserEmail;
    context.read<OnboardingVerifyMailModel>().initContextVars(context);
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEmailVerification();
    });
  }

  Future<void> _initializeEmailVerification() async {
    final model = context.read<OnboardingVerifyMailModel>();
    final emailSent = await model.sendInitialVerificationEmail(_email);

    if (!emailSent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(model.emailError ?? 'Errore nell\'invio dell\'email'),
          backgroundColor: Colors.red,
        ),
      );
    }

    model.startWatchingVerification(
      onVerified: (isVerified) {
        if (mounted && isVerified && !_isNavigating) {
          _isNavigating = true;
          context.goNamedAuth('Onboarding_VerifyMailSuccess', context.mounted);
        }
      },
      onError: (error) {
        if (mounted) {
          if (error is TimeoutException) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Verifica email scaduta. Prova a rimandare l\'email.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      },
    );
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
                  _Header(onUpdate: () => setState(() {})),
                  _MailContent(
                    email: _email,
                    animationsMap: animationsMap,
                  ),
                  const _ContinueButton(),
                  _ResendButton(email: _email),
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
  const _Header({required this.onUpdate});
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    return wrapWithModel(
      model: context.read<OnboardingVerifyMailModel>().customAppbarModel,
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

class _MailContent extends StatelessWidget {
  const _MailContent({required this.email, required this.animationsMap});
  final String? email;
  final Map<String, AnimationInfo> animationsMap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Center(
            child: Lottie.asset(
              'assets/animation/send_mail_animation.json',
              fit: BoxFit.cover,
              width: 80.w,
              height: 60.w,
              repeat: true,
            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Center(
            child: Text(
              'Verifica il tuo indirizzo mail!',
              style: CustomFlowTheme.of(context).headlineSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
          child: Center(
            child: Text(
              email ?? '@@NO_MAIL_PASSED@@',
              style: CustomFlowTheme.of(context).titleSmall,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 0),
          child: Center(
            child: Text(
              'Il tuo account è stato creato ma non è utilizzabile fino a quando non confermerai la mail. Trovi il link nella mail indicata sopra. Controlla che non sia finita erroneamente in spam!',
              style: CustomFlowTheme.of(context).titleSmall.override(
                    color: CustomFlowTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: () async {
          FocusScope.of(context).unfocus();
          logFirebaseEvent('ONBOARDING_VERIFY_MAIL_CONTINUE');
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
    );
  }
}

class _ResendButton extends StatelessWidget {
  const _ResendButton({required this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<OnboardingVerifyMailModel>();
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: model.isEmailSending
            ? null
            : () async {
                FocusScope.of(context).unfocus();
                logFirebaseEvent('ONBOARDING_VERIFY_MAIL_RESEND_MAIL');
                logFirebaseEvent('Button_haptic_feedback');
                HapticFeedback.lightImpact();
                final m = context.read<OnboardingVerifyMailModel>();
                final success = await m.resendVerificationEmail(email);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Email inviata con successo!'
                            : m.emailError ?? 'Errore nell\'invio',
                      ),
                      backgroundColor:
                          success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
        text: model.isEmailSending
            ? 'Invio in corso...'
            : 'Rimanda email di verifica',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          color: CustomFlowTheme.of(context).primaryBackground,
          textStyle: CustomFlowTheme.of(context).titleSmall,
          elevation: 0,
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(_Dims.buttonRadius),
        ),
      ),
    );
  }
}
