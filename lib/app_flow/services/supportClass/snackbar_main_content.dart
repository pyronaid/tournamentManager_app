import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';

import '../../app_flow_theme.dart';

class SnackbarMainContent extends StatelessWidget {
  final SnackbarStyle style;
  final String message;
  final Function? onCloseButtonPressed;

  const SnackbarMainContent({
    required this.style,
    required this.message,
    required this.onCloseButtonPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(0),
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(15, 10, 15, 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [CustomFlowTheme.of(context).gradientBackgroundBegin, CustomFlowTheme.of(context).gradientBackgroundEnd]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if(style.icon != null) ...[
              Icon(
                style.icon,
                color: style.displayColor,
              ),
              // Icon in SnackBar
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 17, bottom: 17),
                child: Text(
                  message,
                  style: CustomFlowTheme.of(context).bodyMedium,
                ),
              ),
            ),
            Visibility(
              visible: style.isCloseButtonVisible,
              child: IconButton(
                onPressed: () {
                  onCloseButtonPressed?.call();
                },
                icon: const Icon(Icons.close, color: Colors.amber,),
              ),
            )
          ],
        ),
      ),
    );
  }
}