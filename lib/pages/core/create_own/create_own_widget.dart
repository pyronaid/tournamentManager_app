import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_animations.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/core/create_own/create_own_model.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double fieldSpacing     = 18.0;
  static const double buttonHeight     = 50.0;
  static const double buttonRadius     = 25.0;
  static const double prefixIconSize   = 18.0;
  static const double carouselHeight   = 24.0; // used as 24.h (responsive)
  static const double carouselImgHeight = 20.0; // used as 20.h (responsive)
  static const double dropdownMenuMax  = 50.0; // used as 50.h (responsive)
  static const double borderWidth      = 1.0;
}

// ---------------------------------------------------------------------------
// VALUE OBJECTS
// Used by Selectors to compare composite state.
// FIX: replaces Tuple2<List<dynamic>, bool> with a named, type-safe class.
// ---------------------------------------------------------------------------
@immutable
class _AddressState {
  const _AddressState({
    required this.placeList,
    required this.isOnline,
  });

  final List<dynamic> placeList;
  final bool isOnline;

  @override
  bool operator ==(Object other) =>
      other is _AddressState &&
          other.isOnline == isOnline &&
          // List equality — rebuilds when the suggestions list changes.
          other.placeList.length == placeList.length;

  @override
  int get hashCode => Object.hash(isOnline, placeList.length);
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
// Kept as StatefulWidget because:
//   - GlobalKey<FormState> must survive rebuilds
//   - _handleSave references mounted and context
//   - _model.initContextVars must run exactly once in initState
// ---------------------------------------------------------------------------
class CreateOwnWidget extends StatefulWidget {
  const CreateOwnWidget({super.key});

  @override
  State<CreateOwnWidget> createState() => _CreateOwnWidgetState();
}

class _CreateOwnWidgetState extends State<CreateOwnWidget> {
  final _formKey = GlobalKey<FormState>();

  late final CreateOwnModel _model;

  @override
  void initState() {
    super.initState();
    _model = context.read<CreateOwnModel>();
    // initContextVars wires up anything the model needs from BuildContext.
    // Safe here — context is valid in initState for widgets inserted via
    // the standard route/provider stack.
    _model.initContextVars(context);
  }

  // ── Save handler ───────────────────────────────────────────────────────────
  // Extracted from onPressed so it can be read, tested, and reasoned about
  // independently from the button widget that triggers it.
  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    logFirebaseEvent('ONBOARDING_CREATE_OWN_CREATE_OWN');
    logFirebaseEvent('Button_validate_form');

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    logFirebaseEvent('Button_haptic_feedback');
    HapticFeedback.lightImpact();

    final result = await _model.saveTournament();

    // Guard: widget might have been disposed during the async save.
    if (!mounted) return;

    if (result) {
      context.goNamedAuth('Dashboard', context.mounted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: _CreateOwnForm(
              model: _model,
              formKey: _formKey,
              onSave: _handleSave,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM BODY
// Purely presentational. Receives everything via constructor.
// No Provider.of / context.read calls inside — all data flows in from above.
// ---------------------------------------------------------------------------
class _CreateOwnForm extends StatelessWidget {
  const _CreateOwnForm({
    required this.model,
    required this.formKey,
    required this.onSave,
  });

  final CreateOwnModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        _FormHeader(model: model),

        // ── Game carousel ─────────────────────────────────────────────────
        _GameCarousel(model: model),

        // ── Form fields ───────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _GameDropdown(model: model),
                _NameField(model: model),
                _DateField(model: model),
                _OnlineSwitch(model: model),
                _AddressField(model: model),
                _CapacityField(model: model),
                _PreRegistrationSwitch(model: model),
                _WaitingListSwitch(model: model),
              ],
            ),
          ),
        ),

