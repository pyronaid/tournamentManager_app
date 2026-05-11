import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/core/add_people/add_people_model.dart';
import '../tournament_people/tournament_people_model.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double headerPaddingAll  = 24.0;
  static const double titlePaddingTop   = 24.0;
  static const double titlePaddingBtm   = 30.0;
  static const double formPaddingAll    = 24.0;
  static const double fieldPaddingBtm   = 30.0;
  static const double labelPaddingBtm   = 4.0;
  static const double msgPaddingBtm     = 30.0;
  static const double msgRowPadding     = 8.0;
  static const double msgIconSize       = 30.0;
  static const double msgIconInner      = 20.0;
  static const double msgIconGap        = 20.0;
  static const double prefixIconSize    = 18.0;
  static const double suffixIconSize    = 20.0;
  static const double submitHeight      = 50.0;
  static const double submitRadius      = 25.0;
  static const double submitPaddingAll  = 24.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// Kept as StatefulWidget because _formKey (GlobalKey) must survive rebuilds.
// ---------------------------------------------------------------------------
class AddPeopleWidget extends StatefulWidget {
  const AddPeopleWidget({super.key});

  @override
  State<AddPeopleWidget> createState() => _AddPeopleWidgetState();
}

class _AddPeopleWidgetState extends State<AddPeopleWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    assert(() {
      debugPrint('[BUILD] add_people_widget.dart');
      return true;
    }());

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Selector<TournamentPeopleModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              if (isLoading) return const _LoadingBody();

              // FIX: both models resolved here and passed as parameters —
              //   avoids context.read inside descendant build methods.
              //   AddPeopleModel is read once; TournamentPeopleModel is read
              //   once. Neither needs to be watched — all reactive state goes
              //   through the Consumer in _AddPeopleBody.
              final addModel =
              context.read<AddPeopleModel>();
              final peopleModel =
              context.read<TournamentPeopleModel>();

              return _AddPeopleBody(
                formKey: _formKey,
                addModel: addModel,
                peopleModel: peopleModel,
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING BODY
// ---------------------------------------------------------------------------
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(24),
    child: Center(child: CircularProgressIndicator()),
  );
}

// ---------------------------------------------------------------------------
// MAIN BODY
//
// FIX: Align(topCenter) removed.  SingleChildScrollView aligns its child
//   to the top by default — the explicit Align added a redundant layout node.
//
// FIX: Consumer<AddPeopleModel> replaced with a constructor parameter.
//   Consumer rebuilds the entire Column (header + form + button) on every
//   notifyListeners call from AddPeopleModel.  Since both models are already
//   resolved in the Selector builder above and passed down, this widget is
//   now purely declarative and rebuilds only when its parent rebuilds
//   (i.e. when isLoading flips).
//   The model is passed to _FormSection and _SubmitButton which need it;
//   _HeaderSection only needs the peopleModel for the tournament name.
// ---------------------------------------------------------------------------
class _AddPeopleBody extends StatelessWidget {
  const _AddPeopleBody({
    required this.formKey,
    required this.addModel,
    required this.peopleModel,
  });

  final GlobalKey<FormState> formKey;
  final AddPeopleModel addModel;
  final TournamentPeopleModel peopleModel;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeaderSection(),
          _FormSection(
            addModel: addModel,
            peopleModel: peopleModel,
            formKey: formKey,
          ),
          _SubmitButton(
            addModel: addModel,
            peopleModel: peopleModel,
            formKey: formKey,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HEADER SECTION
//
// FIX: model parameter removed — the header only shows a static title and
//   the appbar back button.  It has no model dependency so it becomes a
//   genuinely const-constructible widget.
// ---------------------------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomFlowTheme.of(context).secondary,
      padding: const EdgeInsets.all(_Dims.headerPaddingAll),
      child: Column(
        children: [
          const CustomAppbarWidget(backButton: true),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              0, _Dims.titlePaddingTop, 0, _Dims.titlePaddingBtm,
            ),
            child: Text(
              'Registra un giocatore',
              style: CustomFlowTheme.of(context).displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION
// ---------------------------------------------------------------------------
class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.addModel,
    required this.peopleModel,
    required this.formKey,
  });

  final AddPeopleModel addModel;
  final TournamentPeopleModel peopleModel;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_Dims.formPaddingAll),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _UserIdField(addModel: addModel, peopleModel: peopleModel),
            // FIX: messageObjList passed directly — _MessageList has no model
            //   dependency, only the list content.
            _MessageList(messages: addModel.messageObjList),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// USER ID FIELD
//
// FIX: context.read<TournamentPeopleModel>() removed from build().
//   peopleModel is now received as a constructor parameter — resolved once
//   in the Selector builder at the root widget level.
// ---------------------------------------------------------------------------
class _UserIdField extends StatelessWidget {
  const _UserIdField({
    required this.addModel,
    required this.peopleModel,
  });

  final AddPeopleModel addModel;
  final TournamentPeopleModel peopleModel;

