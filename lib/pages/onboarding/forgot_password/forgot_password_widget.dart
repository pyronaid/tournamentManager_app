import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/onboarding/forgot_password/forgot_password_model.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double buttonHeight = 50.0;
  static const double buttonRadius = 25.0;
  static const double prefixIconSize = 18.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// Kept as StatefulWidget because _formKey must survive rebuilds and
// _handleReset references mounted + context.
// ---------------------------------------------------------------------------
class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();
  late final ForgotPasswordModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<ForgotPasswordModel>();
  }

  // FIX: button logic extracted from the inline onPressed lambda into a
  //   named method — consistent with _handleSave in every other form page.
  Future<void> _handleReset() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('FORGOT_PASSWORD_RESET_PASSWORD_BTN_ON_TA');
    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();
    logFirebaseEvent('Button_auth');

    if (_model.emailAddressTextController.text.isEmpty) {
      _model.showResetPasswordIssueSnackBar();
    } else {
      await pocketAuthManager
          .resetPassword(_model.emailAddressTextController.text);
      logFirebaseEvent('Button_navigate_back');
      if (mounted) context.safePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // FIX: Expanded + Align(0,0) replaced with a simple Padding +
          //   SingleChildScrollView.
          //   The original Expanded filled all available height, then
          //   Align(0,0) centred the Column inside it — effectively just
          //   adding extra space below the form with no scrolling.
          //   SingleChildScrollView is safer: if the keyboard appears or the
          //   screen is very small the content scrolls rather than overflowing,
          //   even though resizeToAvoidBottomInset is false.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                _FormSection(
                  formKey: _formKey,
                  model: _model,
                  onReset: _handleReset,
                ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomAppbarWidget(backButton: true),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: Text(
            'Password dimenticata',
            style: CustomFlowTheme.of(context).displaySmall,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION
//
// FIX: model is now received as a constructor parameter — no context.read
//   inside build().  onReset replaces the inline async lambda on the button.
// ---------------------------------------------------------------------------
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.formKey,
    required this.model,
    required this.onReset,
  });

  final GlobalKey<FormState> formKey;
  final ForgotPasswordModel model;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ti manderemo una mail per il reset della password.',
                  textAlign: TextAlign.start,
                  style: CustomFlowTheme.of(context).labelLarge,
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
                  child: Text(
                    'Email',
                    textAlign: TextAlign.start,
                    style: CustomFlowTheme.of(context).bodyLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                  child: TextFormField(
                    controller: model.emailAddressTextController,
                    focusNode: model.emailAddressFocusNode,
                    autofocus: false,
                    autofillHints: const [AutofillHints.email],
                    textCapitalization: TextCapitalization.none,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                    decoration: standardInputDecoration(
                      context,
                      prefixIcon: Icon(
                        Icons.email,
                        color: CustomFlowTheme.of(context).secondaryText,
                        size: _Dims.prefixIconSize,
                      ),
                    ),
                    style: CustomFlowTheme.of(context).titleSmall.override(
                          fontWeight: FontWeight.w500,
                          lineHeight: 1,
                        ),
                    minLines: 1,
                    cursorColor: CustomFlowTheme.of(context).primary,
                    validator: model.emailAddressTextControllerValidator
                        .asValidator(context),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
          child: AFButtonWidget(
            onPressed: onReset,
            text: 'Reset Password',
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
        ),
      ],
    );
  }
}
