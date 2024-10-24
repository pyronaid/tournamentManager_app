import 'package:tournamentmanager/app_flow/services/supportClass/SnackBarClasses.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_position.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';

class SnackBarService {
  late Function(SnackBarRequest) _showSnackBarListener;

  /// Registers a callback function. Typically to show the dialog
  void registerSnackBarListener(Function(SnackBarRequest) showSnackBarListener) {
    _showSnackBarListener = showSnackBarListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  void showSnackBar({
    required String title,
    required String message,
    Duration duration = const Duration(milliseconds: 2500),
    SnackbarStyle style = SnackbarStyle.normal,
    SnackbarPosition position = SnackbarPosition.top,
  }) {
    _showSnackBarListener(SnackBarRequest(
      title: title,
      message: message,
      duration: duration,
      style: style,
      position: position,
    ));
  }

  /// Completes the _dialogCompleter to resume the Future's execution call

}