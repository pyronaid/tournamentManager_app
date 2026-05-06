// components/custom_appbar_widget.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tournamentmanager/app_flow/app_flow_icon_button.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

/// App bar row with optional back button, action button, and options button.
/// All three slots are independently opt-in via boolean flags.
class CustomAppbarWidget extends StatelessWidget {
  const CustomAppbarWidget({
    super.key,
    required this.backButton,
    this.actionButton = false,
    this.actionButtonText,
    this.actionButtonAction,
    this.optionsButton = false,
    this.optionsButtonAction,
  });

  final bool backButton;
  final bool actionButton;
  final String? actionButtonText;
  final Future<void> Function()? actionButtonAction;
  final bool optionsButton;
  final Future<void> Function()? optionsButtonAction;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Back button ───────────────────────────────────────────────────
        if (backButton)
          CustomFlowIconButton(
            borderColor: theme.secondaryBackground,
            borderRadius: 24,
            borderWidth: 1,
            buttonSize: 44,
            fillColor: theme.secondaryBackground,
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: theme.primaryText,
              size: 18,
            ),
            onPressed: () async {
              logFirebaseEvent('CUSTOM_APPBAR_keyboard_arrow_left_ICN_ON');
              logFirebaseEvent('IconButton_navigate_back');
              context.safePop();
            },
          ),

        // ── Right-side buttons ────────────────────────────────────────────
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (actionButton)
              AFButtonWidget(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  logFirebaseEvent('CUSTOM_APPBAR_COMP_SAVE_BTN_ON_TAP');
                  logFirebaseEvent('Button_execute_callback');
                  await actionButtonAction?.call();
                },
                text: valueOrDefault<String>(actionButtonText, 'Button'),
                options: AFButtonOptions(
                  height: 44,
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                  iconPadding: EdgeInsetsDirectional.zero,
                  color: theme.secondaryBackground,
                  textStyle: theme.bodyMedium.override(color: theme.primaryText),
                  elevation: 0,
                  borderSide: const BorderSide(color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            if (optionsButton)
              CustomFlowIconButton(
                borderColor: theme.secondaryBackground,
                borderRadius: 24,
                borderWidth: 1,
                buttonSize: 44,
                fillColor: theme.secondaryBackground,
                icon: FaIcon(
                  FontAwesomeIcons.ellipsis,
                  color: theme.primaryText,
                  size: 18,
                ),
                onPressed: () async {
                  logFirebaseEvent('CUSTOM_APPBAR_COMP_ellipsisH_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_execute_callback');
                  await optionsButtonAction?.call();
                },
              ),
          ].divide(const SizedBox(width: 8)),
        ),
      ],
    );
  }
}