import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/components/tournament_decklist_card/tournament_decklist_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_model.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../app_flow/services/SnackBarService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';
import '../../../backend/schema/enrollments_record.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/no_content_card/no_content_card_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';

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

  static const double sliverAppBarExpandedHeight  = 70.0;
  static const double sliverAppBarCollapsedHeight = 70.0;
  static const double sectionFooterHeight         = 40.0;
  static const double sectionFooterRadius         = 20.0;
  static const double titlePaddingBottom          = 30.0;
  static const double titlePaddingTop             = 15.0;
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

    final success = await _model.manageCode("");

    if (!mounted) return;

    // Tell the model to notify its listeners so dependent Selectors rebuild.
    // Calling notifyListeners() from the widget is not possible because
    // ChangeNotifier.notifyListeners() is @protected.  The model exposes a
    // public method for exactly this purpose.
    if (success) {
      _model.onRefresh();
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

          final enrollResult = snapshot.data!;
          if (enrollResult.isNotEnrolled) {
            return NoContentCard(
              type: NoContentType.enroll,
              active: false,
              phrase:
              'Non sei iscritto a questo torneo e pertanto non puoi '
                  'caricare una decklist. Se pensi sia un errore, contatta '
                  "l'organizzatore.",
            );
          }

          //The decklist area rebuild according to tournament state.
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: _Dims.fieldSpacing,),
              _DecklistSection(enrollmnentCheckResult: enrollResult, model: model,),
              SizedBox(height: _Dims.fieldSpacing,),
              Selector<TournamentDecklistModel, StateTournament>(
                selector: (_, m) => m.tournamentState,
                builder: (_, state, ___) {
                  if(state == StateTournament.close){
                    return NoContentCard(
                      type: NoContentType.enroll,
                      active: false,
                      phrase:
                      'Non sei iscritto a questo torneo e pertanto non puoi '
                          'caricare una decklist. Se pensi sia un errore, contatta '
                          "l'organizzatore.",
                    );
                  } else if(state == StateTournament.ongoing){
                    return const NoContentCard(
                      type: NoContentType.ongoing,
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
                    enrollmentCheckResult: enrollResult
                  );
                },
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
    required this.enrollmentCheckResult,
  });

  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;
  final TournamentDecklistModel model;
  final EnrollmentCheckResult enrollmentCheckResult;

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
            _YdkFileField(model: model, enrollmentCheckResult: enrollmentCheckResult),
            _YdkLinkField(model: model, onSave: onSave, enrollmentCheckResult: enrollmentCheckResult),
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
  const _YdkFileField({
    required this.model,
    required this.enrollmentCheckResult,
  });

  final TournamentDecklistModel model;
  final EnrollmentCheckResult enrollmentCheckResult;

  Future<void> _onUploadYdk(BuildContext context) async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('DECKLIST_LOAD_YDK_FILE');
    HapticFeedback.lightImpact();

    FilePickerResult? result;
    try {
      result = await FilePicker.pickFiles(
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
    final SnackBarService snackBarService = GetIt.instance<SnackBarService>();
    if (path == null) {
      // path is null on web — guard in case the app is ever ported.
      snackBarService.showSnackBar(
        message: 'File non accessibile. Riprova.',
        title: 'Errore',
        style: SnackbarStyle.error,
      );
      return;
    }

    bool res = await model.manageFile(path, enrollmentCheckResult);
    if(!res){
      snackBarService.showSnackBar(
        message: 'Errore durante il caricamento del file. Riprova.',
        title: 'Errore',
        style: SnackbarStyle.error,
      );
      return;
    } else {
      snackBarService.showSnackBar(
        message: 'La lista è stata correttamente salvata',
        title: 'Caricamento completato',
        style: SnackbarStyle.success,
      );
    }
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
  const _YdkLinkField({
    required this.model,
    required this.onSave,
    required this.enrollmentCheckResult,
  });

  final TournamentDecklistModel model;
  final EnrollmentCheckResult enrollmentCheckResult;

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
            controller: model.tournamentDecklistTextController,
            focusNode: model.tournamentDecklistFocusNode,
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
            validator: model.tournamentDecklistTextControllerValidator.asValidator(context),
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
  const _DecklistSection({
    required this.model,
    required this.enrollmnentCheckResult
  });

  final EnrollmentCheckResult? enrollmnentCheckResult;
  final TournamentDecklistModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(_Dims.pagePadding, 0, _Dims.pagePadding, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (enrollmnentCheckResult != null && enrollmnentCheckResult!.enrollments.isNotEmpty && enrollmnentCheckResult!.enrollments.first.decklist != null) ...[
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
              child: Text(
                'Decklist attuale',
                style: CustomFlowTheme.of(context).bodyMedium,
              ),
            ),
            Container(
              width: double.infinity,
              height: 500,
              decoration: BoxDecoration(
                color: CustomFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomScrollView(
                slivers: [
                  // ── Main section ─────────────────────────────────────────────
                  _SectionHeader(
                    label: 'MAIN',
                    backgroundColor: CustomFlowTheme.of(context).secondary,
                    isExpanded: Selector<TournamentDecklistModel, bool>(
                      selector: (_, m) => m.showMainCards,
                      builder: (_, show, __) => _ToggleIcon(show: show),
                    ),
                    onToggle: model.switchShowMainCards,
                  ),

                  Selector<TournamentDecklistModel, bool>(
                    selector: (_, m) => m.showMainCards,
                    builder: (_, show, __) => show
                        ? _DecklistSliverList(
                      items: enrollmnentCheckResult!.enrollments.first.decklist!.main.entries.toList(),
                      listKey: 'main',
                      emptyPhrase: 'Nessuna carta nel main deck.',
                    )
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  /*
                  SliverToBoxAdapter(
                    child: _SectionFooter(color: CustomFlowTheme.of(context).secondary),
                  ),*/

                  // ── Main section ─────────────────────────────────────────────
                  _SectionHeader(
                    label: 'SIDE',
                    backgroundColor: CustomFlowTheme.of(context).secondary,
                    isExpanded: Selector<TournamentDecklistModel, bool>(
                      selector: (_, m) => m.showSideCards,
                      builder: (_, show, __) => _ToggleIcon(show: show),
                    ),
                    onToggle: model.switchShowSideCards,
                  ),

                  Selector<TournamentDecklistModel, bool>(
                    selector: (_, m) => m.showSideCards,
                    builder: (_, show, __) => show
                        ? _DecklistSliverList(
                      items: enrollmnentCheckResult!.enrollments.first.decklist!.side.entries.toList(),
                      listKey: 'main',
                      emptyPhrase: 'Nessuna carta nel side deck.',
                    )
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  /*
                  SliverToBoxAdapter(
                    child: _SectionFooter(color: CustomFlowTheme.of(context).secondary),
                  ),*/

                  // ── Main section ─────────────────────────────────────────────
                  _SectionHeader(
                    label: 'EXTRA',
                    backgroundColor: CustomFlowTheme.of(context).secondary,
                    isExpanded: Selector<TournamentDecklistModel, bool>(
                      selector: (_, m) => m.showExtraCards,
                      builder: (_, show, __) => _ToggleIcon(show: show),
                    ),
                    onToggle: model.switchShowExtraCards,
                  ),

                  Selector<TournamentDecklistModel, bool>(
                    selector: (_, m) => m.showExtraCards,
                    builder: (_, show, __) => show
                        ? _DecklistSliverList(
                      items: enrollmnentCheckResult!.enrollments.first.decklist!.extra.entries.toList(),
                      listKey: 'main',
                      emptyPhrase: 'Nessuna carta nell\'extra deck.',
                    )
                        : const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),

                  /*
                  SliverToBoxAdapter(
                    child: _SectionFooter(color: CustomFlowTheme.of(context).secondary),
                  ),*/
                ],
              ),
            ),
          ] else ...[
            const NoContentCard(
              type: NoContentType.pick,
              active: false,
              phrase: 'Nessuna decklist caricata.',
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION HEADER
// Accepts a pre-built widget for isExpanded so the caller can wrap it in a
// Selector without this widget needing to know about the model.
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.backgroundColor,
    required this.isExpanded,
    required this.onToggle,
  });

  final String label;
  final Color backgroundColor;
  final Widget isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      expandedHeight: _Dims.sliverAppBarExpandedHeight,
      collapsedHeight: _Dims.sliverAppBarExpandedHeight,
      toolbarHeight: _Dims.sliverAppBarExpandedHeight,
      backgroundColor: backgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          label,
          style: CustomFlowTheme.of(context).headlineLarge,
          textAlign: TextAlign.center,
        ),
        expandedTitleScale: 1,
        titlePadding: const EdgeInsetsDirectional.fromSTEB(
          0,
          _Dims.titlePaddingTop,
          0,
          _Dims.titlePaddingBottom,
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: isExpanded,
          onPressed: onToggle,
        ),
      ],
    );
  }
}


