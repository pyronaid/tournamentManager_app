import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';

import '../backend/firebase_analytics/analytics.dart';
import 'app_flow_util.dart';

class DialogActionButtons extends StatelessWidget {
  final String cancelButtonText;
  final String confirmButtonText;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool isLoading;
  final bool isConfirmEnabled;

  const DialogActionButtons({
    super.key,
    required this.cancelButtonText,
    required this.confirmButtonText,
    required this.onCancel,
    required this.onConfirm,
    this.isLoading = false,
    this.isConfirmEnabled = true,
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
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onError,
                  ),
                ),
              ) : Text(
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
    final extra = GoRouterState.of(context).extra;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If accessed with browser's forwarded button (no 'extra' data will exist), navigate back programmatically
    if (extra == null) {
      // Use addPostFrameCallback to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Router.neglect(context, () => context.safePop());
      });
      // Return an empty container while redirecting
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: colorScheme.scrim.withValues(alpha: 0.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
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
                            _buildActionButtons(context, theme, colorScheme),
                          ],
                        ),
                      ),
                      if(_isLoading) ...[
                        Positioned.fill(
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
                                    'Processing...',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return DialogActionButtons(
      cancelButtonText: request.buttonTitleCancelled,
      confirmButtonText: request.buttonTitleConfirmed,
      onCancel: () {
        Router.neglect(context, () => context.safePop());
      },
      onConfirm: () async {
        if (request.functionConfirmed != null) {
          await request.functionConfirmed!(null);
        }
        if (request.redirectConfirmed != null) {
          logFirebaseEvent('Button_navigate_to');
          context.goNamed(
            request.redirectConfirmed!,
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
      },
    );
  }
}

class DialogFormWidget extends StatefulWidget {
  final AlertFormRequest request;

  const DialogFormWidget({super.key, required this.request});

  @override
  State<DialogFormWidget> createState() => _DialogFormWidgetState();
}

class _DialogFormWidgetState extends State<DialogFormWidget> {
  late List<Future<FormInformation>> _formInformation;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Generate FormInformation objects when the widget initializes
    _formInformation = widget.request.formInfo.map((func) => func()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If accessed with browser's forwarded button (no 'extra' data will exist), navigate back programmatically
    if (extra == null) {
      // Use addPostFrameCallback to avoid build-time navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Router.neglect(context, () => context.safePop());
      });
      // Return an empty container while redirecting
      return Container();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        color: colorScheme.scrim.withValues(alpha: 0.5),
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {},
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            Center(
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
                    child: Padding(
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
                          _buildFormSection(context, theme, colorScheme),
                          const SizedBox(height: 32),
                          _buildActionButtons(context, theme, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 45.h,
      ),
      child: FutureBuilder<List<FormInformation>>(
        future: Future.wait(_formInformation),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error loading form: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }
          // Success state
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No form data available'),
            );
          }
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: snapshot.data!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return FutureBuilder<List<FormInformation>>(
      future: Future.wait(_formInformation),
      builder: (BuildContext context, AsyncSnapshot<List<FormInformation>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return DialogActionButtons(
            cancelButtonText: widget.request.buttonTitleCancelled,
            confirmButtonText: widget.request.buttonTitleConfirmed,
            onCancel: () {
              Router.neglect(context, () => context.safePop());
            },
            onConfirm: () {},
            isLoading: true,
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return DialogActionButtons(
            cancelButtonText: widget.request.buttonTitleCancelled,
            confirmButtonText: widget.request.buttonTitleConfirmed,
            onCancel: () {
              Router.neglect(context, () => context.safePop());
            },
            onConfirm: () {},
            isConfirmEnabled: false,
          );
        }

        return DialogActionButtons(
          cancelButtonText: widget.request.buttonTitleCancelled,
          confirmButtonText: widget.request.buttonTitleConfirmed,
          onCancel: () {
            Router.neglect(context, () => context.safePop());
          },
          onConfirm: () async {
            if (_formKey.currentState?.validate() ?? false) {
              List<dynamic> formValues = snapshot.data!.map((inf) => inf.result()).toList();
              if (widget.request.functionConfirmed != null) {
                await widget.request.functionConfirmed!(formValues);
              }
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
            }
          },
        );
      },
    );
  }
}