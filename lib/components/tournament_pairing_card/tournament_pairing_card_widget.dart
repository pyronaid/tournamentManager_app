// components/tournament_pairing_card/tournament_pairing_card_widget.dart

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/backend/schema/pairings_record.dart';

class TournamentPairingsCardWidget extends StatelessWidget {
  const TournamentPairingsCardWidget({
    super.key,
    required this.pairingRef,
    required this.index,
    required this.deleteFun,
  });

  final PairingsRecord pairingRef;    // non-nullable: guard at call site
  final int index;
  final Future<void> Function(String pairingId) deleteFun;

  AlertRequest _deleteRequest() => AlertRequest(
        title: 'ATTENZIONE: Cancellazione del pairing in corso...',
        description: 'Sei sicuro di voler eliminare questo Pairing?',
        buttonTitleCancelled: 'Annulla',
        buttonTitleConfirmed: 'Continua',
        functionConfirmed: (_) => deleteFun(pairingRef.uid),
      );

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final p = pairingRef;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: Container(
          width: double.infinity,
          color: theme.tertiary,
          constraints: const BoxConstraints(minHeight: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Completion status stripe ─────────────────────────────────
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Container(
                  width: 15,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: p.completed ? theme.completed : theme.ongoing,
                  ),
                ),
              ),

              // ── Player A win/loss icon ───────────────────────────────────
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: _PlayerResultIcon(won: p.playerAWon),
              ),

              // ── Player A name ────────────────────────────────────────────
              Flexible(
                flex: 5,
                fit: FlexFit.loose,
                child: _PlayerNameColumn(
                  name: p.namePlayerA,
                  surname: p.surnamePlayerA,
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),

              // ── Centre column: table + status icons ──────────────────────
              Flexible(
                flex: 3,
                fit: FlexFit.loose,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(5, 15, 5, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _TableIndexRow(tableIndex: p.tableIndex),
                      if (p.dropPlayerA || p.dropPlayerB)
                        _PairingIconRow(
                          showLeft: p.dropPlayerA,
                          showRight: p.dropPlayerB,
                          asset: 'assets/images/icons/dropped.png',
                        ),
                      if (p.isBye)
                        _PairingIconRow(
                          showLeft: p.playerAWon,
                          showRight: p.playerBWon,
                          asset: 'assets/images/icons/bye.png',
                        ),
                      if (p.noShow)
                        _PairingIconRow(
                          // noShow: the LOSER gets the icon
                          showLeft: !p.playerAWon,
                          showRight: !p.playerBWon,
                          asset: 'assets/images/icons/noshow.png',
                        ),
                      if (p.doubleLoss)
                        _PairingIconRow(
                          showLeft: true,
                          showRight: true,
                          asset: 'assets/images/icons/double_loss.png',
                        ),
                    ],
                  ),
                ),
              ),

              // ── Player B name ────────────────────────────────────────────
              Flexible(
                flex: 5,
                fit: FlexFit.loose,
                child: _PlayerNameColumn(
                  name: p.namePlayerB,
                  surname: p.surnamePlayerB,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
              ),

              // ── Player B win/loss icon ───────────────────────────────────
              Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: _PlayerResultIcon(won: p.playerBWon),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Win / loss result icon ───────────────────────────────────────────────────
class _PlayerResultIcon extends StatelessWidget {
  const _PlayerResultIcon({required this.won});

  final bool won;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(5, 15, 5, 15),
        child: Image.asset(
          won
              ? 'assets/images/icons/playerWin.png'
              : 'assets/images/icons/playerLose.png',
          fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}

// ── Player name + surname block ──────────────────────────────────────────────
class _PlayerNameColumn extends StatelessWidget {
  const _PlayerNameColumn({
    required this.name,
    required this.surname,
    required this.crossAxisAlignment,
  });

  final String name;
  final String surname;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text('NOME',
                style: theme.titleMedium.override(color: theme.cardMain),
                softWrap: true),
            Text(name,
                style: theme.bodySmall.override(color: theme.cardMain),
                softWrap: true),
            Text('COGN.',
                style: theme.titleMedium.override(color: theme.cardMain),
                softWrap: true),
            Text(surname,
                style: theme.bodySmall.override(color: theme.cardMain),
                softWrap: true),
          ],
        ),
      ),
    );
  }
}

// ── Table index row ──────────────────────────────────────────────────────────
class _TableIndexRow extends StatelessWidget {
  const _TableIndexRow({required this.tableIndex});

  final int tableIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: Image.asset('assets/images/icons/table.png',
              fit: BoxFit.cover),
        ),
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Text(
            ' $tableIndex',
            style: CustomFlowTheme.of(context)
                .titleMedium
                .override(color: CustomFlowTheme.of(context).cardMain),
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

// ── Symmetric icon row (drop / bye / noshow / doubleLoss) ───────────────────
// Replaces four nearly-identical copy-pasted Row blocks.
// [showLeft] / [showRight] control which side renders the icon vs SizedBox.
class _PairingIconRow extends StatelessWidget {
  const _PairingIconRow({
    required this.showLeft,
    required this.showRight,
    required this.asset,
  });

  final bool showLeft;
  final bool showRight;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: showLeft
              ? Image.asset(asset, fit: BoxFit.cover)
              : const SizedBox.shrink(),
        ),
        const Flexible(flex: 1, fit: FlexFit.tight, child: SizedBox.shrink()),
        Flexible(
          flex: 2,
          fit: FlexFit.tight,
          child: showRight
              ? Image.asset(asset, fit: BoxFit.cover)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
