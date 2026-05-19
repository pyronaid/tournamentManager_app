import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_model.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/services/snackbar_service.dart'; // adjust to your actual path

import '../../../app_flow/app_flow_widgets.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// Centralised so every magic number has a single source of truth.
// ---------------------------------------------------------------------------
abstract class _Dims {
  // Form fields
  static const double fieldSpacing      = 24.0;
  static const double buttonHeight      = 50.0;
  static const double sectionBorderWidth = 1.0;

  // Horizontal padding used consistently throughout the page.
  static const double pagePadding = 24.0;
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// ---------------------------------------------------------------------------

class TournamentDecklistWidget extends StatefulWidget {
  const TournamentDecklistWidget({super.key});

  @override
  State<TournamentDecklistWidget> createState() =>
      _TournamentDecklistWidgetState();
}

class _TournamentDecklistWidgetState extends State<TournamentDecklistWidget> {
  final _formKey = GlobalKey<FormState>();

  // Resolved once in initState — safe because the widget is always created
  // inside a Provider<TournamentDecklistModel> ancestor.
  late final TournamentDecklistModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<TournamentDecklistModel>();
  }

  // ── Save handler ──────────────────────────────────────────────────────────
  // Kept in the StatefulWidget so it can access _formKey and mounted.
  // Business logic (uploadDecklist) lives in the model.
  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('DECKLIST_UPLOAD_SAVE');

    if (_formKey.currentState == null ||
        !_formKey.currentState!.validate()) {
      return;
    }

    HapticFeedback.lightImpact();

    final success = await _model.uploadDecklist();

    if (!mounted) return;

    // Tell the model to notify its listeners so dependent Selectors rebuild.
    // Calling notifyListeners() from the widget is not possible because
    // ChangeNotifier.notifyListeners() is @protected.  The model exposes a
    // public method for exactly this purpose.
    if (success) {
      _model.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // Rebuilds only when isLoading changes — same pattern as
          // TournamentDetailWidget and TournamentRoundsWidget.
          child: Selector<TournamentDecklistModel, bool>(
            selector: (_, m) => m.isLoading,
            builder: (_, isLoading, __) {
              assert(() {
                debugPrint('[BUILD] tournament_decklist_widget.dart');
                return true;
              }());

              if (isLoading) return const _LoadingBody();

              // LayoutBuilder provides the real available height so child
              // widgets can size themselves proportionally if needed.
              return LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: _DecklistForm(
                    model: _model,
                    formKey: _formKey,
                    onSave: _handleSave,
                    availableHeight: constraints.maxHeight,
                  ),
                ),
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
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator());
}

// ---------------------------------------------------------------------------
// DECKLIST FORM
// Owns the RefreshIndicator and the enrollment gate.
// ---------------------------------------------------------------------------

class _DecklistForm extends StatelessWidget {
  const _DecklistForm({
    required this.model,
    required this.formKey,
    required this.onSave,
    required this.availableHeight,
  });

