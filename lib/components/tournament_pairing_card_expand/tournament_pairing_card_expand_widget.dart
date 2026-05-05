// components/tournament_pairing_card_expand/tournament_pairing_card_expand_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/schema/pairings_record.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';

class TournamentPairingCardExpandWidget extends StatefulWidget {
  const TournamentPairingCardExpandWidget({
    super.key,
    required this.pairingRef,
    required this.updateFun,
  });

  final PairingsRecord pairingRef; // non-nullable: guard at call site
  final Future<void> Function(String pairingId, Map<String, dynamic> data)
      updateFun;

  @override
  State<TournamentPairingCardExpandWidget> createState() =>
      _TournamentPairingCardExpandWidgetState();
}

class _TournamentPairingCardExpandWidgetState
    extends State<TournamentPairingCardExpandWidget> {

  // ── Constant (was TournamentPairingCardExpandModel.doubleLossString) ──────
  static const String _doubleLossKey = 'doubleLoss';

  // ── Local UI state (was TournamentPairingCardExpandModel fields) ──────────
  late String? _selectedWinner;
  late bool _dropPlayerA;
  late bool _dropPlayerB;
  late bool _noShow;
  final List<String> _errors = [];
  final _formKey = GlobalKey<FormState>();

  // Convenience accessor — avoids repeating widget.pairingRef everywhere.
  PairingsRecord get _p => widget.pairingRef;

  @override
  void initState() {
    super.initState();
    // Mirror initial values from the record.
    _selectedWinner = _p.doubleLoss ? _doubleLossKey : _p.winner;
    _dropPlayerA = _p.dropPlayerA;
    _dropPlayerB = _p.dropPlayerB;
    _noShow = _p.noShow;
  }

  // ── State mutators (were model methods) ───────────────────────────────────

  void _onRadioChanged(String? value) {
    setState(() {
      // doubleLoss and noShow are mutually exclusive.
      if (value == _doubleLossKey && _noShow) _noShow = false;
      _selectedWinner = value;
    });
  }

  void _onDropPlayerA(bool value) => setState(() => _dropPlayerA = value);
  void _onDropPlayerB(bool value) => setState(() => _dropPlayerB = value);

  void _onNoShow(bool value) {
    setState(() {
      // noShow and doubleLoss are mutually exclusive.
      if (value && _selectedWinner == _doubleLossKey) _selectedWinner = null;
      _noShow = value;
    });
  }

  // ── Save handler ──────────────────────────────────────────────────────────

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    // Clear stale errors.
    if (_errors.isNotEmpty) setState(() => _errors.clear());

    if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedWinner == null) {
      setState(() => _errors.add('Nessuna opzione winner scelta'));
      return;
    }

    final Map<String, dynamic> patch = {
      PairingsRecord.noShowFieldName: _noShow,
      PairingsRecord.dropPlayerAFieldName: _dropPlayerA,
      PairingsRecord.dropPlayerBFieldName: _dropPlayerB,
      if (_selectedWinner == _doubleLossKey) ...{
        PairingsRecord.doubleLossFieldName: true,
        PairingsRecord.winnerFieldName: null,
      } else ...{
        PairingsRecord.winnerFieldName: _selectedWinner,
        PairingsRecord.doubleLossFieldName: false,
      },
    };

    await widget.updateFun(_p.uid, patch);
    HapticFeedback.lightImpact();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final isSwiss = _p.roundKind == RoundKind.swiss;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        child: Container(
          width: double.infinity,
          color: theme.tertiaryDark,
          constraints: const BoxConstraints(minHeight: 100),
          child: Center(
            child: Padding(
              padding: const EdgeInsetsDirectional.all(10),
              child: Form(
                key: _formKey,
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(1),
                  },
                  children: [
                    _headerRow(theme),
                    _playerARow(theme, isSwiss),
                    _playerBRow(theme, isSwiss),
                    if (isSwiss) _doubleLossRow(theme),
                    _actionsRow(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Table rows ────────────────────────────────────────────────────────────

  TableRow _headerRow(CustomFlowTheme theme) {
    return TableRow(children: [
      TableCell(
        child: Text('WINNER',
            style: theme.titleMedium.override(color: theme.cardMain),
            softWrap: true),
      ),
      const TableCell(child: SizedBox.shrink()),
    ]);
  }

  TableRow _playerARow(CustomFlowTheme theme, bool isSwiss) {
    return TableRow(children: [
      TableCell(
        child: _PlayerRadioTile(
          name: _p.namePlayerA,
          surname: _p.surnamePlayerA,
          username: _p.usernamePlayerA,
          value: _p.playerA,
          groupValue: _selectedWinner,
          onChanged: _onRadioChanged,
        ),
      ),
      TableCell(
        child: isSwiss
            ? _DropSwitch(
                label: 'Drop Torneo',
                value: _dropPlayerA,
                onChanged: _onDropPlayerA,
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }

  TableRow _playerBRow(CustomFlowTheme theme, bool isSwiss) {
    return TableRow(children: [
      TableCell(
        child: _PlayerRadioTile(
          name: _p.namePlayerB,
          surname: _p.surnamePlayerB,
          username: _p.usernamePlayerB,
          value: _p.playerB,
          groupValue: _selectedWinner,
          onChanged: _onRadioChanged,
        ),
      ),
      TableCell(
        child: isSwiss
            ? _DropSwitch(
                label: 'Drop Torneo',
                value: _dropPlayerB,
                onChanged: _onDropPlayerB,
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }

  TableRow _doubleLossRow(CustomFlowTheme theme) {
    return TableRow(children: [
      TableCell(
        child: ListTile(
          leading: Radio<String>(
            value: _doubleLossKey,
            groupValue: _selectedWinner,
            onChanged: _onRadioChanged,
          ),
          title: Text('doubleLoss',
              style: theme.bodySmall.override(color: theme.cardMain),
              softWrap: true),
        ),
      ),
      TableCell(
        child: _DropSwitch(
          label: 'No Show Win',
          value: _noShow,
          onChanged: _onNoShow,
        ),
      ),
    ]);
  }

  TableRow _actionsRow(CustomFlowTheme theme) {
    return TableRow(children: [
      // Error messages column
      TableCell(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _errors
              .map((e) => Text(e,
                  style: theme.bodySmall.override(color: theme.error),
                  softWrap: true))
              .toList(),
        ),
      ),
      // Save button column
      TableCell(
        child: Row(
          children: [
            const Expanded(flex: 1, child: SizedBox.shrink()),
            Expanded(
              flex: 1,
              child: AFButtonWidget(
                onPressed: _save,
                text: 'Salva',
                options: AFButtonOptions(
                  height: 40,
                  padding: EdgeInsetsDirectional.zero,
                  iconPadding: EdgeInsetsDirectional.zero,
                  color: theme.primary,
                  textStyle:
                      theme.labelLarge.override(color: theme.info),
                  elevation: 0,
                  borderSide: const BorderSide(
                      color: Colors.transparent, width: 1),
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}

// ── Player radio tile ────────────────────────────────────────────────────────
// Extracted: used identically for player A and B, only data differs.
class _PlayerRadioTile extends StatelessWidget {
  const _PlayerRadioTile({
    required this.name,
    required this.surname,
    required this.username,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String name;
  final String surname;
  final String username;
  final String value;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final style = theme.bodySmall.override(color: theme.cardMain);

    return ListTile(
      leading: Radio<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: style, softWrap: true),
          Text(surname, style: style, softWrap: true),
          Text(username, style: style, softWrap: true),
        ],
      ),
    );
  }
}

// ── Drop / toggle switch ─────────────────────────────────────────────────────
// Extracted: used for dropPlayerA, dropPlayerB, and noShow.
class _DropSwitch extends StatelessWidget {
  const _DropSwitch({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: theme.bodySmall.override(color: theme.cardMain),
        softWrap: true,
      ),
    );
  }
}