        // ── Submit button ─────────────────────────────────────────────────
        _SubmitButton(onSave: onSave),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: HEADER
// FIX: wrapWithModel removed — CustomAppbarWidget is built directly.
// wrapWithModel was accumulating stale callbacks on each rebuild.
// ---------------------------------------------------------------------------
class _FormHeader extends StatelessWidget {
  const _FormHeader({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CustomFlowTheme.of(context).secondary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppbarWidget(
            backButton: true,
            actionButton: false,
            actionButtonAction: () async {},
            optionsButtonAction: () async {},
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            child: Text(
              'Crea un nuovo torneo',
              style: CustomFlowTheme.of(context).displaySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: GAME CAROUSEL
// Static structure — no Selector needed. The PageView drives its own
// internal state; the model only needs to know the page index for the
// dropdown sync, which is handled by _GameDropdown's Selector.
// ---------------------------------------------------------------------------
class _GameCarousel extends StatelessWidget {
  const _GameCarousel({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    final games = Game.values.where((g) => g.desc.isNotEmpty).toList();

    return SizedBox(
      width: double.infinity,
      height: _Dims.carouselHeight.h,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 20, 24, 0),
        child: PageView(
          controller: model.pageViewController,
          scrollDirection: Axis.horizontal,
          onPageChanged: model.jumpToPageAndNotify,
          children: games.map((game) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  child: Image.asset(
                    game.resource,
                    height: _Dims.carouselImgHeight.h,
                    fit: BoxFit.cover,
                  ).animateOnPageLoad(model.animationsMap[game.index]!),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: GAME DROPDOWN
// FIX: Selector reads from model directly via m.pageViewController.page,
// not from a captured variable. Rebuilds only when the page changes.
// ---------------------------------------------------------------------------
class _GameDropdown extends StatelessWidget {
  const _GameDropdown({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    final games =
    Game.values.where((g) => g.desc.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
      child: Selector<CreateOwnModel, double?>(
        selector: (_, m) => m.pageViewController.page,
        builder: (_, page, __) {
          return DropdownButton<int>(
            itemHeight: null,
            menuMaxHeight: _Dims.dropdownMenuMax.h,
            value: page != null ? page.round() : 0,
            items: games.map((game) {
              return DropdownMenuItem(
                value: game.index,
                child: Text(
                  game.desc,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
            style: CustomFlowTheme.of(context).bodyMedium.override(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              lineHeight: 1,
            ),
            onChanged: (value) {
              if (value != null) model.jumpToPageAndNotify(value);
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: NAME FIELD
// No Selector needed — TextFormField manages its own display via the
// controller. notifyListeners on the model is not needed for text fields.
// ---------------------------------------------------------------------------
class _NameField extends StatelessWidget {
  const _NameField({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: 'Nome torneo',
      child: TextFormField(
        controller: model.tournamentNameTextController,
        focusNode: model.tournamentNameFocusNode,
        autofocus: false,
        autofillHints: const [AutofillHints.name],
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        obscureText: false,
        decoration: standardInputDecoration(
          context,
          prefixIcon: Icon(
            Icons.style,
            color: CustomFlowTheme.of(context).secondaryText,
            size: _Dims.prefixIconSize,
          ),
        ),
        style: CustomFlowTheme.of(context).bodyLarge.override(
          fontWeight: FontWeight.w500,
          lineHeight: 1,
        ),
        minLines: 1,
        cursorColor: CustomFlowTheme.of(context).primary,
        validator: model.tournamentNameTextControllerValidator
            .asValidator(context),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: DATE FIELD
// FIX: Selector on TextEditingController.text removed.
// TextEditingController notifies its own listeners — not the model's
// notifyListeners — so that Selector never triggered a rebuild anyway.
// The field is readOnly and updated via the date picker which writes
// directly to the controller, causing the TextFormField to rebuild itself.
// ---------------------------------------------------------------------------
class _DateField extends StatelessWidget {
  const _DateField({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: 'Data torneo',
      child: TextFormField(
        controller: model.tournamentDateTextController,
        focusNode: model.tournamentDateFocusNode,
        autofocus: false,
        readOnly: true,
        obscureText: false,
        decoration: standardInputDecoration(
          context,
          suffixIcons: [
            IconButton(
              icon: const Icon(Icons.calendar_month),
              onPressed: () => _showDatePicker(context),
            ),
          ],
        ),
        style: CustomFlowTheme.of(context).bodyLarge.override(
          fontWeight: FontWeight.w500,
          lineHeight: 1,
        ),
        minLines: 1,
        cursorColor: CustomFlowTheme.of(context).primary,
        validator:
        model.tournamentDateTextControllerValidator.asValidator(context),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      locale: const Locale('it'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) model.setTournamentDate(picked);
  }
}

// ---------------------------------------------------------------------------
// SECTION: ONLINE SWITCH
// Selector on isOnlineEnabledVar — rebuilds only when the flag changes.
// ---------------------------------------------------------------------------
class _OnlineSwitch extends StatelessWidget {
  const _OnlineSwitch({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _SwitchRow(
      label: 'Torneo Online',
      selector: Selector<CreateOwnModel, bool>(
        selector: (_, m) => m.isOnlineEnabledVar,
        builder: (_, value, __) => Switch(
          value: value,
          onChanged: (_) => model.switchIsOnlineEn(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: ADDRESS FIELD
// FIX: Tuple2 replaced with _AddressState value object.
// Rebuilds when isOnline changes (enables/disables the field) or when
// the suggestions list changes (updates TypeAhead options).
// ---------------------------------------------------------------------------
class _AddressField extends StatelessWidget {
  const _AddressField({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: 'Indirizzo torneo',
      child: Selector<CreateOwnModel, _AddressState>(
        selector: (_, m) => _AddressState(
          placeList: m.placeList,
          isOnline: m.isOnlineEnabledVar,
        ),
        builder: (_, addressState, __) {
          return TypeAheadField<dynamic>(
            controller: model.tournamentAddressTextController,
            focusNode: model.tournamentAddressFocusNode,
            suggestionsCallback: (_) => model.callAddressHint(),
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                // Field is disabled when tournament is online.
                enabled: !addressState.isOnline,
                textInputAction: TextInputAction.next,
                obscureText: false,
                autofocus: false,
                textCapitalization: TextCapitalization.none,
                decoration: standardInputDecoration(
                  context,
                  prefixIcon: Icon(
                    Icons.place,
                    color: CustomFlowTheme.of(context).secondaryText,
                    size: _Dims.prefixIconSize,
                  ),
                ),
                style: CustomFlowTheme.of(context).bodyLarge.override(
                  fontWeight: FontWeight.w500,
                  lineHeight: 1,
                ),
                minLines: 1,
                cursorColor: CustomFlowTheme.of(context).primary,
                validator: model.tournamentAddressTextControllerValidator
                    .asValidator(context),
              );
            },
            itemBuilder: (context, place) {
              return ListTile(
                title: Text(place['description'] as String),
              );
            },
            onSelected: model.setTournamentAddress,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: CAPACITY FIELD
// FIX: Selector on TextEditingController.text removed — same reason as
// _DateField. The controller manages its own display.
// ---------------------------------------------------------------------------
class _CapacityField extends StatelessWidget {
  const _CapacityField({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _LabelledField(
      label: 'Capienza torneo',
      child: TextFormField(
        controller: model.tournamentCapacityTextController,
        focusNode: model.tournamentCapacityFocusNode,
        autofocus: false,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textCapitalization: TextCapitalization.none,
        textInputAction: TextInputAction.next,
        obscureText: false,
        decoration: standardInputDecoration(
          context,
          prefixIcon: Icon(
            Icons.reduce_capacity,
            color: CustomFlowTheme.of(context).secondaryText,
            size: _Dims.prefixIconSize,
          ),
        ),
        onChanged: (value) {
          if (value.isEmpty) model.setTournamentCapacity();
        },
        style: CustomFlowTheme.of(context).bodyLarge.override(
          fontWeight: FontWeight.w500,
          lineHeight: 1,
        ),
        minLines: 1,
        cursorColor: CustomFlowTheme.of(context).primary,
        validator: model.tournamentCapacityTextControllerValidator
            .asValidator(context),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: PRE-REGISTRATION SWITCH
// ---------------------------------------------------------------------------
class _PreRegistrationSwitch extends StatelessWidget {
  const _PreRegistrationSwitch({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _SwitchRow(
      label: 'Pre-registrazione abilitata',
      selector: Selector<CreateOwnModel, bool>(
        selector: (_, m) => m.preRegistrationEnabledVar,
        builder: (_, value, __) => Switch(
          value: value,
          onChanged: (_) => model.switchPreRegistrationEn(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: WAITING LIST SWITCH
// ---------------------------------------------------------------------------
class _WaitingListSwitch extends StatelessWidget {
  const _WaitingListSwitch({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    return _SwitchRow(
      label: "Lista d'attesa abilitata",
      selector: Selector<CreateOwnModel, bool>(
        selector: (_, m) => m.waitingListEnabledVar,
        builder: (_, value, __) => Switch(
          value: value,
          onChanged: (_) => model.switchWaitingListEn(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: SUBMIT BUTTON
// ---------------------------------------------------------------------------
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
      child: AFButtonWidget(
        onPressed: onSave,
        text: 'Crea Torneo',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          color: CustomFlowTheme.of(context).primary,
          textStyle: CustomFlowTheme.of(context).titleSmall,
          elevation: 0,
          borderSide: const BorderSide(
            color: Colors.transparent,
            width: _Dims.borderWidth,
          ),
          borderRadius: BorderRadius.circular(_Dims.buttonRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED HELPER WIDGETS
// ---------------------------------------------------------------------------

/// Labelled wrapper for form fields — replaces the repeated
/// Column > Padding > Text > field pattern across all form sections.
class _LabelledField extends StatelessWidget {
  const _LabelledField({
    required this.label,
    required this.child,
    // ignore: unused_element_parameter
    this.topPadding = _Dims.fieldSpacing,
  });

  final String label;
  final Widget child;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, topPadding, 0, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
            child: Text(label, style: CustomFlowTheme.of(context).bodyMedium),
          ),
          child,
        ],
      ),
    );
  }
}

/// Label + trailing selector row — replaces the repeated
/// Row > Text > Selector > Switch pattern for all toggle fields.
class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.selector,
  });

  final String label;
  final Widget selector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, _Dims.fieldSpacing, 0, 0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(label, style: CustomFlowTheme.of(context).bodyMedium),
          selector,
        ],
      ),
    );
  }
}
