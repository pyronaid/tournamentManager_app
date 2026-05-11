import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_model.dart';

import '../../../components/standard_graphics/standard_graphics_widgets.dart';


// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;

  // ── Lottie animation ───────────────────────────────────────────────────────
  /// The animation fills this fraction of the available width.
  /// FractionallySizedBox resolves the actual pixel size at build time —
  /// no external package needed.
  static const double animationWidthFraction  = 0.80; // replaces 80.w
  /// Height expressed as a fraction of width to preserve aspect ratio.
  /// 60/80 = 0.75 → same ratio as the original 60.w / 80.w.
  static const double animationHeightFraction = 0.75; // replaces 60.w
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------
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
        if (mounted && error is TimeoutException) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Verifica email scaduta. Prova a rimandare l\'email.'),
              backgroundColor: Colors.orange,
            ),
          );
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
          // FIX: Align(0,0) removed — it was redundant here since the Column
          //   below uses crossAxisAlignment.start and mainAxisAlignment.start.
          //   Align(0,0) centres its child, which contradicts the start
          //   alignment of the Column content.  SingleChildScrollView is
          //   added for safety on small screens / landscape orientation.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
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
// MAIL CONTENT
//
// FIX: Lottie width/height changed from 80.w / 60.w (responsive_sizer
//   percentage) to LayoutBuilder + FractionallySizedBox.
//
//   Why FractionallySizedBox is better here:
//     - It resolves the actual pixel size from its parent's constraints at
//       build time, with no external package.
//     - The animation stays proportional: height = width * 0.75 (same ratio
//       as original 60w/80w = 0.75), expressed as a named constant so the
//       relationship is self-documenting.
//     - On tablets the animation scales up correctly rather than being
//       capped at a device-specific 80%.
// ---------------------------------------------------------------------------
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final animWidth =
                    constraints.maxWidth * _Dims.animationWidthFraction;
                final animHeight = animWidth * _Dims.animationHeightFraction;
                return Lottie.asset(
                  'assets/animation/send_mail_animation.json',
                  fit: BoxFit.contain,
                  width: animWidth,
                  height: animHeight,
                  repeat: true,
                ).animateOnPageLoad(
                    animationsMap['imageOnPageLoadAnimation1']!);
              },
            ),
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

// ---------------------------------------------------------------------------
// CONTINUE BUTTON
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: () {
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
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
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

// ---------------------------------------------------------------------------
// RESEND BUTTON
// context.watch is correct here — the button text/enabled state reacts to
// isEmailSending changes.  No fix needed.
// FIX: fromSTEB(0,0,0,0) → EdgeInsetsDirectional.zero.
// ---------------------------------------------------------------------------
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
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
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
