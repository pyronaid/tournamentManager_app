import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';
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

  dynamic result();
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
  final bool readOnly;

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
    this.readOnly = false,
  });

  @override
  State<TextFormElement> createState() => _TextFormElementState();

  @override
  dynamic result() {
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
          readOnly: widget.readOnly,
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
  dynamic result() {
    final currentState = (key as GlobalKey<SliderFormElementState>).currentState;
    return currentState?.currentValue ?? sliderValue;
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
  final List<T>? selectedItems;
  final String Function(T) nameExtractor;

  const DropdownFormElement({
    required GlobalKey<DropdownFormElementState> key,
    required super.label,
    required this.value,
    required this.items,
    this.selectedItems,
    required this.nameExtractor,
  }) : super(key: key);

  @override
  State<DropdownFormElement<T>> createState() => DropdownFormElementState<T>();

  @override
  dynamic result() {
    final currentState = (key as GlobalKey<DropdownFormElementState>).currentState;
    return currentState?._selectedItems.whereType<T>().toList() ?? [];
  }
}

class DropdownFormElementState<T> extends State<DropdownFormElement<T>> {
  List<T?> _selectedItems = [];
  List<T> _allItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedItems ?? widget.items);
    _allItems = List.from(widget.items);
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
        MultiSelectChipField(
          showHeader: false,
          initialValue: _selectedItems,
          items: _allItems.map((e) => MultiSelectItem<T>(e, widget.nameExtractor(e))).toList(),
          icon: const Icon(
            Icons.check,
            color: Colors.white,
          ),
          headerColor: Colors.blue,
          onTap: (values) {
            _selectedItems = values;
          },
          selectedChipColor: CustomFlowTheme.of(context).primary,
          selectedTextStyle: const TextStyle(color: Colors.white),
          textStyle: const TextStyle(color: Colors.black54,),
          scroll: false,
          decoration:  const BoxDecoration(),
          chipShape: RoundedRectangleBorder(
            side: const BorderSide(
              color: Colors.transparent,
              width: 0,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}

class CalendarPickerFormElement<T> extends FormInformation {
  final DateTime from;
  final DateTime to;

  const CalendarPickerFormElement({
    required GlobalKey<CalendarPickerFormElementState> key,
    required super.label,
    required this.from,
    required this.to,
  }) : super(key: key);

  @override
  State<CalendarPickerFormElement> createState() => CalendarPickerFormElementState();

  @override
  dynamic result() {
    final currentState = (key as GlobalKey<CalendarPickerFormElementState>).currentState;
    return [currentState?._rangeStart, currentState?._rangeEnd ?? currentState?._rangeStart];
  }
}

class CalendarPickerFormElementState extends State<CalendarPickerFormElement> {
  late DateTime? _rangeStart;
  late DateTime? _rangeEnd;
  late DateTime _focusedDay;
  late DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _rangeStart = widget.from;
    _rangeEnd = widget.to;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focused){
    setState(() {
      _selectedDay = null;
      _focusedDay = focused;
      _rangeStart = start;
      _rangeEnd = end;
    });
  }

  void _onDaySelected(DateTime? selected, DateTime focused){
    if(!isSameDay(selected, _selectedDay)){
      setState(() {
        _selectedDay = selected;
        _selectedDay = focused;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 4),
          child: Text(
            widget.label,
            style: CustomFlowTheme.of(context).bodyMedium,
          ),
        ),
        SizedBox(
          width: 100 .w,
          height: 450,
          child: TableCalendar(
            availableGestures: AvailableGestures.horizontalSwipe,
            locale: 'it_IT',
            firstDay: DateTime.now(),
            lastDay: DateTime(2101),
            focusedDay: _focusedDay,
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            onRangeSelected: _onRangeSelected,
            rangeSelectionMode: RangeSelectionMode.toggledOn,
            calendarFormat: _calendarFormat,
            onDaySelected: _onDaySelected,
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: CustomFlowTheme.of(context).primary,
              ),
              weekendStyle: TextStyle(
                color: CustomFlowTheme.of(context).primary,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(
                color: Colors.white,
              ),
              withinRangeTextStyle : TextStyle(
                color: Colors.black54, // Text color for weekend days
                fontWeight: FontWeight.bold, // Font style for weekend days
              ),
              disabledTextStyle : TextStyle(
                color: Colors.grey
              ),
            ),
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            /*
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            */
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),

          ),
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
  final String? Function(BuildContext, String?, String?, String?)? validatorFunction;

  const TextAheadAddressFormElement({
    required GlobalKey<TextAheadAddressFormElementState> key,
    required this.controller,
    required this.focusNode,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.iconPrefix,
    this.iconSuffix,
    required this.callHintFunc,
    this.validatorFunction,
    required super.label,
  }) : super(key: key);

  @override
  State<TextAheadAddressFormElement> createState() => TextAheadAddressFormElementState();

  @override
  dynamic result() {
    final currentState = (key as GlobalKey<TextAheadAddressFormElementState>).currentState;
    return currentState?.placeId;
  }
}

class TextAheadAddressFormElementState extends State<TextAheadAddressFormElement> {
  String? placeId;
  String? lastSelected;


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
              readOnly: false,
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
              validator: (val) => widget.validatorFunction!(context, val, placeId, lastSelected),
            );
          },
          itemBuilder: (context, place) {
            return ListTile(
              title: Text(place["description"]),
              //subtitle: Text(city.country),
            );
          },
          onSelected: (place) {
            placeId = place["place_id"];
            lastSelected = place["description"];
            setState(() {
              widget.controller.text = place["description"];
            });
          },
        ),
      ],
    );
  }
}



class AlertResponse {
  final bool confirmed;
  final List<dynamic>? formValues;

  AlertResponse({
    required this.confirmed,
    this.formValues,
  });
}