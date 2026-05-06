import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_winner_card/tournament_winner_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/pocketbase_auth/pocketbase_users_record.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
// Centralise all magic numbers to make future adjustments trivial.
// ---------------------------------------------------------------------------
abstract class _Dims {
  static const double avatarSize        = 130.0;
  static const double avatarRadius      = 61.0;
  static const double editBadgeRadius   = 15.0;
  static const double editIconSize      = 18.0;
  static const double nameBadgeRadius   = 10.0;
  static const double nameBadgeIconSize = 10.0;
  static const double blurSigma         = 10.0;
  static const double borderWidth       = 4.0;
  static const double settingsBorder    = 1.0;
  static const double buttonHeight      = 50.0;
  static const double buttonRadius      = 25.0;
}

@immutable
class _TournamentOutcomeState {
  const _TournamentOutcomeState({
    required this.state,
    required this.hasWinner,
  });

  final StateTournament state;
  final bool hasWinner;

  @override
  bool operator ==(Object other) =>
      other is _TournamentOutcomeState &&
          other.state == state &&
          other.hasWinner == hasWinner;

  @override
  int get hashCode => Object.hash(state, hasWinner);
}

class TournamentDetailWidget extends StatelessWidget  {
  const TournamentDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Selector<TournamentDetailModel, bool>(
        selector: (_, m) => m.isLoading,
        builder: (_, isLoading, __) {
          // FIX [warning]: replaced print() with debugPrint(), gated on
          //   kDebugMode so it is stripped in release builds.
          assert(() {
            debugPrint('[BUILD] tournament_detail_widget.dart');
            return true;
          }());

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final model = context.read<TournamentDetailModel>();

          return Scaffold(
            backgroundColor: CustomFlowTheme.of(context).primaryBackground,
            body: SafeArea(
              top: true,
              child: _TournamentDetailBody(
                model: model,
                enrollCheckFuture: model.enrollCheckFuture,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BODY
// Assembles all sections. Each section is its own private StatelessWidget.
// ---------------------------------------------------------------------------

class _TournamentDetailBody extends StatelessWidget {
  const _TournamentDetailBody({
    required this.model,
    required this.enrollCheckFuture,
  });

  final TournamentDetailModel model;
  final Future<EnrollmentCheckResult> enrollCheckFuture;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Hero / Header ──────────────────────────────────────────────
          _TournamentHeader(model: model),

          // ── 2. Settings row 1 (state / date / capacity) ───────────────────
          _SettingsRowOne(model: model),

          // ── 3. Settings row 2 (pre-reg / waiting list) ────────────────────
          _SettingsRowTwo(model: model),

          // ── 4. Winner area (only when tournament is closed) ───────────────
          Selector<TournamentDetailModel, _TournamentOutcomeState>(selector: (_, m) => _TournamentOutcomeState(
            state: m.tournamentModel.tournamentState,
            hasWinner: m.tournamentModel.hasWinner,
          ),
            builder: (_, outcomeState, ___) {
              if (outcomeState.state == StateTournament.close && outcomeState.hasWinner) {
                return _WinnerArea(winners: t.winner ?? []);
              } else {
                return const SizedBox.shrink();
              }
            },
          ),

          // ── 5. Registration / enrolment area ──────────────────────────────
          Selector<TournamentDetailModel, _TournamentOutcomeState>(selector: (_, m) => _TournamentOutcomeState(
            state: m.tournamentModel.tournamentState,
            hasWinner: m.tournamentModel.hasWinner,
          ),
            builder: (_, outcomeState, ___) {
              if (outcomeState.state == StateTournament.ready && !outcomeState.hasWinner) {
                return _RegistrationArea(
                  model: model,
                  enrollCheckFuture: enrollCheckFuture,
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),

          // ── 6. Tooltip / legend accordion ─────────────────────────────────
          const _TooltipAccordion(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 1 – HEADER
// ---------------------------------------------------------------------------

class _TournamentHeader extends StatelessWidget {
  const _TournamentHeader({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
      child: Container(
        constraints: BoxConstraints(minHeight: 35.h),
        child: Stack(
          children: [
            // Background game image
            Positioned.fill(
              child: Image.asset(t.tournamentGame.resource, fit: BoxFit.cover),
            ),
            // Blur overlay
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _Dims.blurSigma,
                  sigmaY: _Dims.blurSigma,
                ),
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            ),
            // Foreground content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _TournamentAvatar(model: model),
                  _TournamentNameRow(model: model),
                  _TournamentGameLabel(gameName: t.tournamentGame.desc),
                  _TournamentCounters(model: model),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Avatar with optional edit badge ─────────────────────────────────────────
class _TournamentAvatar extends StatelessWidget {
  const _TournamentAvatar({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;

    return Selector<TournamentDetailModel, String?>(selector: (_, m) => m.tournamentModel.tournamentImageUrl,
      builder: (_, image, ___) => Stack(
        children: [
          Container(
            width: _Dims.avatarSize,
            height: _Dims.avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: CustomFlowTheme.of(context).primary,
                width: _Dims.borderWidth,
              ),
            ),
            child: CircleAvatar(
              radius: _Dims.avatarRadius,
              backgroundImage: image == null
                  ? const AssetImage('assets/images/icons/default_tournament.png') as ImageProvider
                  : NetworkImage(image),
            ),
          ),
          if (model.isTournamentEditable)
            Positioned(
              bottom: 5,
              right: 0,
              child: _EditBadge(
                onTap: () async {
                  final source = await showModalBottomSheet<ImageSource>(
                    context: context,
                    builder: (_) => const _ImageSourceSheet(),
                  );
                  if (source == null) return;
                  if (!context.mounted) return;
                  t.setTournamentImage(source);
                },
                radius: _Dims.editBadgeRadius,
                iconSize: _Dims.editIconSize,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Tournament name row with optional edit icon ──────────────────────────────
class _TournamentNameRow extends StatelessWidget {
  const _TournamentNameRow({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;

    return Selector<TournamentDetailModel, String>(selector: (_, m) => m.tournamentModel.tournamentName,
      builder: (_, name, ___) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
        child: SizedBox(
          width: 75.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  name,
                  style: CustomFlowTheme.of(context).titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              if (model.isTournamentEditable)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 20),
                  child: _EditBadge(
                    onTap: () {
                      if (!context.mounted) return;
                      context.goNamed(
                        'DialogChangeTournamentName',
                        pathParameters: {'tournamentId': t.tournamentId}
                            .withoutNulls,
                        extra: {
                          'req': model.showChangeTournamentNameFormRequest(),
                        },
                      );
                    },
                    radius: _Dims.nameBadgeRadius,
                    iconSize: _Dims.nameBadgeIconSize,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game label ───────────────────────────────────────────────────────────────
class _TournamentGameLabel extends StatelessWidget {
  const _TournamentGameLabel({required this.gameName});

  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
      child: SizedBox(
        width: 75.w,
        child: Text(
          gameName,
          style: CustomFlowTheme.of(context).titleSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ── Counters (pre-registered / waiting / registered) ────────────────────────
class _TournamentCounters extends StatelessWidget {
  const _TournamentCounters({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left placeholder – kept to preserve original layout intent.
        const Text('quattro'),
        // Right counters
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (t.tournamentPreRegistrationEn)
                Selector<TournamentDetailModel, int>(selector: (_, m) => m.tournamentModel.tournamentPreRegisteredSize,
                  builder: (_, size, ___) => _CounterLabel(
                    count: size,
                    label: ' Pre iscritti',
                  ),
                ),
              if (t.tournamentWaitingListEn)
                Selector<TournamentDetailModel, int>(selector: (_, m) => m.tournamentModel.tournamentWaitingSize,
                  builder: (_, size, ___) => _CounterLabel(
                    count: size,
                    label: ' Waiting list',
                  ),
                ),
              Selector<TournamentDetailModel, int>(selector: (_, m) => m.tournamentModel.tournamentRegisteredSize,
                builder: (_, size, ___) => _CounterLabel(
                  count: size,
                  label: ' Iscritti',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterLabel extends StatelessWidget {
  const _CounterLabel({
    required this.count,
    required this.label,
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext ctx) {
    return Text.rich(
      textAlign: TextAlign.right,
      TextSpan(children: [
        TextSpan(
          text: count.toString(),
          style: CustomFlowTheme.of(ctx).headlineSmall,
        ),
        TextSpan(
          text: label,
          style: CustomFlowTheme.of(ctx).bodySmall,
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 2 – SETTINGS ROW 1  (state / date / capacity)
// ---------------------------------------------------------------------------

class _SettingsRowOne extends StatelessWidget {
  const _SettingsRowOne({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StateDropdown(model: model),
        _DateSelector(model: model),
        _CapacitySelector(model: model),
      ],
    );
  }
}

// ── State dropdown ───────────────────────────────────────────────────────────
class _StateDropdown extends StatelessWidget {
  const _StateDropdown({required this.model});

  final TournamentDetailModel model;

  List<StateTournament> get _visibleStates {
    final current = model.tournamentModel.tournamentState.indexState;
    return StateTournament.values.where((s) {
      if (s.indexState == 0) return false;
      if (s.indexState > current + 1) return false;
      if (s.indexState < current - 1) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;
    final states = _visibleStates;

    return Selector<TournamentDetailModel, StateTournament>(selector: (_, m) => m.tournamentModel.tournamentState,
      builder: (_, state, ___) => _SettingsCell(
        child: DropdownButton<String>(
          alignment: Alignment.center,
          value: state.name,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
          iconSize: 30,
          underline: const SizedBox.shrink(),
          onChanged: model.canInteractOn
              ? (String? newValue) {
            if (newValue == null || !context.mounted) return;
            context.goNamed(
              'DialogState',
              pathParameters: {'tournamentId': t.tournamentId}.withoutNulls,
              extra: {
                'req': model
                    .showChangeTournamentStateAlertRequest(newValue),
              },
            );
          }
              : null,
          items: states.map((s) {
            return DropdownMenuItem<String>(
              value: s.name,
              child: Text(
                s.desc,
                style: TextStyle(
                  color: s.indexState == state.indexState
                      ? CustomFlowTheme.of(context).primary
                      : CustomFlowTheme.of(context).info,
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (_) => states.map<Widget>((s) {
            return _SettingsCellContent(
              title: 'STATO',
              subtitle: s.desc,
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Date selector ────────────────────────────────────────────────────────────
class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;
    final editable = model.isTournamentEditable;

    return InkWell(
      onTap: () {
        if (editable) _showDatePicker(context, t);
      },
      child: Selector<TournamentDetailModel, DateTime?>(selector: (_, m) => m.tournamentModel.tournamentDate,
        builder: (_, date, ___) => _SettingsCell(
          color: editable
              ? CustomFlowTheme.of(context).info
              : Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SettingsCellContent(
                title: 'DATA',
                subtitle: DateFormat('dd/MM/yy')
                    .format(date ?? DateTime.now()),
                subtitleColor: editable ? Colors.grey : Colors.black,
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, TournamentModel t) async {
    final now = DateTime.now();
    final initial = t.tournamentDate ?? now;
    final first = now.isBefore(initial) ? now : initial;

    final picked = await showDatePicker(
      locale: const Locale('it'),
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2101),
    );
    if (picked != null) t.setTournamentData(picked);
  }
}

// ── Capacity selector ────────────────────────────────────────────────────────

class _CapacitySelector extends StatelessWidget {
  const _CapacitySelector({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    final t = model.tournamentModel;
    final editable = model.isTournamentEditable;

    return InkWell(
      onTap: () {
        if (!editable || !context.mounted) return;
        context.goNamed(
          'DialogChangeCapacity',
          pathParameters: {'tournamentId': t.tournamentId}.withoutNulls,
          extra: {
            'req': model.showChangeTournamentCapacityAlertFormRequest(),
          },
        );
      },
      child: Selector<TournamentDetailModel, String>(selector: (_, m) => m.tournamentModel.tournamentCapacity,
        builder: (_, cap, ___) => _SettingsCell(
          color: editable
              ? CustomFlowTheme.of(context).info
              : Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SettingsCellContent(
                title: 'CAPIENZA',
                subtitle: cap,
                subtitleColor: editable ? Colors.grey : Colors.black,
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 3 – SETTINGS ROW 2  (pre-registration / waiting list)
// ---------------------------------------------------------------------------

class _SettingsRowTwo extends StatelessWidget {
  const _SettingsRowTwo({required this.model});

  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
      Selector<TournamentDetailModel, bool>(selector: (_, m) => m.tournamentModel.tournamentPreRegistrationEn,
        builder: (_, flag, ___) => _ToggleCell(
            model: model,
            title: 'PRE ISCRIZIONI',
            enabled: model.isTournamentEditable,
            value: flag,
            onTap: () {
              if (!model.isTournamentEditable || !context.mounted) return;
              context.goNamed(
                'DialogPreIscrizioni',
                pathParameters: {
                  'tournamentId': model.tournamentModel.tournamentId,
                }.withoutNulls,
                extra: {'req': model.showSwitchPreIscrizioniAlertRequest()},
              );
            },
          ),
        ),
        Selector<TournamentDetailModel, bool>(selector: (_, m) => m.tournamentModel.tournamentWaitingListEn,
          builder: (_, flag, ___) => _ToggleCell(
            model: model,
            title: 'WAITING LIST',
            enabled: model.tournamentModel.tournamentWaitingListPossible,
            value: flag,
            onTap: () {
              if (!model.isTournamentEditable || !context.mounted) return;
              context.goNamed(
                'DialogWaitingList',
                pathParameters: {
                  'tournamentId': model.tournamentModel.tournamentId,
                }.withoutNulls,
                extra: {'req': model.showSwitchWaitingListAlertRequest()},
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ToggleCell extends StatelessWidget {
  const _ToggleCell({
    required this.model,
    required this.title,
    required this.enabled,
    required this.value,
    required this.onTap,
  });

  final TournamentDetailModel model;
  final String title;
  final bool enabled;
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50.w,
        height: 30.sp,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              enabled ? CustomFlowTheme.of(context).info : Colors.grey,
              value
                  ? CustomFlowTheme.of(context).success
                  : CustomFlowTheme.of(context).warning,
            ],
          ),
          border: Border.all(
            color: CustomFlowTheme.of(context).alternate,
            width: _Dims.settingsBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: CustomFlowTheme.of(context)
                      .titleSmall
                      .override(color: Colors.black),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.toString(),
                style: CustomFlowTheme.of(context)
                    .labelLarge
                    .override(color: Colors.grey.shade900),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 4 – WINNER AREA
// ---------------------------------------------------------------------------

class _WinnerArea extends StatelessWidget {
  const _WinnerArea({required this.winners});

  final List<dynamic> winners;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(20),
      child: Column(
        children: winners.map((item) {
          final userId = item[PocketbaseUser.idFieldName];
          if (userId == null) return const SizedBox.shrink();
          return TournamentWinnerCardWidget(
            name: item[PocketbaseUser.nameFieldName],
            surname: item[PocketbaseUser.surnameFieldName],
            username: item[PocketbaseUser.usernameFieldName],
            userId: userId,
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 5 – REGISTRATION AREA
// Uses a stable Future reference to prevent flickering rebuilds.
// The RegistrationStatus enum (computed in the model) drives the UI decision.
// ---------------------------------------------------------------------------

class _RegistrationArea extends StatelessWidget {
  const _RegistrationArea({
    required this.model,
    required this.enrollCheckFuture,
  });

  final TournamentDetailModel model;
  final Future<EnrollmentCheckResult> enrollCheckFuture;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(20),
      child: FutureBuilder<EnrollmentCheckResult>(
        future: enrollCheckFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Delegate the decision to the model, keeping the view purely
          // declarative. Each status maps to one widget below.
          final status = model.resolveRegistrationStatus(snapshot.data!);

          return switch (status) {
            RegistrationStatus.canRegister       => _PreRegisterButton(model: model),
            RegistrationStatus.canJoinWaiting    => _WaitingListButton(model: model),
            RegistrationStatus.alreadyEnrolled   => _DeEnrollSection(model: model),
            RegistrationStatus.tournamentFull    => _InfoBox(
              message:
              'Il torneo ha raggiunto il limite e non è stata abilitata una waiting list. '
                  'Monitoralo per vedere se vengono aggiunti nuovi posti o se ne liberano alcuni.',
              context: context,
            ),
            RegistrationStatus.preRegDisabled    => _InfoBox(
              message:
              'Non è possibile preregistrarsi. Recati il giorno stabilito presso la sede '
                  'dell\'evento o contatta l\'organizzatore per avere le modalità di registrazione.',
              context: context,
            ),
          };
        },
      ),
    );
  }
}

class _PreRegisterButton extends StatelessWidget {
  const _PreRegisterButton({required this.model});
  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    return AFButtonWidget(
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (!context.mounted) return;
        context.goNamed(
          'DialogPreRegisterPlayer',
          pathParameters: {
            'tournamentId': model.tournamentModel.tournamentId,
          }.withoutNulls,
          extra: {'req': model.showAddToPreRegisterListAlertRequest()},
        );
      },
      text: 'Pre registrati!',
      options: _defaultButtonOptions(context),
    );
  }
}

class _WaitingListButton extends StatelessWidget {
  const _WaitingListButton({required this.model});
  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    return AFButtonWidget(
      onPressed: () {
        FocusScope.of(context).unfocus();
        if (!context.mounted) return;
        context.goNamed(
          'DialogWaitingListPlayer',
          pathParameters: {
            'tournamentId': model.tournamentModel.tournamentId,
          }.withoutNulls,
          extra: {'req': model.showAddToWaitingListAlertRequest()},
        );
      },
      text: 'Aggiungiti alla waiting list!',
      options: _defaultButtonOptions(context),
    );
  }
}

class _DeEnrollSection extends StatelessWidget {
  const _DeEnrollSection({required this.model});
  final TournamentDetailModel model;

  @override
  Widget build(BuildContext context) {
    return _InfoBox(
      context: context,
      message: 'Sei già censito per questo torneo!',
      child: AFButtonWidget(
        onPressed: () {
          FocusScope.of(context).unfocus();
          if (!context.mounted) return;
          context.goNamed(
            'DialogDeEnrollPlayer',
            pathParameters: {
              'tournamentId': model.tournamentModel.tournamentId,
            }.withoutNulls,
            extra: {'req': model.showDeEnrollPlayerAlertRequest()},
          );
        },
        text: 'De-registrati',
        options: AFButtonOptions(
          width: double.infinity,
          height: _Dims.buttonHeight,
          padding: EdgeInsetsDirectional.zero,
          iconPadding: EdgeInsetsDirectional.zero,
          color: const Color(0xFFFFD4D4),
          textStyle: CustomFlowTheme.of(context)
              .bodyMedium
              .override(color: const Color(0xFFB74D4D)),
          elevation: 0,
          borderSide: BorderSide(
            color: CustomFlowTheme.of(context).primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(_Dims.buttonRadius),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECTION 6 – TOOLTIP ACCORDION  (fully static)
// ---------------------------------------------------------------------------

class _TooltipAccordion extends StatelessWidget {
  const _TooltipAccordion();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(20),
      child: SimpleAccordion(
        children: [
          AccordionHeaderItem(
            title: 'Legenda degli stati',
            children: [
              AccordionItem(
                title:
                'open: In questo stato il torneo non è visibile e non può essere trovato dagli altri utenti. '
                    'In questa fase potrai finalizzare le configurazioni prima di farlo passare allo stato successivo.',
              ),
              AccordionItem(
                title:
                'ready: In questo stato il torneo è visibile a tutti gli utenti che possono preiscriversi '
                    'o se possibile o aggiungerlo ai tornei interessati.',
              ),
              AccordionItem(
                title:
                'ongoing: In questo stato il torneo è in corso. Non sono possibili altre iscrizioni ma '
                    'in questa fase si possono generare i vari turni e anche la top.',
              ),
              AccordionItem(
                title:
                'close: In questo stato il torneo è chiuso. Non possono essere modificati parametri o generati '
                    'nuovi round. La classifica finale decreta il vincitore.',
              ),
            ],
          ),
          AccordionHeaderItem(
            title: 'Pre-registrazione',
            children: [
              AccordionItem(
                title:
                'Questa configurazione permette agli utenti di pre-registrarsi. Se tale configurazione è abilitata, '
                    'nel momento in cui ci sarà l\'iscrizione ufficiale l\'app segnalerà ogni qual volta si sta '
                    'registrando un giocatore al di fuori di questa lista e chiederà conferma per procedere.',
              ),
            ],
          ),
          AccordionHeaderItem(
            title: 'Waiting list',
            children: [
              AccordionItem(
                title:
                'Questa configurazione può essere abilitata solo se è stata definita una capienza massima del torneo '
                    'e se le preiscrizioni sono state abilitate. Nel momento in cui i preiscritti avranno raggiunto la '
                    'capienza del torneo, gli altri saranno posizionati in coda in questa nuova lista. '
                    'L\'app segnalerà ogni volta si sta iscrivendo un giocatore all\'interno di questa lista.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED HELPER WIDGETS
// ---------------------------------------------------------------------------

/// Generic bordered cell used in settings rows.
class _SettingsCell extends StatelessWidget {
  const _SettingsCell({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 33.w,
      height: 30.sp,
      decoration: BoxDecoration(
        color: color ?? CustomFlowTheme.of(context).info,
        border: Border.all(
          color: CustomFlowTheme.of(context).alternate,
          width: _Dims.settingsBorder,
        ),
      ),
      child: child,
    );
  }
}

/// Two-line label (title + subtitle) used inside settings cells.
class _SettingsCellContent extends StatelessWidget {
  const _SettingsCellContent({
    required this.title,
    required this.subtitle,
    this.subtitleColor,
  });

  final String title;
  final String subtitle;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: CustomFlowTheme.of(context)
                .titleMedium
                .override(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: CustomFlowTheme.of(context)
                .labelLarge
                .override(color: subtitleColor ?? Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Small circular edit badge used in avatars and name rows.
class _EditBadge extends StatelessWidget {
  const _EditBadge({
    required this.onTap,
    required this.radius,
    required this.iconSize,
  });

  final VoidCallback onTap;
  final double radius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: CustomFlowTheme.of(context).primary,
        child: Icon(
          Icons.edit,
          size: iconSize,
          color: CustomFlowTheme.of(context).info,
        ),
      ),
    );
  }
}

/// Generic info / message box used in the registration area.
class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.message,
    required this.context,
    this.child,
  });

  final String message;
  // ignore: avoid_field_initializers_in_const_classes
  final BuildContext context;
  final Widget? child;

  @override
  Widget build(BuildContext ctx) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: CustomFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CustomFlowTheme.of(context).alternate,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (child != null)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                  child: Text(
                    message,
                    style: CustomFlowTheme.of(context).labelLarge,
                  ),
                )
              else
                Text(
                  message,
                  style: CustomFlowTheme.of(context).labelLarge,
                ),
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Fotocamera'),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Galleria / File'),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED HELPER FUNCTION
// ---------------------------------------------------------------------------
AFButtonOptions _defaultButtonOptions(BuildContext context) {
  return AFButtonOptions(
    width: double.infinity,
    height: _Dims.buttonHeight,
    padding: EdgeInsetsDirectional.zero,
    iconPadding: EdgeInsetsDirectional.zero,
    color: CustomFlowTheme.of(context).secondary,
    textStyle: CustomFlowTheme.of(context).bodyMedium,
    elevation: 0,
    borderSide: BorderSide(
      color: CustomFlowTheme.of(context).primary,
      width: 2,
    ),
    borderRadius: BorderRadius.circular(_Dims.buttonRadius),
  );
}