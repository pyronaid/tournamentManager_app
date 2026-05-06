import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/pages/core/create_edit_news/create_edit_news_model.dart';
import 'package:tournamentmanager/pages/nav_bar/news_model.dart';

import '../../../app_flow/services/SnackBarService.dart';
import '../../../app_flow/services/supportClass/snackbar_style.dart';


// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double fieldSpacing      = 30.0;
  static const double buttonHeight      = 50.0;
  static const double buttonRadius      = 25.0;
  static const double imageButtonWidth  = 40; // used as 40.w (responsive)
  static const double prefixIconSize    = 18.0;
  static const double sectionBorderWidth = 1.0;
}

class CreateEditNewsWidget extends StatefulWidget {
  const CreateEditNewsWidget({super.key});

  @override
  State<CreateEditNewsWidget> createState() => _CreateEditNewsWidgetState();
}

class _CreateEditNewsWidgetState extends State<CreateEditNewsWidget> {
  // Owned by the State so they survive rebuilds.
  final _formKey = GlobalKey<FormState>();

  late final CreateEditNewsModel _model;
  late final SnackBarService snackBarService;

  @override
  void initState() {
    super.initState();

    _model = context.read<CreateEditNewsModel>();
    snackBarService = GetIt.instance<SnackBarService>();
  }

  // ── Save / submit handler ──────────────────────────────────────────────────
  // Extracted from onPressed so it can be read, tested, and reasoned about
  // independently from the button widget that triggers it.
  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();

    // Analytics: fire the correct event based on create vs edit mode.
    _model.saveWayEn
        ? logFirebaseEvent('ONBOARDING_CREATE_NEWS_CREATE_NEWS')
        : logFirebaseEvent('ONBOARDING_EDIT_NEWS_EDIT_NEWS');

    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    final newsModel = context.read<NewsModel>();
    final result = await newsModel.saveEditNews(
      _model.saveWayEn,
      _model.fieldControllerTitle.text,
      _model.fieldControllerSubTitle.text,
      _model.fieldControllerDescription.text,
      _model.newsImageUrlTemp,
      _model.newsShowTimestampEnVar,
    );
    snackBarService.showSnackBar(
        message: result ? 'News creata/modificata con successo' : 'Errore nella creazione della News. Riprova più tardi',
        title: 'Creazione/Modifica News',
        style: result ? SnackbarStyle.success : SnackbarStyle.error);


    // Guard: the widget might have been disposed during the async save.
    if (!mounted) return;

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();

