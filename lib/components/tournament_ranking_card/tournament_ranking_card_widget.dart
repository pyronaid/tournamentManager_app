// components/tournament_ranking_card/tournament_ranking_card_widget.dart

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/rankings_record.dart';

/// Displays a single ranking row: position, player name/username, and scores.
class TournamentRankingsCardWidget extends StatelessWidget {
  const TournamentRankingsCardWidget({
    super.key,
    required this.rankingRef,
    required this.index,
  });

  final RankingsRecord rankingRef; // non-nullable: guard at call site
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final cardStyle = theme.bodySmall.override(color: theme.cardMain);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 10, 0),
      child: Container(
        width: double.infinity,
        color: theme.tertiary,
        constraints: const BoxConstraints(minHeight: 100),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Position ──────────────────────────────────────────────────
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: _CenteredText(
                text: '${index + 1}',
                style: theme.titleMedium.override(color: theme.cardMain),
              ),
            ),

            // ── Name + username ───────────────────────────────────────────
            Flexible(
              flex: 5,
              fit: FlexFit.tight,
              child: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${rankingRef.userName} ${rankingRef.userSurname}',
                        style: theme.titleMedium.override(color: theme.cardMain),
                        softWrap: true,
                      ),
                      Text(
                        rankingRef.userUsername,
                        style: cardStyle,
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Points ────────────────────────────────────────────────────
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child: _CenteredText(
                  text: '${rankingRef.points}', style: cardStyle),
            ),

            // ── T1 ────────────────────────────────────────────────────────
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child:
                  _CenteredText(text: '${rankingRef.t1}', style: cardStyle),
            ),

            // ── T2 ────────────────────────────────────────────────────────
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child:
                  _CenteredText(text: '${rankingRef.t2}', style: cardStyle),
            ),

            // ── T3 ────────────────────────────────────────────────────────
            Flexible(
              flex: 2,
              fit: FlexFit.loose,
              child:
                  _CenteredText(text: '${rankingRef.t3}', style: cardStyle),
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
