import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/app_flow/nav/nav_basics.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/components/title_with_subtitle/title_with_subtitle_widget.dart';
import 'package:tournamentmanager/pages/profile/edit_profile/edit_profile_model.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double headerPaddingAll    = 24.0;
  static const double pageTitlePaddingTop = 24.0;
  static const double formPaddingH        = 24.0;
  static const double formPaddingTop      = 42.0;
  static const double formPaddingBtm      = 24.0;
  static const double labelPaddingBtm     = 4.0;
  static const double fieldPaddingTop     = 4.0;
  static const double iconSize            = 18.0;
  static const double sectionPaddingH     = 24.0;
  static const double buttonPaddingTop    = 12.0;
  static const double buttonHeight        = 50.0;
  static const double buttonRadius        = 25.0;

  /// Bottom padding after the delete account button — provides breathing room
  /// before the end of the scroll content.
  static const double deleteButtonPaddingBtm = 48.0;

  static const Color  deleteButtonBg      = Color(0xFFFFD4D4);
  static const Color  deleteButtonText    = Color(0xFFB74D4D);
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// Kept as StatefulWidget: _formKey must persist across rebuilds.
// ---------------------------------------------------------------------------
class EditProfileWidget extends StatefulWidget {
  const EditProfileWidget({super.key});

  @override
  State<EditProfileWidget> createState() => _EditProfileWidgetState();
}

class _EditProfileWidgetState extends State<EditProfileWidget> {
  final _formKey = GlobalKey<FormState>();

  // FIX: model resolved once in initState — not inside multiple descendant
  //   build() methods.  Passing it as a parameter makes every widget's
  //   dependency explicit and removes six separate context.read calls from
  //   build methods throughout the tree.
  late final EditProfileModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<EditProfileModel>();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // FIX: Align(0,0) inside SingleChildScrollView removed.
          //   SingleChildScrollView aligns content to the top by default;
          //   the Align was a redundant layout node with no visual effect.
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(model: _model, formKey: _formKey),
                _FormSection(model: _model, formKey: _formKey),
                _ResetPasswordSection(model: _model),
                _ChangeMailSection(model: _model),
                _DeleteAccountSection(model: _model),
                _HiddenEmailField(model: _model),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER  (appbar with save action + page title)
// ---------------------------------------------------------------------------
class _Header extends StatelessWidget {
  const _Header({required this.model, required this.formKey});