    if (result) context.safePop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          // Align(topCenter) removed: SingleChildScrollView already aligns
          // its child to the top by default.
          child: SingleChildScrollView(
            // Selector on isLoading only: rebuilds this subtree only when the
            // loading flag changes, not on every NewsModel notification.
            child: Selector<NewsModel, bool>(
              selector: (_, m) => m.isLoading,
              builder: (context, isLoading, _) {
                if (isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return _CreateEditNewsForm(
                  model: _model,
                  formKey: _formKey,
                  onSave: _handleSave,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM BODY
// Purely presentational. Receives everything it needs via constructor.
// No Provider.of / context.read calls inside — all data flows in from above.
// ---------------------------------------------------------------------------

class _CreateEditNewsForm extends StatelessWidget {
  const _CreateEditNewsForm({
    required this.model,
    required this.formKey,
    required this.onSave,
  });

  final CreateEditNewsModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header (appbar + page title) ──────────────────────────────────
        _FormHeader(model: model),

        // ── Form fields ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                _LabelledFormField(
                  label: 'Titolo news',
                  controller: model.fieldControllerTitle,
                  focusNode: model.newsTitleFocusNode,
                  prefixIcon: Icons.title,
                  validator: model.newsTitleTextControllerValidator
                      .asValidator(context),
                ),

                // Subtitle
                _LabelledFormField(
                  label: 'Sotto Titolo news (facoltativo)',
                  controller: model.fieldControllerSubTitle,
                  focusNode: model.newsSubTitleFocusNode,
                  prefixIcon: Icons.text_fields,
                  validator: model.newsSubTitleTextControllerValidator
                      .asValidator(context),
                ),

                // Description (multiline)
                _LabelledFormField(
                  label: 'Testo news',
                  controller: model.fieldControllerDescription,
                  focusNode: model.newsDescriptionFocusNode,
                  prefixIcon: Icons.article,
                  minLines: 5,
                  maxLines: 5,
                  validator: model.newsDescriptionTextControllerValidator
                      .asValidator(context),
                ),

                // Image picker
                _ImagePickerField(model: model),

                // Show timestamp toggle
                _TimestampToggle(model: model),
              ],
            ),
          ),
        ),

        // ── Submit button ──────────────────────────────────────────────────
        _SubmitButton(model: model, onSave: onSave),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: HEADER
// ---------------------------------------------------------------------------

class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.model});

  final CreateEditNewsModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomFlowTheme.of(context).secondary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AppBar: the model listener is registered in State.initState, so
          // we build the widget directly without wrapWithModel to avoid
          // accumulating stale callbacks on each rebuild.
          CustomAppbarWidget(
            backButton: true,
            actionButton: false,
            actionButtonAction: () async {},
            optionsButtonAction: () async {},
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
            child: Text(
              model.saveWayEn
                  ? 'Crea una nuova notizia'
                  : 'Modifica notizia',
              style: CustomFlowTheme.of(context).displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: LABELLED FORM FIELD
// Replaces the three copy-pasted Title / Subtitle / Description blocks.
// Every structural difference (icon, lines, validator) is a parameter.
// ---------------------------------------------------------------------------

class _LabelledFormField extends StatelessWidget {
  const _LabelledFormField({
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.prefixIcon,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final IconData prefixIcon;
  final FormFieldValidator<String>? validator;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.fieldSpacing),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
            child: Text(label, style: CustomFlowTheme.of(context).bodyMedium),
          ),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            autofocus: false,
            autofillHints: const [AutofillHints.name],
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            obscureText: false,
            minLines: minLines,
            maxLines: maxLines,
            cursorColor: CustomFlowTheme.of(context).primary,
            decoration: standardInputDecoration(
              context,
              prefixIcon: Icon(
                prefixIcon,
                color: CustomFlowTheme.of(context).secondaryText,
                size: _Dims.prefixIconSize,
              ),
            ),
            style: CustomFlowTheme.of(context).bodyLarge.override(
              fontWeight: FontWeight.w500,
              lineHeight: 1,
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: IMAGE PICKER FIELD
// Two granular Selectors so only the image preview or the button row
// rebuilds when its specific slice of state changes — never the whole form.
// ---------------------------------------------------------------------------

/// Value object replacing Tuple2<String?, bool> for the image selector.
/// Named fields make the selector self-documenting and type-safe.
@immutable
class _ImageState {
  const _ImageState({required this.localPath, required this.useNetwork});

  final String? localPath;
  final bool useNetwork;

  @override
  bool operator ==(Object other) =>
      other is _ImageState &&
          other.localPath == localPath &&
          other.useNetwork == useNetwork;

  @override
  int get hashCode => Object.hash(localPath, useNetwork);
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({required this.model});

  final CreateEditNewsModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, _Dims.fieldSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Text(
              'Immagine news (facoltativo)',
              style: CustomFlowTheme.of(context).bodyMedium,
            ),
          ),

          // ── Image preview ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CustomFlowTheme.of(context).accent1,
              ),
              // Rebuilds only when localPath or useNetwork changes.
              child: Selector<CreateEditNewsModel, _ImageState>(
                selector: (_, m) => _ImageState(
                  localPath: m.newsImageUrlTemp,
                  useNetwork: m.useNetworkImage,
                ),
                builder: (context, imageState, _) =>
                    _ImagePreview(imageState: imageState, model: model),
              ),
            ),
          ),

          // ── Upload / delete buttons ─────────────────────────────────────
          // Rebuilds only when useNetworkImage changes (controls delete button
          // visibility).
          Selector<CreateEditNewsModel, bool>(
            selector: (_, m) => m.useNetworkImage,
            builder: (context, useNetwork, _) =>
                _ImageActionButtons(model: model, showDelete: useNetwork),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageState, required this.model});

  final _ImageState imageState;
  final CreateEditNewsModel model;

  @override
  Widget build(BuildContext context) {
    if (imageState.useNetwork) {
      // Read the current network URL directly from NewsModel — safe here
      // because this widget only rebuilds when useNetwork flips.
      final networkUrl = context.read<NewsModel>().newsImageUrl;
      if (networkUrl == null) return const Text('Nessuna immagine caricata');

      return Image.network(
        networkUrl,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return CircularProgressIndicator(
            value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                progress.expectedTotalBytes!
                : null,
          );
        },
        errorBuilder: (_, __, ___) => Icon(
          Icons.error,
          color: CustomFlowTheme.of(context).error,
          size: _Dims.prefixIconSize,
        ),
      );
    }

    if (imageState.localPath != null) {
      return Image.file(File(imageState.localPath!));
    }

    return const Text('Nessuna immagine caricata');
  }
}

