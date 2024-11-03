import 'package:flutter/material.dart';

final class LoaderRoute extends DialogRoute<dynamic> {
  LoaderRoute({
    required super.context,
    required super.builder,
    this.id,
    super.barrierDismissible,
  });

  final Object? id;
}