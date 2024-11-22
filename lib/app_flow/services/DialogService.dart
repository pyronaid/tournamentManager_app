import 'dart:async';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';

class DialogService {
  late Function(AlertRequest) _showDialogListener;
  late Function(AlertFormRequest) _showDialogFormListener;
  late Completer<AlertResponse> _dialogCompleter;

  DialogService(){
    print("[SERVICE CONSTRUCTOR] DialogService");
  }

  /// Registers a callback function. Typically to show the dialog
  void registerDialogListener(Function(AlertRequest) showDialogListener) {
    _showDialogListener = showDialogListener;
  }
  void registerDialogFormListener(Function(AlertFormRequest) showDialogFormListener) {
    _showDialogFormListener = showDialogFormListener;
  }

  /// Calls the dialog listener and returns a Future that will wait for dialogComplete.
  Future<AlertResponse> showDialog({
    required String title,
    required String description,
    String buttonTitleConfirmed = 'Ok',
    String buttonTitleCancelled = 'Annulla',
  }) {
    _dialogCompleter = Completer<AlertResponse>();
    _showDialogListener(AlertRequest(
      title: title,
      description: description,
      buttonTitleConfirmed: buttonTitleConfirmed,
      buttonTitleCancelled: buttonTitleCancelled,
    ));
    return _dialogCompleter.future;
  }
  Future<AlertResponse> showDialogForm({
    required String title,
    required String description,
    String buttonTitleConfirmed = 'Ok',
    String buttonTitleCancelled = 'Annulla',
    required List<FormInformation> formInfo,
  }) {
    _dialogCompleter = Completer<AlertResponse>();
    _showDialogFormListener(AlertFormRequest(
      title: title,
      description: description,
      buttonTitleConfirmed: buttonTitleConfirmed,
      buttonTitleCancelled: buttonTitleCancelled,
      formInfo: formInfo,
    ));
    return _dialogCompleter.future;
  }

  /// Completes the _dialogCompleter to resume the Future's execution call
  void dialogComplete(AlertResponse response) {
    _dialogCompleter.complete(response);
  }
  bool dialogIsCompleted(){
    return _dialogCompleter.isCompleted;
  }
}