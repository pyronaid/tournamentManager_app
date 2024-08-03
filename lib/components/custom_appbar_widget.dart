import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:petsy/app_flow/app_flow_theme.dart';
import 'package:petsy/app_flow/app_flow_util.dart';
import 'package:petsy/app_flow/app_flow_widgets.dart';

import '../app_flow/app_flow_icon_button.dart';
import '../backend/firebase_analytics/analytics.dart';
import 'custom_appbar_model.dart';

class CustomAppbarWidget extends StatefulWidget {
  const CustomAppbarWidget({
    super.key,
    required this.backButton,
    bool? actionButton,
    this.actionButtonText,
    this.actionButtonAction,
    bool? optionsButton,
    required this.optionsButtonAction,
  })  : actionButton = actionButton ?? false,
        optionsButton = optionsButton ?? false;

  final bool? backButton;
  final bool actionButton;
  final String? actionButtonText;
  final Future Function()? actionButtonAction;
  final bool optionsButton;
  final Future Function()? optionsButtonAction;

  @override
  State<CustomAppbarWidget> createState() => _CustomAppbarWidgetState();
}

class _CustomAppbarWidgetState extends State<CustomAppbarWidget> {
  late CustomAppbarModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomAppbarModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.backButton ?? true)
          CustomFlowIconButton(
            borderColor: CustomFlowTheme.of(context).secondaryBackground,
            borderRadius: 24.0,
            borderWidth: 1.0,
            buttonSize: 44.0,
            fillColor: CustomFlowTheme.of(context).secondaryBackground,
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: CustomFlowTheme.of(context).primaryText,
              size: 18.0,
            ),
            onPressed: () async {
              logFirebaseEvent('CUSTOM_APPBAR_keyboard_arrow_left_ICN_ON');
              logFirebaseEvent('IconButton_navigate_back');
              context.safePop();
            },
          ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (widget.actionButton)
              AFButtonWidget(
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  logFirebaseEvent('CUSTOM_APPBAR_COMP_SAVE_BTN_ON_TAP');
                  logFirebaseEvent('Button_execute_callback');
                  await widget.actionButtonAction?.call();
                },
                text: valueOrDefault<String>(
                  widget.actionButtonText,
                  'Button',
                ),
                options: AFButtonOptions(
                  height: 44.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  iconPadding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: CustomFlowTheme.of(context).primary,
                  textStyle: CustomFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: CustomFlowTheme.of(context).primaryBackground,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                  elevation: 0.0,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
            if (widget.optionsButton)
              CustomFlowIconButton(
                borderColor: CustomFlowTheme.of(context).secondaryBackground,
                borderRadius: 24.0,
                borderWidth: 1.0,
                buttonSize: 44.0,
                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                icon: FaIcon(
                  FontAwesomeIcons.ellipsis,
                  color: CustomFlowTheme.of(context).primaryText,
                  size: 18.0,
                ),
                onPressed: () async {
                  logFirebaseEvent('CUSTOM_APPBAR_COMP_ellipsisH_ICN_ON_TAP');
                  logFirebaseEvent('IconButton_execute_callback');
                  await widget.optionsButtonAction?.call();
                },
              ),
          ].divide(const SizedBox(width: 8.0)),
        ),
      ],
    );
  }
}
