import 'package:tournamentmanager/app_flow/services/supportClass/loader_classes.dart';

class LoaderService {
  late Function(LoaderRequest) _showLoaderListener;
  late Function(LoaderRequest) _hideLoaderListener;

  LoaderService(){
    print("[SERVICE CONSTRUCTOR] LoaderService");
  }

  /// Registers a callback function. Typically to show the dialog
  void registerLoaderListener(Function(LoaderRequest) showLoaderListener) {
    _showLoaderListener = showLoaderListener;
  }
  void registerLoaderCompleter(Function(LoaderRequest) hideLoaderListener) {
    _hideLoaderListener = hideLoaderListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  void showLoader({
      required Object id,
      bool barrierDismissible = false}) {
    _showLoaderListener(LoaderRequest(
      id: id,
      barrierDismissible: barrierDismissible,
    ));
  }
  void hideLoader({
    required Object id,
    bool barrierDismissible = false
  }){
    _hideLoaderListener(LoaderRequest(
      id: id,
      barrierDismissible: barrierDismissible
    ));
  }

}