  final EditProfileModel model;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomFlowTheme.of(context).secondary,
      padding: const EdgeInsets.all(_Dims.headerPaddingAll),
      child: Column(
        children: [
          CustomAppbarWidget(
            backButton: true,
            actionButton: true,
            actionButtonText: 'Salva',
            actionButtonAction: () async {
              logFirebaseEvent('EDIT_PROFILE_Container_or1jni5i_CALLBACK');
              logFirebaseEvent('customAppbar_backend_call');
              if (formKey.currentState == null || !formKey.currentState!.validate()) {
                return;
              }
              model.updateUserProfile(formKey);
              logFirebaseEvent('customAppbar_update_page_state');
            },
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.pageTitlePaddingTop, 0, 0),
            child: Text(
              'Modifica Profilo',
              style: CustomFlowTheme.of(context).displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION  (name / surname / username fields)
// ---------------------------------------------------------------------------
class _FormSection extends StatelessWidget {
  const _FormSection({required this.model, required this.formKey});

  final EditProfileModel model;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.formPaddingH, _Dims.formPaddingTop,
        _Dims.formPaddingH, _Dims.formPaddingBtm,
      ),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Nome'),
            _FormTextField(
              controller: model.nameTextController,
              focusNode: model.nameFocusNode,
              autofillHint: AutofillHints.name,
              capitalization: TextCapitalization.words,
              onChanged: (_) {
                EasyDebounce.debounce(
                  '_model.fullNameTextController',
                  const Duration(milliseconds: 2000),
                  () async {
                    logFirebaseEvent('EDIT_PROFILE_fullName_ON_TEXTFIELD_CHANG');
                    logFirebaseEvent('fullName_update_page_state');
                  },
                );
                model.clearServerError('name');
              },
              validator: model.nameTextControllerValidator?.asValidator(context),
            ),
            const _FieldLabel('Cognome'),
            _FormTextField(
              controller: model.surnameTextController,
              focusNode: model.surnameFocusNode,
              autofillHint: AutofillHints.familyName,
              capitalization: TextCapitalization.words,
              onChanged: (_) {
                EasyDebounce.debounce(
                  '_model.surnameTextController',
                  const Duration(milliseconds: 2000),
                  () async {
                    logFirebaseEvent('EDIT_PROFILE_surname_ON_TEXTFIELD_CHANG');
                    logFirebaseEvent('surname_update_page_state');
                  },
                );
                model.clearServerError('surname');
              },
              validator: model.surnameTextControllerValidator?.asValidator(context),
            ),
            const _FieldLabel('Username'),
            _FormTextField(
              controller: model.usernameTextController,
              focusNode: model.usernameFocusNode,
              autofillHint: AutofillHints.username,
              capitalization: TextCapitalization.none,
              onChanged: (_) {
                EasyDebounce.debounce(
                  '_model.usernameTextController',
                  const Duration(milliseconds: 2000),
                  () async {
                    logFirebaseEvent('EDIT_PROFILE_username_ON_TEXTFIELD_CHANG');
                    logFirebaseEvent('username_update_page_state');
                  },
                );
                model.clearServerError('username');
              },
              validator: model.usernameTextControllerValidator?.asValidator(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FIELD LABEL
// ---------------------------------------------------------------------------
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.labelPaddingBtm),
      child: Text(text, style: CustomFlowTheme.of(context).bodyLarge),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM TEXT FIELD  (shared structure for name / surname / username)
// ---------------------------------------------------------------------------
class _FormTextField extends StatelessWidget {
  const _FormTextField({
    required this.controller,
    required this.focusNode,
    required this.autofillHint,
    required this.capitalization,
    required this.onChanged,
    required this.validator,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String autofillHint;
  final TextCapitalization capitalization;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.fieldPaddingTop, 0, 0),
      child: AuthUserStreamWidget(
        builder: (context) => TextFormField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          autofocus: false,
          autofillHints: [autofillHint],
          textCapitalization: capitalization,
          textInputAction: TextInputAction.next,
          obscureText: false,
          decoration: standardInputDecoration(
            context,
            prefixIcon: Icon(
              Icons.person,
              color: CustomFlowTheme.of(context).secondaryText,
              size: _Dims.iconSize,
            ),
          ),
          style: CustomFlowTheme.of(context).bodyLarge.override(
            fontWeight: FontWeight.w500,
            lineHeight: 1,
          ),
          minLines: 1,
          cursorColor: CustomFlowTheme.of(context).primary,
          validator: validator,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// RESET PASSWORD SECTION
//
// FIX: model received as constructor parameter — no context.read in build().
// FIX: EdgeInsets.fromLTRB(sectionPaddingH, 0, sectionPaddingH, 0) replaced
//   with EdgeInsets.symmetric(horizontal: sectionPaddingH) — expresses the
//   same inset more clearly.  Applied to all three section widgets below.
// ---------------------------------------------------------------------------
class _ResetPasswordSection extends StatelessWidget {
  const _ResetPasswordSection({required this.model});

  final EditProfileModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: _Dims.sectionPaddingH),
          child: TitleWithSubtitleWidget(
            title: 'Reset Password',
            subtitle: 'Ricevi un link via email per resettare la tua password.',
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.sectionPaddingH, _Dims.buttonPaddingTop, _Dims.sectionPaddingH, 0,
          ),
          child: AFButtonWidget(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('EDIT_PROFILE_RESET_PASSWORD_BTN_ON_TAP');
              logFirebaseEvent('Button_auth');
              if (model.emailAddressTextController.text.isEmpty) {
                model.showIssueSnackBar();
              } else {
                context.goNamed('DialogResetPassword', extra: {'req': model.showResetPasswordAlertRequest()});
              }
            },
            text: 'Reset Password',
            options: _primaryButtonOptions(context),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CHANGE MAIL SECTION
// ---------------------------------------------------------------------------
class _ChangeMailSection extends StatelessWidget {
  const _ChangeMailSection({required this.model});

  final EditProfileModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: _Dims.sectionPaddingH),
          child: TitleWithSubtitleWidget(
            title: 'Cambio Mail',
            subtitle: 'Avvia la procedura di cambio mail: $currentUserEmail',
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.sectionPaddingH, _Dims.buttonPaddingTop, _Dims.sectionPaddingH, 0,
          ),
          child: AFButtonWidget(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('EDIT_PROFILE_CHANGE_MAIL_BTN_ON_TAP');
              logFirebaseEvent('Button_auth');
              if (model.emailAddressTextController.text.isEmpty) {
                model.showIssueSnackBar();
              } else {
                context.goNamed('DialogChangeMail', extra: {'req': model.showChangeMailAlertRequest()});
              }
            },
            text: 'Change Mail',
            options: _primaryButtonOptions(context),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DELETE ACCOUNT SECTION
// ---------------------------------------------------------------------------
class _DeleteAccountSection extends StatelessWidget {
  const _DeleteAccountSection({required this.model});

  final EditProfileModel model;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: _Dims.sectionPaddingH),
          child: TitleWithSubtitleWidget(
            title: 'Cancella Account',
            subtitle: 'I dati del tuo account saranno cancellati senza possibilità di ripristino.',
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.sectionPaddingH, _Dims.buttonPaddingTop, _Dims.sectionPaddingH, 48,
          ),
          child: AFButtonWidget(
            onPressed: () async {
              FocusScope.of(context).unfocus();
              logFirebaseEvent('EDIT_PROFILE_DELETE_ACCOUNT_BTN_ON_TAP');
              logFirebaseEvent('Button_auth');
              context.goNamed('DialogDeleteAccount',
                  extra: {
                    'req': model.showConfirmDeletionAccountAlertRequest(),
                  });
            },
            text: 'Cancella Account',
            options: AFButtonOptions(
              width: double.infinity,
              height: _Dims.buttonHeight,
              padding: EdgeInsetsDirectional.zero,
              iconPadding: EdgeInsetsDirectional.zero,
              color: _Dims.deleteButtonBg,
              textStyle: CustomFlowTheme.of(context).bodyMedium.override(color: _Dims.deleteButtonText),
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

// ---------------------------------------------------------------------------
// HIDDEN EMAIL FIELD  (invisible — holds email value for validation/alert refs)
// ---------------------------------------------------------------------------
class _HiddenEmailField extends StatelessWidget {
  const _HiddenEmailField({required this.model});

  final EditProfileModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: _Dims.sectionPaddingH),
      child: TextFormField(
        controller: model.emailAddressTextController,
        focusNode: model.emailAddressFocusNode,
        autofocus: false,
        textCapitalization: TextCapitalization.none,
        readOnly: true,
        obscureText: false,
        decoration: const InputDecoration(
          isDense: true,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        style: CustomFlowTheme.of(context).bodyMedium.override(
          color: CustomFlowTheme.of(context).primaryBackground,
          fontSize: 1,
          fontWeight: FontWeight.w500,
          lineHeight: 1,
        ),
        minLines: 1,
        validator: model.emailAddressTextControllerValidator.asValidator(context, ''),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED PRIMARY BUTTON OPTIONS
// ---------------------------------------------------------------------------
AFButtonOptions _primaryButtonOptions(BuildContext context) {
  return AFButtonOptions(
    width: double.infinity,
    height: _Dims.buttonHeight,
    padding: EdgeInsetsDirectional.zero,
    iconPadding: EdgeInsetsDirectional.zero,
    color: CustomFlowTheme.of(context).primary,
    textStyle: CustomFlowTheme.of(context)
        .bodyMedium
        .override(color: CustomFlowTheme.of(context).primaryBackground),
    elevation: 0,
    borderSide: const BorderSide(color: Colors.transparent, width: 1),
    borderRadius: BorderRadius.circular(_Dims.buttonRadius),
  );
}
