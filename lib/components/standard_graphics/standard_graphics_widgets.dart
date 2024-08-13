import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../app_flow/app_flow_animations.dart';
import '../../app_flow/app_flow_theme.dart';

InputDecoration standardInputDecoration(BuildContext context, {Widget? suffixIcon, Widget? prefixIcon}) {
  return InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).alternate,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).primary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: CustomFlowTheme.of(context).secondaryBackground,
    errorMaxLines: 2,
    suffixIcon: suffixIcon,
    prefixIcon: prefixIcon,
  );
}

AnimationInfo standardAnimationInfo(BuildContext context) {
  return AnimationInfo(
    trigger: AnimationTrigger.onPageLoad,
    effectsBuilder: () => [
      ScaleEffect(
        curve: Curves.easeInOut,
        delay: 0.0.ms,
        duration: 600.0.ms,
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
      ),
      FadeEffect(
        curve: Curves.easeInOut,
        delay: 0.0.ms,
        duration: 600.0.ms,
        begin: 0.0,
        end: 1.0,
      ),
    ],
  );
}

AnimationInfo standardAnimationCard(BuildContext context) {
  return AnimationInfo(
    trigger: AnimationTrigger.onPageLoad,
    effectsBuilder: () => [
      ScaleEffect(
        curve: Curves.elasticOut,
        delay: 0.0.ms,
        duration: 600.0.ms,
        begin: const Offset(0.0, 0.0),
        end: const Offset(1.0, 1.0),
      ),
    ],
  );
}

