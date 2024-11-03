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

class AlertFormRequest extends AlertRequest{
  final List<FormInformation> formInfo;

  AlertFormRequest({
    required this.formInfo,
    required super.title,
    required super.description,
    required super.buttonTitleConfirmed,
    required super.buttonTitleCancelled
  });
}

class FormInformation {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? iconPrefix;
  final IconData? iconSuffix;
  final String? Function(BuildContext, String?, String?)? validatorFunction;
  final String validatorParameter;
  final String label;

  FormInformation({
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.iconPrefix,
    this.iconSuffix,
    this.validatorFunction,
    required this.validatorParameter,
    required this.label,
  });
}

class AlertResponse {
  final bool confirmed;
  final List<String?>? formValues;

  AlertResponse({
    required this.confirmed,
    this.formValues,
  });
}