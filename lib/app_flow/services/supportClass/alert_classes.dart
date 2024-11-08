import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';

import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../app_flow_theme.dart';

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

abstract class FormInformation extends StatefulWidget {
  final String label;

  const FormInformation({
    super.key,
    required this.label,
  });

  String result();
}

class TextFormElement extends FormInformation {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? iconPrefix;
  final IconData? iconSuffix;
  final Future<void> Function(BuildContext)? iconSuffixOnTapFunction;
  final String? Function(BuildContext, String?, String?)? validatorFunction;
  final String? validatorParameter;

  const TextFormElement({
    super.key,
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.iconPrefix,
    this.iconSuffix,
    this.iconSuffixOnTapFunction,
    this.validatorFunction,
    required this.validatorParameter,
    required super.label,
  });

  @override
  State<TextFormElement> createState() => _TextFormElementState();

  @override
  String result() {
    return controller.text;
  }
}

class _TextFormElementState extends State<TextFormElement> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 4),
          child: Text(
            widget.label,
            style: CustomFlowTheme.of(context).bodyMedium,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          obscureText: false,
          decoration: standardInputDecoration(
            context,
            prefixIcon: widget.iconPrefix != null ?
            Icon(
              widget.iconPrefix,
              color: CustomFlowTheme.of(context).secondaryText,
              size: 18,
            ) : null,
            suffixIcon: widget.iconSuffix != null ? widget.iconSuffixOnTapFunction != null ?
            IconButton(
              icon: Icon(
                widget.iconSuffix,
                color: CustomFlowTheme.of(context).secondaryText,
                size: 18,
              ),
              onPressed: () async {
                widget.iconSuffixOnTapFunction!(context);
              },
            ) :
            Icon(
              widget.iconSuffix,
              color: CustomFlowTheme.of(context).secondaryText,
              size: 18,
            ) : null,
          ),
          style: CustomFlowTheme.of(context).bodyLarge.override(
            fontWeight: FontWeight.w500,
            lineHeight: 1,
          ),
          minLines: 1,
          cursorColor: CustomFlowTheme.of(context).primary,
          validator: widget.validatorFunction?.asValidator(context, widget.validatorParameter),
        ),
      ],
    );
  }
}

class SliderFormElement extends FormInformation {
  final double sliderValue;
  final double min;
  final double max;
  final int? divisions;
  final String? Function(double)? valueLabel;

  const SliderFormElement({
    required GlobalKey<SliderFormElementState> key,
    required super.label,
    required this.sliderValue,
    required this.min,
    required this.max,
    this.divisions,
    this.valueLabel,
  }) : super(key: key);

  @override
  State<SliderFormElement> createState() => SliderFormElementState();

  @override
  String result() {
    final currentState = (key as GlobalKey<SliderFormElementState>).currentState;
    return currentState?.currentValue.toString() ?? sliderValue.toString();
  }
}

class SliderFormElementState extends State<SliderFormElement> {
  late double currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.sliderValue; // Initialize once with widget's initial value
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 4),
          child: Text(
            widget.label,
            style: CustomFlowTheme.of(context).bodyMedium,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.min.toStringAsFixed(0),
              style: CustomFlowTheme.of(context).labelMedium,
            ),
            Expanded(
              child: Slider(
                value: currentValue ?? 0,
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: (newValue) {
                  setState(() {
                    currentValue = newValue;
                  });
                },
                label: widget.valueLabel?.call(currentValue ?? 0) ?? currentValue.toString(),
              ),
            ),
            Text(
              widget.max.toStringAsFixed(0),
              style: CustomFlowTheme.of(context).labelMedium,
            ),
          ]
        ),
      ],
    );
  }
}

class DropdownFormElement<T> extends FormInformation {
  final T? value;
  final List<T> items;
  final String Function(T) nameExtractor;

  const DropdownFormElement({
    super.key,
    required super.label,
    required this.value,
    required this.items,
    required this.nameExtractor,
  });

  @override
  State<DropdownFormElement<T>> createState() => _DropdownFormElementState<T>();

  @override
  String result() {
    return "";
  }
}

class _DropdownFormElementState<T> extends State<DropdownFormElement<T>> {
  List<T> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 4),
          child: Text(
            widget.label,
            style: CustomFlowTheme.of(context).bodyMedium,
          ),
        ),
        DropdownButtonFormField(
          value: widget.value,
          menuMaxHeight: 30.h,
          items: widget.items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              key: ValueKey(item),
              child: SizedBox(
                width: 50.w,
                child: CheckboxListTile(
                  title: Text(
                    widget.nameExtractor(item),
                    style: CustomFlowTheme.of(context).bodyLarge.override(
                      fontWeight: FontWeight.w500,
                      lineHeight: 1,
                    ),
                  ),
                  value: _selectedItems.contains(item),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value ?? false) {
                        _selectedItems.add(item);
                      } else {
                        _selectedItems.remove(item);
                      }
                    });
                  },
                ),
              ),
            );
          }).toList(),
          hint: const Text("Scegli"),
          decoration: standardInputDecoration(context),
          style: CustomFlowTheme.of(context).bodyLarge.override(
            fontWeight: FontWeight.w500,
            lineHeight: 1,
          ),
          onChanged: (T? value) {
            // Do nothing, as we handle selection in the CheckboxListTile
            print("hello");
          },
        ),
      ],
    );
  }
}

class TextAheadAddressFormElement extends FormInformation {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autofocus;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? iconPrefix;
  final IconData? iconSuffix;
  final Future<List> Function() callHintFunc;
  final String? Function(BuildContext, String?, String?)? validatorFunction;
  final String validatorParameter;

  const TextAheadAddressFormElement({
    super.key,
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.iconPrefix,
    this.iconSuffix,
    required this.callHintFunc,
    this.validatorFunction,
    required this.validatorParameter,
    required super.label,
  });

  @override
  State<TextAheadAddressFormElement> createState() => _TextAheadAddressFormElementState();

  @override
  String result() {
    return controller.text;
  }
}

class _TextAheadAddressFormElementState extends State<TextAheadAddressFormElement> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypeAheadField<dynamic>(
          controller: widget.controller,
          focusNode: widget.focusNode,
          suggestionsCallback: (String search) {
            return widget.callHintFunc();
          },
          builder: (context, controller, focusNode) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textInputAction: TextInputAction.next,
              obscureText: false,
              decoration: standardInputDecoration(
                context,
                prefixIcon: widget.iconPrefix != null ?
                Icon(
                  widget.iconPrefix,
                  color: CustomFlowTheme.of(context).secondaryText,
                  size: 18,
                ) : null,
              ),
              style: CustomFlowTheme.of(context).bodyLarge.override(
                fontWeight: FontWeight.w500,
                lineHeight: 1,
              ),
              minLines: 1,
              cursorColor: CustomFlowTheme.of(context).primary,
              validator: widget.validatorFunction?.asValidator(context, widget.validatorParameter),
            );
          },
          itemBuilder: (context, place) {
            return ListTile(
              title: Text(place["description"]),
              //subtitle: Text(city.country),
            );
          },
          onSelected: (place) {
            //tbd
          },
        ),
      ],
    );
  }
}



class AlertResponse {
  final bool confirmed;
  final List<String?>? formValues;

  AlertResponse({
    required this.confirmed,
    this.formValues,
  });
}