class _ImageActionButtons extends StatelessWidget {
  const _ImageActionButtons({
    required this.model,
    required this.showDelete,
  });

  final CreateEditNewsModel model;
  final bool showDelete;

  void _onUpload(BuildContext context) async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('Button_load_pic');
    HapticFeedback.lightImpact();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const _ImageSourceSheet(),
    );
    if (source == null) return;
    if (!context.mounted) return;

    model.setNewsImage(model.saveWay, source);
    logFirebaseEvent('Button_haptic_feedback');
  }

  void _onDelete(BuildContext context) {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('Button_load_pic');
    model.cleanNewsImage(model.saveWay);
    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ImageButton(
          label: 'Carica immagine',
          onPressed: () => _onUpload(context),
        ),
        if (showDelete) ...[
          const SizedBox(width: 10),
          _ImageButton(
            label: 'Elimina immagine',
            onPressed: () => _onDelete(context),
          ),
        ],
      ],
    );
  }
}

class _ImageButton extends StatelessWidget {
  const _ImageButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AFButtonWidget(
      onPressed: onPressed,
      text: label,
      options: AFButtonOptions(
        width: _Dims.imageButtonWidth.w,
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
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Fotocamera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galleria / File'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: TIMESTAMP TOGGLE
// Rebuilds only when newsShowTimestampEnVar changes.
// ---------------------------------------------------------------------------

class _TimestampToggle extends StatelessWidget {
  const _TimestampToggle({required this.model});

  final CreateEditNewsModel model;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, _Dims.fieldSpacing),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Mostra data/ora della notizia',
            style: CustomFlowTheme.of(context).bodyMedium,
          ),
          Selector<CreateEditNewsModel, bool>(
            selector: (_, m) => m.newsShowTimestampEnVar,
            builder: (context, value, _) => Switch(
              value: value,
              onChanged: (_) => model.switchShowTimestampEn(),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: SUBMIT BUTTON
// ---------------------------------------------------------------------------

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.model, required this.onSave});

  final CreateEditNewsModel model;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
      child: AFButtonWidget(
        onPressed: onSave,
        text: model.saveWayEn ? 'Crea News' : 'Modifica News',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          color: CustomFlowTheme.of(context).primary,
          textStyle: CustomFlowTheme.of(context).titleSmall,
          elevation: 0,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: _Dims.sectionBorderWidth,
          ),
          borderRadius: BorderRadius.circular(_Dims.buttonRadius),
        ),
      ),
    );
  }
}