// ---------------------------------------------------------------------------
// TOGGLE ICON
// ---------------------------------------------------------------------------

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Icon(
      show ? Icons.remove_circle : Icons.add_circle,
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION FOOTER
//
// FIX: width: double.infinity removed from the inner SizedBox.
//   DecoratedBox inside SliverToBoxAdapter already fills the sliver
//   cross-axis — the explicit width on the child SizedBox had no effect.
// ---------------------------------------------------------------------------

class _SectionFooter extends StatelessWidget {
  const _SectionFooter({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(_Dims.sectionFooterRadius),
          bottomRight: Radius.circular(_Dims.sectionFooterRadius),
        ),
      ),
      child: const SizedBox(height: _Dims.sectionFooterHeight),
    );
  }
}


// ---------------------------------------------------------------------------
// TOURNAMENT SLIVER LIST
// ---------------------------------------------------------------------------

class _DecklistSliverList extends StatelessWidget {
  const _DecklistSliverList({
    required this.items,
    required this.listKey,
    required this.emptyPhrase,
  });

  // Map<CardRef, int> entries → list of (card, count) pairs
  final List<MapEntry<CardRef, int>> items;
  final String listKey;
  final String emptyPhrase;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverToBoxAdapter(
        child: NoContentCard(
          type: NoContentType.pick,
          active: false,
          phrase: emptyPhrase,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final entry = items[index];
          return TournamentDecklistCardWidget(
            key: ValueKey('${listKey}_${entry.key.id}'),
            cardRef: entry.key,
            qty: entry.value,
          );
        },
        childCount: items.length,
      ),
    );
  }
}
