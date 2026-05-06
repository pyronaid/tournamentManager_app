// components/tournament_winner_card/tournament_winner_card_widget.dart

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';

/// Displays a tournament winner's identity card.
class TournamentWinnerCardWidget extends StatelessWidget {
  const TournamentWinnerCardWidget({
    super.key,
    required this.name,
    required this.surname,
    required this.username,
    required this.userId,
  });

  final String name;
  final String surname;
  final String username;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.tertiary,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(username,
                  style: theme.titleLarge.override(color: theme.cardMain)),
              Text('$name $surname',
                  style: theme.titleMedium.override(color: theme.cardSecond)),
              Text(userId,
                  style: theme.bodySmall.override(color: theme.cardMain)),
            ],
          ),
        ),
      ),
    );
  }
}