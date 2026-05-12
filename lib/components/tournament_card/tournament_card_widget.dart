// components/tournament_card/tournament_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';

/// Displays a single tournament row with date, name/address, and state.
/// Tapping navigates to TournamentDetails.
/// [last] controls whether a divider is rendered below the card.
/// [active] drives the background colour swap.
class TournamentCardWidget extends StatelessWidget {
  const TournamentCardWidget({
    super.key,
    required this.tournamentRef,
    required this.last,
    required this.active,
  });

  final TournamentsRecord tournamentRef;  // non-nullable: callers must guard
  final bool last;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final bg = active ? theme.secondary : theme.primaryBackground;

    return Container(
      width: 90.w,
      color: bg,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: Column(
        children: [
          InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              logFirebaseEvent('TOURN_CARD_COMP_Column_ON_TAP');
              logFirebaseEvent('Column_haptic_feedback');
              HapticFeedback.lightImpact();
              logFirebaseEvent('Column_navigate_to');
              context.pushNamedAuth(
                'TournamentDetails',
                context.mounted,
                pathParameters: {'tournamentId': tournamentRef.uid}.withoutNulls,
                extra: {'tournamentRef': tournamentRef.uid},
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _DateColumn(date: tournamentRef.date!, theme: theme),
                _NameAddressColumn(
                  name: tournamentRef.name,
                  address: tournamentRef.address,
                  isOnline: tournamentRef.isOnlineEn,
                  theme: theme,
                ),
                _StateLabel(
                  state: tournamentRef.state.name,
                  theme: theme,
                ),
              ],
            ),
          ),
          if (!last)
            Divider(
              thickness: 1,
              color: active ? theme.primary : theme.primaryText,
              height: 80,
            ),
        ],
      ),
    );
  }
}

// ── Date column ──────────────────────────────────────────────────────────────
class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.date, required this.theme});

  final DateTime date;
  final CustomFlowTheme theme; // adjust type to whatever your theme class is

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 15.w,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(DateFormat('dd').format(date),
              style: CustomFlowTheme.of(context).titleLarge),
          Text(DateFormat('MM').format(date),
              style: CustomFlowTheme.of(context).bodyMedium),
          Text(DateFormat('yyyy').format(date),
              style: CustomFlowTheme.of(context).bodyMedium),
        ],
      ),
    );
  }
}

// ── Name + address column ────────────────────────────────────────────────────
class _NameAddressColumn extends StatelessWidget {
  const _NameAddressColumn({
    required this.name,
    required this.address,
    required this.isOnline,
    required this.theme,
  });

  final String name;
  final String address;
  final bool isOnline;
  final CustomFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60.w,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: CustomFlowTheme.of(context).bodyMedium),
            const SizedBox(height: 10),
            Text(
              isOnline ? 'ONLINE' : address,
              style: CustomFlowTheme.of(context).labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// ── State label ──────────────────────────────────────────────────────────────
class _StateLabel extends StatelessWidget {
  const _StateLabel({required this.state, required this.theme});

  final String state;
  final CustomFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12.w,
      child: Text(
        state,
        style: CustomFlowTheme.of(context).bodyMicro,
        textAlign: TextAlign.center,
      ),
    );
  }
}
