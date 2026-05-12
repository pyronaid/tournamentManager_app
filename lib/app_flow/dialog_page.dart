import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';

import '../backend/firebase_analytics/analytics.dart';
import 'app_flow_util.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: ConstrainedBox(maxHeight: 45.h) in _buildFormSection replaced with a
//   fraction of the available height resolved by LayoutBuilder.
//
//   45% of screen height fails in two ways:
//   1. On a small phone (600dp) 45% = 270dp — may be too tight for a
//      calendar form element.
//   2. On a large tablet (1200dp) 45% = 540dp — the form section takes
//      more than half the dialog height unnecessarily.
//
//   LayoutBuilder is placed at the dialog scaffold level so the resolved
//   height flows down to both the form section constraint and any future
//   consumer, avoiding redundant MediaQuery calls.
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// The form section inside DialogFormWidget is constrained to this fraction
  /// of the available dialog height.  0.45 preserves the original 45%
  /// intent but is now resolved from actual layout constraints.
  static const double formSectionHeightFraction = 0.45;

  /// Loading spinner size inside the indicator widget.
  static const double loadingIndicatorSize = 20.0;

  /// Loading spinner stroke width.
  static const double loadingStrokeWidth = 2.0;

  /// Dialog outer margin.
  static const double dialogMargin = 32.0;

  /// Dialog inner padding.
  static const double dialogPadding = 24.0;

  /// Dialog corner radius.
  static const double dialogRadius = 16.0;

  /// Space between title and description.
  static const double titleDescSpacing = 24.0;

  /// Space between description and form / action buttons.
  static const double descActionsSpacing = 32.0;

  /// Space between form section and action buttons.
  static const double formActionsSpacing = 32.0;

  /// Loading overlay corner radius — matches dialogRadius.
  static const double overlayRadius = 16.0;

  /// Space between loading spinner and label.
  static const double overlaySpinnerLabelGap = 16.0;

  /// Error / empty state inner padding.
  static const double statePaddingAll = 16.0;

  /// Button gap in DialogActionButtons.
  static const double buttonGap = 8.0;

  /// Button corner radius.
  static const double buttonRadius = 8.0;

  /// Dialog barrier scrim opacity.
  static const double scrimOpacity = 0.5;

  /// Loading overlay surface opacity.
  static const double overlayOpacity = 0.8;
}

// ---------------------------------------------------------------------------
// DIALOG ACTION BUTTONS
// ---------------------------------------------------------------------------
class DialogActionButtons extends StatelessWidget {
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isLoading;
  final bool isConfirmEnabled;
  final Color? confirmColor;

