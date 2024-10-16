import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SnackBarRequest{
  final String title;
  final String message;
  final Duration duration;
  final bool isDismissibleFlag;
  final bool showProgressIndicatorFlag;
  final Sentiment? sentiment;

  SnackBarRequest({
    required this.title,
    required this.message,
    required this.duration,
    required this.isDismissibleFlag,
    required this.showProgressIndicatorFlag,
    this.sentiment,
  });
}


enum Sentiment {
  completed(Icons.check_circle, Colors.green),
  error(Icons.cancel, Colors.red),
  warning(Icons.warning, Colors.orangeAccent),
  networkIssue(Icons.signal_cellular_connected_no_internet_4_bar, Colors.red );

  final IconData icon;
  final Color color;

  const Sentiment(this.icon, this.color);

}