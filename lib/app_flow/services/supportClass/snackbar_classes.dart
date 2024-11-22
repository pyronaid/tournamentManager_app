import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_position.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/snackbar_style.dart';

class SnackBarRequest{
  final String title;
  final String message;
  final Duration duration;
  final SnackbarStyle style;
  final SnackbarPosition position;

  SnackBarRequest({
    required this.title,
    required this.message,
    required this.duration,
    required this.style,
    required this.position,
  });
}