  const DialogActionButtons({
    super.key,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
    this.isConfirmEnabled = true,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: _Dims.buttonGap),
            child: ElevatedButton(
              onPressed: isLoading ? null : onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_Dims.buttonRadius),
                ),
              ),
              child: Text(
                cancelButtonText,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: _Dims.buttonGap),
            child: ElevatedButton(
              onPressed: (isLoading || !isConfirmEnabled) ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_Dims.buttonRadius),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: _Dims.loadingIndicatorSize,
                      width: _Dims.loadingIndicatorSize,
                      child: CircularProgressIndicator(
                        strokeWidth: _Dims.loadingStrokeWidth,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      confirmButtonText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG PAGE
// ---------------------------------------------------------------------------
class DialogPage<T> extends Page<T> {
  final Offset? anchorPoint;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final bool useSafeArea;
  final CapturedThemes? themes;
  final WidgetBuilder builder;

  const DialogPage({
    required this.builder,
    this.anchorPoint,
    this.barrierColor,
    this.barrierDismissible = true,
    this.barrierLabel,
    this.useSafeArea = true,
    this.themes,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    final theme = Theme.of(context);
    return DialogRoute<T>(
      context: context,
      settings: this,
      builder: builder,
      anchorPoint: anchorPoint,
      barrierColor: barrierColor ??
          theme.colorScheme.scrim.withValues(alpha: _Dims.scrimOpacity),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes,
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG WIDGET
// ---------------------------------------------------------------------------
class DialogWidget extends StatefulWidget {
  final AlertRequest request;

  const DialogWidget({super.key, required this.request});

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: colorScheme.scrim.withValues(alpha: _Dims.scrimOpacity),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(_Dims.dialogMargin),
            child: Material(
              type: MaterialType.card,
              elevation: 24,
              color: colorScheme.surface,
              surfaceTintColor: colorScheme.surfaceTint,
              borderRadius: BorderRadius.circular(_Dims.dialogRadius),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(_Dims.dialogPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.request.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: _Dims.titleDescSpacing),
                        Text(
                          widget.request.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: _Dims.descActionsSpacing),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                  if (_isLoading) _LoadingOverlay(request: widget.request),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DialogActionButtons(
      cancelButtonText: widget.request.buttonTitleCancelled,
      confirmButtonText: widget.request.buttonTitleConfirmed,
      isLoading: _isLoading,
      confirmColor: widget.request.isDestructive ? colorScheme.error : null,
      onCancel: () {
        if (!_isLoading) {
          Router.neglect(context, () => context.safePop());
        }
      },
      onConfirm: () async {
        setState(() => _isLoading = true);
        try {
          if (widget.request.functionConfirmed != null) {
            await widget.request.functionConfirmed!(null);
          }
          if (!mounted) return;
          if (widget.request.redirectConfirmed != null) {
            logFirebaseEvent('Button_navigate_to');
            context.goNamed(
              widget.request.redirectConfirmed!,
              extra: <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          } else {
            Router.neglect(context, () => context.safePop());
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showErrorSnackbar(context, e);
        }
      },
    );
  }

  void _showErrorSnackbar(BuildContext context, Object error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Si è verificato un errore: ${error.toString()}'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG FORM WIDGET
//
// FIX: ConstrainedBox(maxHeight: 45.h) replaced with LayoutBuilder.
//   The LayoutBuilder is placed at the Scaffold body level so the resolved
//   height is available for the form section constraint without threading
//   it through multiple constructor parameters.
// ---------------------------------------------------------------------------
class DialogFormWidget extends StatefulWidget {
  final AlertFormRequest request;

  const DialogFormWidget({super.key, required this.request});

  @override
  State<DialogFormWidget> createState() => _DialogFormWidgetState();
}

class _DialogFormWidgetState extends State<DialogFormWidget> {
  late final List<Future<FormInformation>> _formInformation;
  late final Future<List<FormInformation>> _allFormsFuture;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _formInformation =
        widget.request.formInfo.map((func) => func()).toList();
    _allFormsFuture = Future.wait(_formInformation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        // FIX: LayoutBuilder resolves the actual available height here —
        //   the form section receives a concrete pixel constraint derived
        //   from constraints.maxHeight * formSectionHeightFraction.
        builder: (context, constraints) {
          final formMaxHeight =
              constraints.maxHeight * _Dims.formSectionHeightFraction;

          return Container(
            color: colorScheme.scrim
                .withValues(alpha: _Dims.scrimOpacity),
            child: Center(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(_Dims.dialogMargin),
                  child: Material(
                    type: MaterialType.card,
                    elevation: 24,
                    color: colorScheme.surface,
                    surfaceTintColor: colorScheme.surfaceTint,
                    borderRadius:
                        BorderRadius.circular(_Dims.dialogRadius),
                    child: FutureBuilder<List<FormInformation>>(
                      future: _allFormsFuture,
                      builder: (context, snapshot) {
                        final bool isReady =
                            snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData &&
                                snapshot.data!.isNotEmpty;

                        return Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(
                                  _Dims.dialogPadding),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.request.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                      height: _Dims.titleDescSpacing),
                                  Text(
                                    widget.request.description,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                      height: _Dims.descActionsSpacing),
                                  // FIX: formMaxHeight resolved by
                                  //   LayoutBuilder above — no package needed.
                                  _buildFormSection(
                                      context, snapshot, formMaxHeight),
                                  const SizedBox(
                                      height: _Dims.formActionsSpacing),
                                  _buildActionButtons(
                                      context, snapshot, isReady),
                                ],
                              ),
                            ),
                            if (_isLoading)
                              _LoadingOverlay(request: widget.request),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    AsyncSnapshot<List<FormInformation>> snapshot,
    double maxHeight,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: _FormSectionContent(
        snapshot: snapshot,
        formKey: _formKey,
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AsyncSnapshot<List<FormInformation>> snapshot,
    bool isReady,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return DialogActionButtons(
      cancelButtonText: widget.request.buttonTitleCancelled,
      confirmButtonText: widget.request.buttonTitleConfirmed,
      isLoading: _isLoading,
      isConfirmEnabled: isReady,
      confirmColor:
          widget.request.isDestructive ? colorScheme.error : null,
      onCancel: () {
        if (!_isLoading) {
          Router.neglect(context, () => context.safePop());
        }
      },
      onConfirm: () async {
        if (!isReady) return;
        if (!(_formKey.currentState?.validate() ?? false)) return;

        setState(() => _isLoading = true);

        try {
          final formValues =
              snapshot.data!.map((inf) => inf.result()).toList();
          if (widget.request.functionConfirmed != null) {
            await widget.request.functionConfirmed!(formValues);
          }
          if (!mounted) return;
          if (widget.request.redirectConfirmed != null) {
            logFirebaseEvent('Button_navigate_to');
            context.goNamed(
              widget.request.redirectConfirmed!,
              extra: <String, dynamic>{
                kTransitionInfoKey: const TransitionInfo(
                  hasTransition: true,
                  transitionType: PageTransitionType.fade,
                  duration: Duration(milliseconds: 0),
                ),
              },
            );
          } else {
            Router.neglect(context, () => context.safePop());
          }
        } catch (e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Si è verificato un errore: ${e.toString()}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// FORM SECTION CONTENT
// ---------------------------------------------------------------------------
class _FormSectionContent extends StatelessWidget {
  const _FormSectionContent({
    required this.snapshot,
    required this.formKey,
  });

  final AsyncSnapshot<List<FormInformation>> snapshot;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(_Dims.statePaddingAll),
          child: Text(
            'Errore nel caricamento del modulo: ${snapshot.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return const Center(child: Text('Nessun dato disponibile'));
    }

    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: snapshot.data!,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LOADING OVERLAY
// ---------------------------------------------------------------------------
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.request});

  final dynamic request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String label = (request is AlertRequest || request is AlertFormRequest)
        ? (request.processingLabel as String? ?? 'Elaborazione in corso...')
        : 'Elaborazione in corso...';

    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface
              .withValues(alpha: _Dims.overlayOpacity),
          borderRadius: BorderRadius.circular(_Dims.overlayRadius),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.primary,
                ),
              ),
              const SizedBox(height: _Dims.overlaySpinnerLabelGap),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
