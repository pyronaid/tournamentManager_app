
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/AlertClasses.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/SnackBarClasses.dart';

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
    bool isDismissibleFlag = false,
    bool showProgressIndicatorFlag = false,
    Duration duration = const Duration(milliseconds: 2500),
    required Sentiment sentiment,
  }) {
    _showSnackBarListener(SnackBarRequest(
      title: title,
      message: message,
      duration: duration,
      isDismissibleFlag: isDismissibleFlag,
      showProgressIndicatorFlag : showProgressIndicatorFlag,
      sentiment: sentiment,
    ));
  }

  /// Completes the _dialogCompleter to resume the Future's execution call

}