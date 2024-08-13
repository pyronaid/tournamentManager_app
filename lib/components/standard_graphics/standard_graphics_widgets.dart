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

// set up the AlertDialog
AlertDialog standardAlert(BuildContext context, String title, String message, {Widget? cancelButtonWid, Widget? continueButtonWid}) {
  Widget cancelButtonDef = TextButton(
    child: Text(
      "Annulla",
      style: CustomFlowTheme.of(context).titleMedium,
    ),
    onPressed:  () {
      Navigator.of(context).pop(); // dismiss dialog
    },
  );

  Widget continueButtonDef = TextButton(
    child: Text(
      "Continua",
      style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).warning),
    ),
    onPressed:  () async {
      Navigator.of(context).pop(); // dismiss dialog
    },
  );


  return AlertDialog(
    title: Text(
      title,
      style: CustomFlowTheme.of(context).displaySmall.override(color: CustomFlowTheme.of(context).warning),
    ),
    content: Text(
      message,
      style: CustomFlowTheme.of(context).labelMedium,
    ),
    actions: [
      cancelButtonWid ?? cancelButtonDef,
      continueButtonWid ?? continueButtonDef,
    ],
  );
}