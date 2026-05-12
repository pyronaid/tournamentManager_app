// components/tournament_card/tournament_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: all percentage widths via responsive_sizer replaced with layout
//   widgets.
//
//   The original layout used:
//     _DateColumn:        width: 15.w  (15% of screen)
//     _NameAddressColumn: width: 60.w  (60% of screen)
//     _StateLabel:        width: 12.w  (12% of screen)
//     Card container:     width: 90.w  (90% of screen)
//
//   Problems:
//   1. The three column widths sum to 87% — the remaining 3% is unaccounted
//      for and causes subtle alignment drift.
//   2. On tablets the name column (60%) is ~480dp, on phones it's ~216dp —
//      the variation is extreme and unrelated to the content.
//   3. The card container width (90%) is redundant because the card is
//      already inside a sliver that fills available width.
//
//   The fix:
//   - Card container: double.infinity (fills the sliver naturally).
//   - Date column:    fixed width (_dateColWidth) — dates are always 2–4
//                     chars wide; a fixed column prevents layout thrash.
//   - State column:   fixed width (_stateColWidth) — state labels are short
//                     fixed-length strings.
//   - Name column:    Expanded — takes all remaining horizontal space.
//                     This is the correct widget for "fill the rest".
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Fixed width of the date column.
  /// Holds "dd / MM / yyyy" stacked vertically — 56dp is comfortable.
  static const double dateColWidth  = 56.0;

  /// Fixed width of the state label column.
  /// State names are 4–8 chars; 52dp fits them with a small margin.
  static const double stateColWidth = 52.0;

  /// Horizontal padding inside the name/address column.
  static const double namePaddingH  = 10.0;

  /// Gap between tournament name and address text.
  static const double nameAddressGap = 10.0;

  /// Horizontal padding of the outer card container.
  static const double cardPaddingH  = 24.0;

  /// Divider height — controls the visible space between cards.
  static const double dividerHeight = 80.0;
}

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

  final TournamentsRecord tournamentRef;
  final bool last;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final bg = active ? theme.secondary : theme.primaryBackground;

    return Container(
      // FIX: double.infinity replaces 90.w — the card fills its sliver parent.
      width: double.infinity,
      color: bg,
      padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.cardPaddingH, 0, _Dims.cardPaddingH, 0),
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
                // FIX: fixed width replaces 15.w.
                _DateColumn(date: tournamentRef.date!, theme: theme),
                // FIX: Expanded replaces 60.w — fills all remaining space.
                Expanded(
                  child: _NameAddressColumn(
                    name: tournamentRef.name,
                    address: tournamentRef.address,
                    isOnline: tournamentRef.isOnlineEn,
                    theme: theme,
                  ),
                ),
                // FIX: fixed width replaces 12.w.
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
              height: _Dims.dividerHeight,
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
  final CustomFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // FIX: fixed _Dims.dateColWidth replaces 15.w.
      width: _Dims.dateColWidth,
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
// FIX: explicit SizedBox(width: 60.w) removed — this widget now fills its
//   Expanded parent naturally via its own unconstrained layout.
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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.namePaddingH, 0, _Dims.namePaddingH, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: CustomFlowTheme.of(context).bodyMedium),
          SizedBox(height: _Dims.nameAddressGap),
          Text(
            isOnline ? 'ONLINE' : address,
            style: CustomFlowTheme.of(context).labelMedium,
          ),
        ],
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
      // FIX: fixed _Dims.stateColWidth replaces 12.w.
      width: _Dims.stateColWidth,
      child: Text(
        state,
        style: CustomFlowTheme.of(context).bodyMicro,
        textAlign: TextAlign.center,
      ),
    );
  }
}
