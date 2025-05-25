import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/loader_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/loader_route.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_content.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_overlay.dart';
import 'package:tournamentmanager/components/generic_loading/generic_loading_widget.dart';
import 'package:uuid/uuid.dart';


class ServiceManager extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const ServiceManager({
    super.key,
    required this.navigatorKey,
    required this.child,
  });

  @override
  State<ServiceManager> createState() => _ServiceManagerState();
}

class _ServiceManagerState extends State<ServiceManager> {
  //////////////////////////SNACKBAR SERVICE
  final SnackBarService _snackBarService = GetIt.instance<SnackBarService>();
  final List<SnackbarOverlay> _overlays = [];
  final List<SnackBarRequest> _snackbarQueue = [];
  bool _isProcessingSnackbar = false;
  //////////////////////////LOADER SERVICE
  final LoaderService _loaderService = GetIt.instance<LoaderService>();
  final List<LoaderRoute> _loaders = [];

  @override
  void initState() {
    super.initState();
    //////////////////////////SNACKBAR SERVICE
    _snackBarService.registerSnackBarListener(_showSnackBar);
    //////////////////////////LOADER SERVICE
    _loaderService.registerLoaderListener(_showLoader);
    _loaderService.registerLoaderCompleter(_hideLoader);

    // Listen to route changes to manage snackbar persistence
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupRouteObserver();
    });
  }

  void _setupRouteObserver() {
    widget.navigatorKey.currentState?.widget;
    // You can add route observer here if needed for advanced route management
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    // Clean up all overlays
    _clearAllOverlays();
    super.dispose();
  }

  //////////////////////////SNACKBAR SERVICE
  void _showSnackBar(SnackBarRequest request) async {
    // Add to queue for better management across page transitions
    _snackbarQueue.add(request);
    _processSnackbarQueue();
  }

  void _processSnackbarQueue() async {
    if (_isProcessingSnackbar || _snackbarQueue.isEmpty) return;

    _isProcessingSnackbar = true;

    while (_snackbarQueue.isNotEmpty) {
      final request = _snackbarQueue.removeAt(0);
      await _displaySnackbar(request);

      // Small delay between snackbars for better UX
      if (_snackbarQueue.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }

    _isProcessingSnackbar = false;
  }

  Future<void> _displaySnackbar(SnackBarRequest request) async {
    if (request.message.isEmpty) return;

    // Use navigator context for root overlay access
    final navigatorState = widget.navigatorKey.currentState;
    if (navigatorState == null) {
      debugPrint('ServiceManager: Navigator state is null, cannot show snackbar');
      return;
    }

    try {
      // Get overlay from navigator context - this ensures persistence across routes
      final navigatorContext = navigatorState.context;
      final overlayState = Overlay.of(navigatorContext);

      final overlay = SnackbarOverlay(id: const Uuid().v4());

      OverlayEntry overlayEntry = OverlayEntry(
        builder: (context) {
          return SnackBarContent(
            overlay: overlay,
            message: request.message,
            style: request.style,
            position: request.position,
            duration: request.duration,
            onCloseClicked: (currentOverlay) {
              _removeOverlay(currentOverlay);
            },
          );
        },
      );

      overlay.overlay = overlayEntry;
      _overlays.add(overlay);
      overlayState.insert(overlayEntry);

      debugPrint('ServiceManager: Snackbar displayed successfully with ID: ${overlay.id}');

    } catch (e) {
      debugPrint('ServiceManager: Error displaying snackbar: $e');
    }
  }

  void _removeOverlay(SnackbarOverlay overlay) {
    try {
      overlay.overlay.remove();
      _overlays.removeWhere((element) => element.id == overlay.id);
      debugPrint('ServiceManager: Overlay removed with ID: ${overlay.id}');
    } catch (e) {
      debugPrint('ServiceManager: Error removing overlay: $e');
    }
  }

  void _clearAllOverlays() {
    for (final overlay in _overlays) {
      try {
        overlay.overlay.remove();
      } catch (e) {
        debugPrint('ServiceManager: Error removing overlay during cleanup: $e');
      }
    }
    _overlays.clear();
    _snackbarQueue.clear();
  }

  //////////////////////////LOADER SERVICE
  void _showLoader(LoaderRequest request){
    assert(widget.navigatorKey.currentState != null, 'Tried to show loader but navigatorState was null. Key was :${widget.navigatorKey}');
    final navigatorState = widget.navigatorKey.currentState!;
    assert(
    _loaders.where((element) => element.id == request.id).toList().isEmpty,
    'There is already a loader showing with id: ${request.id}',
    );

    final route = LoaderRoute(
      id: request.id,
      barrierDismissible: request.barrierDismissible,
      context: navigatorState.context,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
        },
        child: const Center(
          child: GenericLoadingWidget(),
        ),
      ),
    );

    _loaders.add(route);
    navigatorState.push(route);
  }

  void _hideLoader(LoaderRequest request) {
    if (_loaders.isEmpty) {
      debugPrint('ServiceManager: There is no loader to hide');
      return;
    }
    assert(
    _loaders.where((element) => element.id == request.id).toList().isNotEmpty,
    'Tried to close loader with id: ${request.id} which does not exist',
    );
    assert(
    widget.navigatorKey.currentState !=null,
    'Tried to hide loader but navigatorState was null. Key was :${widget.navigatorKey}');
    final navigatorState = widget.navigatorKey.currentState!;
    final routeIndex = _loaders.indexWhere((element) =>
    element.id == request.id);
    navigatorState.removeRoute(_loaders.removeAt(routeIndex));
  }
}