  // Extracted helper so the two icon button callbacks share the lookup logic.
  Future<void> _lookupAndCompose(BuildContext context, String userId) async {
    final respMap = await peopleModel.getUserInfoForEnrollment(
      userId,
      listType: peopleModel.listTypeReferral,
    );
    addModel.composeOutputForRequest(
      respMap,
      listType: peopleModel.listTypeReferral,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.fieldPaddingBtm),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.labelPaddingBtm),
            child: Text('Id utente', style: CustomFlowTheme.of(context).bodyMedium),
          ),
          TextFormField(
            controller: addModel.fieldControllerIdUser,
            focusNode: addModel.idUserFocusNode,
            autofocus: false,
            autofillHints: const [AutofillHints.name],
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.next,
            obscureText: false,
            decoration: standardInputDecoration(
              context,
              prefixIcon: Icon(
                Icons.badge,
                color: CustomFlowTheme.of(context).secondaryText,
                size: _Dims.prefixIconSize,
              ),
              suffixIcons: [
                // Refresh — looks up the typed ID
                IconButton(
                  onPressed: () async {
                    final text = addModel.fieldControllerIdUser.text;
                    if (text.isNotEmpty) {
                      await _lookupAndCompose(context, text);
                    }
                  },
                  icon: Icon(Icons.refresh, size: _Dims.suffixIconSize),
                  color: CustomFlowTheme.of(context).secondaryText,
                ),
                // QR scanner — fills the field then looks up
                IconButton(
                  onPressed: () async {
                    final result = await context.pushNamedAuth(
                      'ScannerCode', context.mounted,
                      pathParameters: {
                        'tournamentId': peopleModel.tournamentModel.tournamentId,
                      }.withoutNulls,
                    );
                    if (result != null) {
                      addModel.setFieldControllerIdUser(result);
                      final text = addModel.fieldControllerIdUser.text;
                      if (text.isNotEmpty && context.mounted) {
                        await _lookupAndCompose(context, text);
                      }
                    }
                  },
                  icon: Icon(Icons.qr_code, size: _Dims.suffixIconSize),
                  color: CustomFlowTheme.of(context).secondaryText,
                ),
              ],
            ),
            style: CustomFlowTheme.of(context).bodyLarge.override(
              fontWeight: FontWeight.w500,
              lineHeight: 1,
            ),
            minLines: 1,
            cursorColor: CustomFlowTheme.of(context).primary,
            validator: addModel.idUserTextControllerValidator.asValidator(context),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MESSAGE LIST
// ---------------------------------------------------------------------------
class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages});

  final List<MessagePeople> messages;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.msgPaddingBtm),
      child: Column(
        children: [
          for (final msg in messages) _MessageRow(message: msg),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// MESSAGE ROW
// ---------------------------------------------------------------------------
class _MessageRow extends StatelessWidget {
  const _MessageRow({required this.message});

  final MessagePeople message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(_Dims.msgRowPadding),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: _Dims.msgIconSize,
            height: _Dims.msgIconSize,
            decoration: BoxDecoration(
              color: message.messageLevel.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              message.messageLevel.icon,
              color: Colors.white,
              size: _Dims.msgIconInner,
            ),
          ),
          const SizedBox(width: _Dims.msgIconGap),
          Expanded(
            child: Text(
              message.message,
              style: CustomFlowTheme.of(context).titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SUBMIT BUTTON
//
// FIX: context.read<TournamentPeopleModel>() removed from build().
//   peopleModel received as constructor parameter.
//
// FIX: the inline async lambda on onPressed extracted to _handleSubmit —
//   consistent with the _handleSave pattern used in create_own_widget and
//   create_edit_news_widget.  The button declaration becomes one line.
// ---------------------------------------------------------------------------
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.addModel,
    required this.peopleModel,
    required this.formKey,
  });

  final AddPeopleModel addModel;
  final TournamentPeopleModel peopleModel;
  final GlobalKey<FormState> formKey;

  Future<void> _handleSubmit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('ONBOARDING_ADD_USER_ADD_USER');
    logFirebaseEvent('Button_validate_form');

    if (formKey.currentState == null || !formKey.currentState!.validate()) {
      return;
    }

    final flag = await peopleModel.promotePeople(
      addModel.fieldControllerIdUser.text,
      listType: peopleModel.listTypeReferral,
    );

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();

    if (flag && context.mounted) context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(_Dims.submitPaddingAll),
      child: AFButtonWidget(
        onPressed: addModel.checked
            ? () => _handleSubmit(context)
            : null,
        text: 'Aggiungi',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.submitHeight,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          color: CustomFlowTheme.of(context).primary,
          disabledColor: CustomFlowTheme.of(context).disabled,
          textStyle: CustomFlowTheme.of(context).titleSmall,
          elevation: 0,
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
          borderRadius: BorderRadius.circular(_Dims.submitRadius),
        ),
      ),
    );
  }
}
