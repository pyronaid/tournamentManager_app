
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/AlertClasses.dart';

class DialogService {
  late Function(AlertRequest) _showDialogListener;
  late Function(AlertFormRequest) _showDialogFormListener;
  late Completer<AlertResponse> _dialogCompleter;

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
    required TextEditingController controller,
    required FocusNode focusNode,
    bool autofocus = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    IconData? iconPrefix,
    IconData? iconSuffix,
    required String? Function(BuildContext, String?, String?)? validatorFunction,
    required String validatorParameter,
  }) {
    _dialogCompleter = Completer<AlertResponse>();
    _showDialogFormListener(AlertFormRequest(
      title: title,
      description: description,
      buttonTitleConfirmed: buttonTitleConfirmed,
      buttonTitleCancelled: buttonTitleCancelled,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      keyboardType: keyboardType,
      iconPrefix: iconPrefix,
      iconSuffix: iconSuffix,
      validatorFunction: validatorFunction,
      validatorParameter: validatorParameter,
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