  final TournamentDecklistModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      // onRefresh must cause model.enrollCheckFuture to be reassigned so
      // the FutureBuilder below picks up the refreshed value.
      onRefresh: model.onRefresh,
      child: FutureBuilder<EnrollmentCheckResult>(
        future: model.enrollCheckFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // FIX: snapshot.hasData is a bool — the enrolled check must be
          //   performed on the actual data object, not on hasData.
          final enrollResult = snapshot.data!;

          if (enrollResult.isNotEnrolled) {
            return const NoContentCard(
              type: NoContentType.generic,
              active: false,
              phrase:
                  'Non sei iscritto a questo torneo e pertanto non puoi '
                  'caricare una decklist. Se pensi sia un errore, contatta '
                  "l'organizzatore.",
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The upload form is hidden once the tournament has started.
              Selector<TournamentDecklistModel, bool>(
                selector: (_, m) => m.isTournamentOngoing,
                builder: (_, ongoing, ___) {
                  if (ongoing) {
                    return const NoContentCard(
                      type: NoContentType.generic,
                      active: false,
                      phrase:
                          'Il torneo è già iniziato, non puoi più modificare '
                          'la decklist.',
                    );
                  }
                  return _SectionForm(
                    formKey: formKey,
                    onSave: onSave,
                    model: model,
                  );
                },
              ),

              // The decklist preview rebuilds only when decklist changes.
              Selector<TournamentDecklistModel, String?>(
                selector: (_, m) => m.decklist,
                builder: (_, decklist, ___) =>
                    _DecklistSection(decklist: decklist),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION – UPLOAD FORM
// ---------------------------------------------------------------------------

class _SectionForm extends StatelessWidget {
  const _SectionForm({
    required this.formKey,
    required this.onSave,
    required this.model,
  });

  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final TournamentDecklistModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.pagePadding, 0, _Dims.pagePadding, 0),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _YdkFileField(model: model),
            _YdkLinkField(model: model, onSave: onSave),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FIELD – FILE UPLOAD (.ydk)
// ---------------------------------------------------------------------------

class _YdkFileField extends StatelessWidget {
  const _YdkFileField({required this.model});

  final TournamentDecklistModel model;

  Future<void> _onUploadYdk(BuildContext context) async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('DECKLIST_LOAD_YDK_FILE');
    HapticFeedback.lightImpact();

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ydk'],
        allowMultiple: false,
      );
    } catch (e) {
      if (!context.mounted) return;
      GetIt.instance<SnackBarService>().showSnackBar(
        message: 'Impossibile aprire il selettore file. Riprova.',
        title: 'Errore',
        style: SnackbarStyle.error,
      );
      return;
    }

    if (result == null) return; // user cancelled
    if (!context.mounted) return;

    final PlatformFile pickedFile = result.files.single;
    final String? path = pickedFile.path;

    if (path == null) {
      // path is null on web — guard in case the app is ever ported.
      GetIt.instance<SnackBarService>().showSnackBar(
        message: 'File non accessibile. Riprova.',
        title: 'Errore',
        style: SnackbarStyle.error,
      );
      return;
    }

    await model.setYdkFilePath(path);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          0, 0, 0, _Dims.fieldSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Text(
              'Carica da file .ydk',
              style: CustomFlowTheme.of(context).bodyMedium,
            ),
          ),
          AFButtonWidget(
            onPressed: () => _onUploadYdk(context),
            text: 'Carica .ydk',
            options: AFButtonOptions(
              width: double.infinity,
              height: _Dims.buttonHeight,
              padding: EdgeInsetsDirectional.zero,
              iconPadding: EdgeInsetsDirectional.zero,
              color: CustomFlowTheme.of(context).primary,
              textStyle: CustomFlowTheme.of(context)
                  .labelLarge
                  .override(color: CustomFlowTheme.of(context).info),
              elevation: 0,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: _Dims.sectionBorderWidth,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FIELD – LINK UPLOAD (.ydk URL)
// ---------------------------------------------------------------------------

class _YdkLinkField extends StatelessWidget {
  const _YdkLinkField({required this.model, required this.onSave});

  final TournamentDecklistModel model;

  // FIX: the original code referenced _onUploadYdkLink but never defined it.
  // The save callback is passed in from _SectionForm (which receives it from
  // the StatefulWidget's _handleSave) so the validation + upload chain is
  // consistent regardless of which upload path the user chooses.
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          0, 0, 0, _Dims.fieldSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Text(
              'Carica da link .ydk (es. da DB)',
              style: CustomFlowTheme.of(context).bodyMedium,
            ),
          ),
          TextFormField(
            controller: model.controller,
            focusNode: model.focusNode,
            autofocus: false,
            autofillHints: const [AutofillHints.url],
            textCapitalization: TextCapitalization.none,
            textInputAction: TextInputAction.done,
            obscureText: false,
            minLines: 1,
            maxLines: 1,
            cursorColor: CustomFlowTheme.of(context).primary,
            decoration: standardInputDecoration(
              context,
              prefixIcon: null,
            ),
            style: CustomFlowTheme.of(context).bodyLarge.override(
                  fontWeight: FontWeight.w500,
                  lineHeight: 1,
                ),
            validator: model.validator,
          ),
          const SizedBox(height: 10),
          AFButtonWidget(
            onPressed: onSave,
            text: 'Carica da link .ydk',
            options: AFButtonOptions(
              width: double.infinity,
              height: _Dims.buttonHeight,
              padding: EdgeInsetsDirectional.zero,
              iconPadding: EdgeInsetsDirectional.zero,
              color: CustomFlowTheme.of(context).primary,
              textStyle: CustomFlowTheme.of(context)
                  .labelLarge
                  .override(color: CustomFlowTheme.of(context).info),
              elevation: 0,
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: _Dims.sectionBorderWidth,
              ),
              borderRadius: BorderRadius.circular(0),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION – DECKLIST PREVIEW
// FIX: renamed from _showDecklistSection (lowercase) to _DecklistSection
//   to follow Dart's UpperCamelCase naming convention for types.
// ---------------------------------------------------------------------------

class _DecklistSection extends StatelessWidget {
  const _DecklistSection({required this.decklist});

  final String? decklist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.pagePadding, 0, _Dims.pagePadding, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (decklist != null) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: Text(
                'Decklist attuale',
                style: CustomFlowTheme.of(context).bodyMedium,
              ),
            ),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: CustomFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Text(
                  decklist!,
                  style: CustomFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Source Code Pro',
                        lineHeight: 1.2,
                      ),
                ),
              ),
            ),
          ] else ...[
            const NoContentCard(
              type: NoContentType.generic,
              active: false,
              phrase: 'Nessuna decklist caricata.',
            ),
          ],
        ],
      ),
    );
  }
}
