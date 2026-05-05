// components/tournament_pick_card/tournament_pick_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/ExternalAppManagerService.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';

/// Compact tournament card used in pick/selection lists.
/// Tapping the game icon navigates to TournamentDetails.
/// Tapping the address icon launches the external map app.
class TournamentPickCardWidget extends StatelessWidget {
  const TournamentPickCardWidget({
    super.key,
    required this.tournamentRef,
  });

  final TournamentsRecord tournamentRef; // non-nullable: guard at call site

  // Resolving from GetIt inline is fine for a stateless service call.
  // If this widget is ever tested in isolation, inject via constructor instead.
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
          margin: const EdgeInsetsDirectional.all(10),
          decoration: BoxDecoration(
            color: theme.primary,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _DateColumn(date: tournamentRef.date!),
                _InfoColumn(
                  name: tournamentRef.name,
                  address: tournamentRef.address,
                  ownerId: tournamentRef.ownerId,
                  onMapTap: _openMap,
                ),
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
      width: 15.w,
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
class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.name,
    required this.address,
    required this.ownerId,
    required this.onMapTap,
  });

  final String name;
  final String address;
  final String ownerId;
  final VoidCallback onMapTap;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    final labelStyle =
        theme.labelMedium.override(color: theme.primaryText);

    return SizedBox(
      width: 50.w,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: theme.bodyMedium),
            Divider(
                thickness: 1, color: theme.primaryText, height: 10),
            // Address + map launcher inline via RichText + WidgetSpan
            RichText(
              text: TextSpan(
                style: labelStyle,
                children: [
                  TextSpan(text: address),
                  const TextSpan(text: '  '),
                  WidgetSpan(
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: Icon(Icons.open_in_new,
                          color: theme.primaryText, size: 18),
                      onPressed: onMapTap,
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                thickness: 1, color: theme.primaryText, height: 10),
            Text(ownerId, style: labelStyle),
          ],
        ),
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
      width: 25.w,
      child: InkWell(
        onTap: onTap,
        child: Image.asset(asset, width: 70, height: 70),
      ),
    );
  }
}
