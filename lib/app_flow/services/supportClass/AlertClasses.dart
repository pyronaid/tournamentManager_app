import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AlertRequest {
  final String title;
  final String description;
  final String buttonTitleConfirmed;
  final String buttonTitleCancelled;

  AlertRequest({
    required this.title,
    required this.description,
    required this.buttonTitleConfirmed,
    required this.buttonTitleCancelled,
  });
}

class AlertFormRequest<T> extends AlertRequest{
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? iconPrefix;
  final IconData? iconSuffix;
  final String? Function(BuildContext, String?, String?)? validatorFunction;
  final T validatorParameter;

  AlertFormRequest({
    required this.controller,
    required this.focusNode,
    required this.autofocus,
    required this.keyboardType,
    this.inputFormatters,
    this.iconPrefix,
    this.iconSuffix,
    required this.validatorFunction,
    required this.validatorParameter,
    required super.title,
    required super.description,
    required super.buttonTitleConfirmed,
    required super.buttonTitleCancelled
  });
}

class AlertResponse {
  final bool confirmed;
  final String? formValue;

  AlertResponse({
    required this.confirmed,
    this.formValue,
  });
}