// components/tournament_ranking_card/tournament_ranking_card_widget.dart

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';

/// Displays a single ranking row: position, player name/username, and scores.
class TournamentDecklistCardWidget extends StatelessWidget {
  const TournamentDecklistCardWidget({
    super.key,
    required this.cardRef,
    required this.qty,
  });

  final CardRef cardRef; // non-nullable: guard at call site
  final int qty;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final CardType? cardType = CardTypeX.tryParse(cardRef.frameType);
    final Color outer = cardType != null ? cardType.outer : theme.tertiary;
    final Color inner = cardType != null ? cardType.inner : theme.cardMain;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
      child: Container(
        color: outer,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── qty ──────────────────────────────────────────────────
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: _CenteredText(
                text: '$qty',
                style: theme.titleMedium.override(color: inner),
              ),
            ),

            // ── Name + username ───────────────────────────────────────────
            Flexible(
              flex: 9,
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardRef.cardName,
                        style: theme.titleMedium.override(color: inner),
                        softWrap: true,
                      ),
                      Text(
                        cardRef.type.toString(),
                        style: theme.bodySmall.override(color: inner),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Repeated pattern in the original — extracted once.
class _CenteredText extends StatelessWidget {
  const _CenteredText({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(text, style: style, softWrap: true),
    );
  }
}
