import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
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
//
// FIX: carouselHeight, carouselImgHeight, dropdownMenuMax were expressed as
//   percentages via responsive_sizer (.h suffix).  All three are now handled
//   by layout widgets instead:
//     - Carousel height  → AspectRatio (scales with screen width)
//     - Image height     → Expanded inside the AspectRatio column (fills
//                          the available height after the carousel is sized)
//     - Dropdown max     → LayoutBuilder resolves actual screen height once
//                          and passes it down as a concrete pixel value
//
//   The remaining constants are all fixed physical values (spacing, tap
//   targets, border widths) that are correct to keep fixed.
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double fieldSpacing    = 18.0;
  static const double buttonHeight    = 50.0;
  static const double buttonRadius    = 25.0;
  static const double prefixIconSize  = 18.0;
  static const double borderWidth     = 1.0;

  // ── Carousel ──────────────────────────────────────────────────────────────
  /// Aspect ratio of the game image carousel banner.
  /// 16/6 ≈ a wide cinematic strip that is not too tall on small phones and
  /// not too short on tablets — scales automatically with screen width via
  /// AspectRatio, no external package needed.
  static const double carouselAspectRatio = 16 / 6;

  /// Horizontal + vertical padding inside the carousel.
  static const double carouselPaddingH = 24.0;
  static const double carouselPaddingT = 20.0;

  // ── Dropdown ──────────────────────────────────────────────────────────────
  /// The game dropdown menu height is capped at this fraction of the screen
  /// height.  Resolved to pixels by LayoutBuilder at build time — no
  /// responsive_sizer needed.
  static const double dropdownMaxHeightFraction = 0.50;
}

// ---------------------------------------------------------------------------
// VALUE OBJECTS
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
          other.placeList.length == placeList.length;

  @override
  int get hashCode => Object.hash(isOnline, placeList.length);
}

// ---------------------------------------------------------------------------
// ROOT WIDGET
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
    _model.initContextVars(context);
  }

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
          // LayoutBuilder is used here — not deeper — so that the resolved
          // screen height is available to both the carousel and the dropdown
          // without threading it through multiple constructor parameters.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: _CreateOwnForm(
                model: _model,
                formKey: _formKey,
                onSave: _handleSave,
                // Resolved once here; both carousel and dropdown consume it.
                availableHeight: constraints.maxHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FORM BODY
// ---------------------------------------------------------------------------
class _CreateOwnForm extends StatelessWidget {
  const _CreateOwnForm({
    required this.model,
    required this.formKey,
    required this.onSave,
    required this.availableHeight,
  });

  final CreateOwnModel model;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  /// Resolved screen height passed from the LayoutBuilder above.
  /// Used to cap the dropdown menu and size the carousel proportionally.
  final double availableHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────
        _FormHeader(model: model),

        // ── Game carousel ────────────────────────────────────────────────
        _GameCarousel(model: model),

        // ── Form fields ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                _GameDropdown(
                  model: model,
                  // Dropdown menu height capped at a fraction of screen height.
                  menuMaxHeight: availableHeight *
                      _Dims.dropdownMaxHeightFraction,
                ),
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

        // ── Submit button ────────────────────────────────────────────────
        _SubmitButton(onSave: onSave),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: HEADER
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
//
// FIX: the original used:
//   SizedBox(height: _Dims.carouselHeight.h)   → 24% of screen height
//   Image(height: _Dims.carouselImgHeight.h)   → 20% of screen height
//
// Both are replaced with AspectRatio(aspectRatio: carouselAspectRatio).
//
// Why AspectRatio is better here:
//   - It derives height from the available width, which is the correct
//     dimension to scale a banner-style component against.
//   - On a phone in portrait the banner is comfortably sized; in landscape
//     or on a tablet it scales proportionally rather than jumping to 24% of
//     a much larger screen height.
//   - The Image uses BoxFit.contain inside an Expanded, so it always fills
//     the available carousel height without needing its own explicit size.
// ---------------------------------------------------------------------------
class _GameCarousel extends StatelessWidget {
  const _GameCarousel({required this.model});

  final CreateOwnModel model;

  @override
  Widget build(BuildContext context) {
    final games = Game.values.where((g) => g.desc.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        _Dims.carouselPaddingH,
        _Dims.carouselPaddingT,
        _Dims.carouselPaddingH,
        0,
      ),
      child: AspectRatio(
        // Height is derived from width — scales correctly on every device
        // and orientation without any external package.
        aspectRatio: _Dims.carouselAspectRatio,
        child: PageView(
          controller: model.pageViewController,
          scrollDirection: Axis.horizontal,
          onPageChanged: model.jumpToPageAndNotify,
          children: games.map((game) {
            return Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
              child: Image.asset(
                game.resource,
                // Expanded is not available inside PageView children directly,
                // so we use fit: BoxFit.contain and let the AspectRatio parent
                // constrain the available space.  The image fills the carousel
                // height without needing an explicit pixel value.
                fit: BoxFit.contain,
              ).animateOnPageLoad(model.animationsMap[game.index]!),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION: GAME DROPDOWN
//
// FIX: menuMaxHeight was `_Dims.dropdownMenuMax.h` (50% of screen height via
//   responsive_sizer).  It now receives the resolved pixel value from the
//   parent LayoutBuilder via the `menuMaxHeight` parameter — same result,
//   no external package, and the computation happens once at the LayoutBuilder
//   level rather than on every dropdown rebuild.
// ---------------------------------------------------------------------------
class _GameDropdown extends StatelessWidget {
  const _GameDropdown({
    required this.model,
    required this.menuMaxHeight,
  });

  final CreateOwnModel model;

  /// Concrete pixel height for the dropdown overlay menu.
  /// Resolved by the parent LayoutBuilder as:
  ///   constraints.maxHeight * _Dims.dropdownMaxHeightFraction
  final double menuMaxHeight;

  @override
  Widget build(BuildContext context) {
    final games = Game.values.where((g) => g.desc.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
      child: Selector<CreateOwnModel, double?>(
        selector: (_, m) => m.pageViewController.page,
        builder: (_, page, __) {
          return DropdownButton<int>(
            itemHeight: null,
            menuMaxHeight: menuMaxHeight,
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
