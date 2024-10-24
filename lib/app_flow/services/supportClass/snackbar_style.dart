import 'package:flutter/material.dart';

enum SnackbarStyle { error, success, normal, warning, networkIssue }

extension SnackbarStyleExtension on SnackbarStyle {
  Color get displayTitleColor {
    switch (this) {
      case SnackbarStyle.error:
        return Colors.white;
      case SnackbarStyle.success:
        return Colors.white;
      case SnackbarStyle.normal:
        return Colors.white;
      case SnackbarStyle.warning:
        return Colors.white;
      case SnackbarStyle.networkIssue:
        return Colors.white;
    }
  }

  Color get displayMessageColor {
    switch (this) {
      case SnackbarStyle.error:
        return Colors.white;
      case SnackbarStyle.success:
        return Colors.white;
      case SnackbarStyle.normal:
        return Colors.white;
      case SnackbarStyle.warning:
        return Colors.white;
      case SnackbarStyle.networkIssue:
        return Colors.white;
    }
  }

  IconData? get icon {
    switch (this) {
      case SnackbarStyle.error:
        return Icons.cancel;
      case SnackbarStyle.success:
        return Icons.check_circle;
      case SnackbarStyle.normal:
        return null;
      case SnackbarStyle.warning:
        return Icons.warning;
      case SnackbarStyle.networkIssue:
        return Icons.signal_cellular_connected_no_internet_4_bar;
    }
  }

  Color get displayColor {
    switch (this) {
      case SnackbarStyle.error:
        return Colors.red;
      case SnackbarStyle.success:
        return Colors.green;
      case SnackbarStyle.normal:
        return Colors.black;
      case SnackbarStyle.warning:
        return Colors.orangeAccent;
      case SnackbarStyle.networkIssue:
        return Colors.red;
    }
  }

  bool get isCloseButtonVisible {
    switch (this) {
      case SnackbarStyle.error:
        return true;
      case SnackbarStyle.success:
        return true;
      case SnackbarStyle.normal:
        return true;
      case SnackbarStyle.warning:
        return true;
      case SnackbarStyle.networkIssue:
        return true;
    }
  }
}