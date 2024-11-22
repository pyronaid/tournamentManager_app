import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/services/DialogService.dart';
import 'package:tournamentmanager/app_flow/services/LoaderService.dart';
import 'package:tournamentmanager/app_flow/services/SnackBarService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/loader_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/loader_route.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_classes.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_content.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_overlay.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
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
  //////////////////////////DIALOG SERVICE
  final DialogService _dialogService = GetIt.instance<DialogService>();
  //////////////////////////SNACKBAR SERVICE
  final SnackBarService _snackBarService = GetIt.instance<SnackBarService>();
  final List<SnackbarOverlay> _overlays = [];
  //////////////////////////LOADER SERVICE
  final LoaderService _loaderService = GetIt.instance<LoaderService>();
  final List<LoaderRoute> _loaders = [];

  @override
  void initState() {
    super.initState();
    //////////////////////////DIALOG SERVICE
    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerDialogFormListener(_showDialogForm);
    //////////////////////////SNACKBAR SERVICE
    _snackBarService.registerSnackBarListener(_showSnackBar);
    //////////////////////////LOADER SERVICE
    _loaderService.registerLoaderListener(_showLoader);
    _loaderService.registerLoaderCompleter(_hideLoader);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void dispose() {
    super.dispose();
  }
  //////////////////////////DIALOG SERVICE
  void _showDialog(AlertRequest request) {
    showDialog(
      context: context,
      builder: (_) {
        return PopScope(
          onPopInvoked: (bool didPop) {
            if(!_dialogService.dialogIsCompleted()) {
              _dialogService.dialogComplete(AlertResponse(confirmed: false));
            }
          },
          child: AlertDialog(
            title: Text(request.title),
            content: Text(
              request.description,
              style: CustomFlowTheme.of(context).labelMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _dialogService.dialogComplete(AlertResponse(confirmed: false));
                  Navigator.of(context).pop();
                },
                child: Text(request.buttonTitleCancelled),
              ),
              ElevatedButton(
                onPressed: () {
                  _dialogService.dialogComplete(AlertResponse(confirmed: true));
                  Navigator.of(context).pop();
                },
                child: Text(request.buttonTitleConfirmed),
              ),
            ],
          ),
        );
      }
    );
  }
  void _showDialogForm(AlertFormRequest request) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Column(
            children: [
              Text(request.title),
              const SizedBox(height: 20,),
              Text(
                request.description,
                style: CustomFlowTheme.of(context).labelMedium,
              ),
            ]
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 50.h,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for(int i=0; i < request.formInfo.length; i++)...[
                      request.formInfo[i],
                    ]
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _dialogService.dialogComplete(AlertResponse(confirmed: false));
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(request.buttonTitleCancelled),
            ),
            ElevatedButton(
              onPressed: () {
                logFirebaseEvent('Button_validate_form');
                if (formKey.currentState == null ||
                    !formKey.currentState!.validate()) {
                  return;
                }
                _dialogService.dialogComplete(AlertResponse(confirmed: true, formValues: request.formInfo.map((inf) => inf.result()).toList()));
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: Text(request.buttonTitleConfirmed),
            ),
          ],
        );
      }
    );
  }
  //////////////////////////SNACKBAR SERVICE
  void _showSnackBar(SnackBarRequest request) async {
    if (request.message.isEmpty) { return; }
    OverlayState? overlayState = Overlay.of(context);
    final overlay = SnackbarOverlay(id: const Uuid().v4());
    OverlayEntry overlayEntry = OverlayEntry(builder: (context) {
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
    });
    overlay.overlay = overlayEntry;
    _overlays.add(overlay);
    overlayState.insert(overlayEntry);
  }
  void _removeOverlay(SnackbarOverlay overlay) {
    overlay.overlay.remove();
    _overlays.removeWhere((element) => element.id == overlay.id);
  }
  //////////////////////////LOADER SERVICE
  void _showLoader(LoaderRequest request){
    assert(widget.navigatorKey.currentState != null, 'Tried to show dialog but navigatorState was null. Key was :${widget.navigatorKey}');
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
      debugPrint('There is no loader to hide');
      return;
    }
    assert(
      _loaders.where((element) => element.id == request.id).toList().isNotEmpty,
      'Tried to close loader with id: ${request.id} which does not exist',
    );
    assert(
      widget.navigatorKey.currentState !=null,
      'Tried to hide dialog but navigatorState was null. Key was :${widget.navigatorKey}');
    final navigatorState = widget.navigatorKey.currentState!;
    final routeIndex = _loaders.indexWhere((element) =>
    element.id == request.id);
    navigatorState.removeRoute(_loaders.removeAt(routeIndex));
  }
}