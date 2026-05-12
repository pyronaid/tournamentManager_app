// components/tournament_pick_card/tournament_pick_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/ExternalAppManagerService.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX: 15.w / 50.w / 25.w on the three columns replaced with the same
//   pattern used in tournament_card_widget:
//   - _dateColWidth:     fixed — date strings are always short
//   - _gameIconColWidth: fixed — the icon is always the same size
//   - _InfoColumn:       Expanded — fills all remaining horizontal space
//
//   The original percentages summed to 90%, leaving 10% unaccounted for.
//   The new layout is geometrically exact.
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Fixed width of the date column (dd/MM/yyyy stacked).
  static const double dateColWidth    = 56.0;

  /// Fixed width of the game icon column.
  /// The icon itself is 70×70 — a 90dp column gives a small margin.
  static const double gameIconColWidth = 90.0;

  /// The game icon tap target size.
  static const double gameIconSize    = 70.0;

  /// Horizontal padding inside the info column.
  static const double infoPaddingH    = 10.0;

  /// Card outer margin.
  static const double cardMargin      = 10.0;

  /// Card inner padding.
  static const double cardPadding     = 5.0;

  /// Card corner radius.
  static const double cardRadius      = 20.0;

  /// Divider height inside the info column.
  static const double dividerHeight   = 10.0;

  /// Map icon size inside the address RichText.
  static const double mapIconSize     = 18.0;
}

/// Compact tournament card used in pick/selection lists.
/// Tapping the game icon navigates to TournamentDetails.
/// Tapping the address icon launches the external map app.
class TournamentPickCardWidget extends StatelessWidget {
  const TournamentPickCardWidget({
    super.key,
    required this.tournamentRef,
  });

  final TournamentsRecord tournamentRef;

  void _openMap() {
    GetIt.instance<ExternalAppManagerService>().launchMapApp(
      tournamentRef.latitude,
      tournamentRef.longitude,
      tournamentRef.name,
    );
  }

  void _navigateToDetail(BuildContext context) {
    HapticFeedback.lightImpact();
    context.pushNamedAuth(
      'TournamentDetails',
      context.mounted,
      pathParameters: {'tournamentId': tournamentRef.uid}.withoutNulls,
      extra: {'tournamentRef': tournamentRef.uid},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.all(_Dims.cardMargin),
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius:
                const BorderRadius.all(Radius.circular(_Dims.cardRadius)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(_Dims.cardPadding),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // FIX: fixed width replaces 15.w.
                _DateColumn(date: tournamentRef.date!),
                // FIX: Expanded replaces 50.w — fills all remaining space.
                Expanded(
                  child: _InfoColumn(
                    name: tournamentRef.name,
                    address: tournamentRef.address,
                    ownerId: tournamentRef.ownerId,
                    onMapTap: _openMap,
                    isOnline: tournamentRef.isOnlineEn,
                  ),
                ),
                // FIX: fixed width replaces 25.w.
                if (tournamentRef.game.iconResource != null)
                  _GameIcon(
                    asset: tournamentRef.game.iconResource!,
                    onTap: () => _navigateToDetail(context),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Date column ──────────────────────────────────────────────────────────────
class _DateColumn extends StatelessWidget {
  const _DateColumn({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    return SizedBox(
      // FIX: fixed constant replaces 15.w.
      width: _Dims.dateColWidth,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(DateFormat('dd').format(date), style: theme.titleLarge),
          Text(DateFormat('MM').format(date), style: theme.bodyMedium),
          Text(DateFormat('yyyy').format(date), style: theme.bodyMedium),
        ],
      ),
    );
  }
}

// ── Name / address / owner column ────────────────────────────────────────────
// FIX: explicit SizedBox(width: 50.w) removed — this widget now fills its
//   Expanded parent naturally.
class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.name,
    required this.address,
    required this.ownerId,
    required this.onMapTap,
    required this.isOnline,
  });

  final String name;
  final String address;
  final String ownerId;
  final VoidCallback onMapTap;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final labelStyle =
        theme.labelMedium.override(color: theme.primaryText);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
          _Dims.infoPaddingH, 0, _Dims.infoPaddingH, 0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: theme.bodyMedium),
          Divider(
            thickness: 1,
            color: theme.primaryText,
            height: _Dims.dividerHeight,
          ),
          RichText(
            text: TextSpan(
              style: labelStyle,
              children: [
                if (isOnline)
                  const TextSpan(text: 'Online')
                else ...[
                  TextSpan(text: address),
                  const TextSpan(text: '  '),
                  WidgetSpan(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.open_in_new,
                        color: theme.primaryText,
                        size: _Dims.mapIconSize,
                      ),
                      onPressed: onMapTap,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: theme.primaryText,
            height: _Dims.dividerHeight,
          ),
          Text(ownerId, style: labelStyle),
        ],
      ),
    );
  }
}

// ── Game icon ────────────────────────────────────────────────────────────────
class _GameIcon extends StatelessWidget {
  const _GameIcon({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // FIX: fixed constant replaces 25.w.
      width: _Dims.gameIconColWidth,
      child: InkWell(
        onTap: onTap,
        child: Image.asset(
          asset,
          width: _Dims.gameIconSize,
          height: _Dims.gameIconSize,
        ),
      ),
    );
  }
}
