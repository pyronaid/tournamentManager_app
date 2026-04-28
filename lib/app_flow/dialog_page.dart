import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';

import '../backend/firebase_analytics/analytics.dart';
import 'app_flow_util.dart';

// ---------------------------------------------------------------------------
// DIALOG ACTION BUTTONS
// Reusable confirm/cancel button row.
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
            padding: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: isLoading ? null : onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.surfaceContainerHighest,
                foregroundColor: colorScheme.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.only(left: 8),
            child: ElevatedButton(
              onPressed: (isLoading || !isConfirmEnabled) ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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
// Wraps a WidgetBuilder in a DialogRoute so GoRouter can push it as a
// full-screen dialog with the correct barrier and animation.
//
// Usage note: always set parentNavigatorKey: NavigatorKeys.rootNavigator
// on the GoRoute that uses this page, otherwise the dialog renders clipped
// inside the shell's nested navigator.
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
      barrierColor: barrierColor ?? theme.colorScheme.scrim.withValues(alpha: 0.5),
      barrierDismissible: barrierDismissible,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      themes: themes,
    );
  }
}

// ---------------------------------------------------------------------------
// DIALOG WIDGET
// Simple confirmation dialog (title + description + confirm/cancel).
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
        color: colorScheme.scrim.withValues(alpha: 0.5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            child: Material(
              type: MaterialType.card,
              elevation: 24,
              color: colorScheme.surface,
              surfaceTintColor: colorScheme.surfaceTint,
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
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
                        const SizedBox(height: 24),
                        Text(
                          widget.request.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        _buildActionButtons(context),
                      ],
                    ),
                  ),
                  // Loading overlay
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
// Dialog with a dynamic form section built from AlertFormRequest.formInfo.
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
    // FIX: resolve Future.wait once and reuse — both form section and
    // action buttons share the same future instance so Flutter's
    // FutureBuilder deduplicates the resolution automatically.
    _allFormsFuture = Future.wait(_formInformation);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: colorScheme.scrim.withValues(alpha: 0.5),
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Material(
                type: MaterialType.card,
                elevation: 24,
                color: colorScheme.surface,
                surfaceTintColor: colorScheme.surfaceTint,
                borderRadius: BorderRadius.circular(16),
                // FIX: single FutureBuilder wraps the whole card content —
                // snapshot resolved once and passed to both sub-builders.
                child: FutureBuilder<List<FormInformation>>(
                  future: _allFormsFuture,
                  builder: (context, snapshot) {
                    final bool isReady =
                        snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData &&
                            snapshot.data!.isNotEmpty;

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24),
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
                              const SizedBox(height: 24),
                              Text(
                                widget.request.description,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              // Pass resolved snapshot directly.
                              _buildFormSection(context, snapshot),
                              const SizedBox(height: 32),
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
      ),
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    AsyncSnapshot<List<FormInformation>> snapshot,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 45.h),
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
        // Defensive guard — button is already disabled when !isReady,
        // but guard here in case of race conditions.
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
// PRIVATE: FORM SECTION CONTENT
// Extracted to keep _DialogFormWidgetState.build readable.
// Handles all three snapshot states (loading / error / data).
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
          padding: const EdgeInsets.all(16),
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
// PRIVATE: LOADING OVERLAY
// Shared between DialogWidget and DialogFormWidget.
// FIX: loading text now reads from request.processingLabel so it can be
// localised at the call site rather than hardcoded as "Processing...".
// ---------------------------------------------------------------------------
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.request});

  // Accept the base AlertRequest so both dialog types can use this widget.
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
          color: colorScheme.surface.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
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
              const SizedBox(height: 16),
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
