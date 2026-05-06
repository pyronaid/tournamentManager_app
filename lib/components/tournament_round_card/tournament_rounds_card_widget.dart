// components/tournament_round_card/tournament_rounds_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';

class TournamentRoundsCardWidget extends StatelessWidget {
  const TournamentRoundsCardWidget({
    super.key,
    required this.roundRef,
    required this.index,
    required this.deleteFun,
    required this.deepFun,
    required this.editable,
    this.closeFun,
  });

  final RoundsRecord roundRef;  // non-nullable: guard at call site
  final int index;
  final Future<void> Function(RoundsRecord round) deleteFun;
  final Future<void> Function(RoundsRecord round)? closeFun;
  final void Function(String roundId) deepFun;
  final bool editable;

  // ── AlertRequest builders (were TournamentRoundsCardModel methods) ────────

  AlertRequest _deleteRequest() => AlertRequest(
    title: 'ATTENZIONE: Cancellazione del round in corso...',
    description: 'Sei sicuro di voler eliminare questo Round?',
    buttonTitleCancelled: 'Annulla',
    buttonTitleConfirmed: 'Continua',
    functionConfirmed: (_) => deleteFun(roundRef),
  );

  AlertRequest _closeRequest() => AlertRequest(
    title: 'ATTENZIONE: Chiusura del torneo in corso...',
    description: 'Sei sicuro di voler chiudere il torneo e nominare il vincitore?',
    buttonTitleCancelled: 'Annulla',
    buttonTitleConfirmed: 'Continua',
    // closeFun is guaranteed non-null at call sites that show this action.
    functionConfirmed: (_) => closeFun!(roundRef),
  );

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Slidable(
        key: ValueKey('round$index'),
        endActionPane: editable
            ? ActionPane(
          motion: const ScrollMotion(),
          children: [
            // Delete action — shown whenever the round is editable.
            SlidableAction(
              onPressed: (_) => context.goNamed(
                'DialogDeleteRound',
                pathParameters: {
                  'tournamentId': roundRef.tournamentId,
                }.withoutNulls,
                extra: {'req': _deleteRequest()},
              ),
              backgroundColor: theme.error,
              foregroundColor: theme.info,
              icon: Icons.delete,
              label: 'Delete',
            ),
            // Close tournament — only when closeFun is provided.
            if (closeFun != null)
              SlidableAction(
                onPressed: (_) => context.goNamed(
                  'DialogCloseTournament',
                  pathParameters: {
                    'tournamentId': roundRef.tournamentId,
                  }.withoutNulls,
                  extra: {'req': _closeRequest()},
                ),
                backgroundColor: theme.completed,
                foregroundColor: theme.info,
                icon: Icons.key,
                label: 'Chiudi\nTorneo',
              ),
          ],
        )
            : null,
        child: InkWell(
          onTap: () => deepFun(roundRef.uid),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.tertiary,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: _RoundTypeColumn(roundRef: roundRef),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.loose,
                    child: _RoundStatsColumn(roundRef: roundRef),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Round type: icon + kind label + round/top label ──────────────────────────
class _RoundTypeColumn extends StatelessWidget {
  const _RoundTypeColumn({required this.roundRef});

  final RoundsRecord roundRef;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final isTopCut = roundRef.roundKind == RoundKind.topcut;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          isTopCut
              ? 'assets/images/icons/versus_top.png'
              : 'assets/images/icons/versus.png',
          width: 20.w,
          height: 20.w,
          fit: BoxFit.cover,
        ),
        Text(
          roundRef.roundKind.desc,
          style: theme.titleMedium.override(color: theme.cardMain),
          softWrap: true,
        ),
        Text(
          isTopCut ? 'TOP ${roundRef.size}' : 'ROUND ${roundRef.index}',
          style: theme.titleMedium.override(color: theme.cardMain),
          softWrap: true,
        ),
      ],
    );
  }
}

// ── Round stats: completion status, player count, pairing progress ───────────
class _RoundStatsColumn extends StatelessWidget {
  const _RoundStatsColumn({required this.roundRef});

  final RoundsRecord roundRef;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StatRow(
          asset: roundRef.completed
              ? 'assets/images/icons/completed.png'
              : 'assets/images/icons/ongoing.png',
          label: roundRef.completed ? 'Completato' : 'In corso',
        ),
        _StatRow(
          asset: 'assets/images/icons/player.png',
          label: 'Giocatori del round : ${roundRef.size}',
        ),
        _StatRow(
          asset: 'assets/images/icons/round.png',
          label:
          'Pairing completati : ${roundRef.matchCompleted} / ${roundRef.matchAll}',
        ),
      ],
    );
  }
}

// ── Single stat row: icon + label ────────────────────────────────────────────
// Extracted: used three times in _RoundStatsColumn with identical structure.
class _StatRow extends StatelessWidget {
  const _StatRow({required this.asset, required this.label});

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(asset, width: 30, height: 30, fit: BoxFit.cover),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: CustomFlowTheme.of(context)
                .labelLarge
                .override(color: CustomFlowTheme.of(context).cardMain),
            maxLines: null,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}