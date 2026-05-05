// no_content_card.dart

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';

// ---------------------------------------------------------------------------
// ENUM — encodes the icon asset for each use-case.
// Adding a new variant = one new enum value, zero new files.
// ---------------------------------------------------------------------------
enum NoContentType {
  tournament('assets/images/icons/empty-box.png'),
  news('assets/images/icons/news.png'),
  pairings('assets/images/icons/pairing.png'),
  people('assets/images/icons/player.png'),
  pick('assets/images/icons/empty-box.png'),
  rankings('assets/images/icons/ranking.png'),
  rounds('assets/images/icons/round.png');

  const NoContentType(this.asset);
  final String asset;
}

// ---------------------------------------------------------------------------
// VARIANT — controls container styling.
// Keeping this separate from NoContentType means you can freely mix
// a new icon with any existing visual style without a combinatorial explosion.
// ---------------------------------------------------------------------------
enum NoContentVariant {
  /// Original NoTournamentCard style — background fills the outer container
  /// and the inner card matches it (no visible border effect).
  flat,

  /// Standard bordered card — secondaryBackground / secondary swap on active.
  card,

  /// NoTournamentPickCard style — primary-colored pill with no active toggle.
  pill,
}

// ---------------------------------------------------------------------------
// WIDGET
// Pure StatelessWidget — no local state, no model file needed.
// ---------------------------------------------------------------------------
class NoContentCard extends StatelessWidget {
  const NoContentCard({
    super.key,
    required this.type,
    required this.phrase,
    this.active = true,
    this.variant = NoContentVariant.card,
  });

  final NoContentType type;
  final String phrase;

  /// Drives color swaps in [flat] and [card] variants.
  /// Ignored by [pill] since it has no active/inactive concept.
  final bool active;

  final NoContentVariant variant;

  @override
  Widget build(BuildContext context) {
    return switch (variant) {
      NoContentVariant.flat => _FlatCard(
          asset: type.asset,
          phrase: phrase,
          active: active,
        ),
      NoContentVariant.card => _BorderedCard(
          asset: type.asset,
          phrase: phrase,
          active: active,
        ),
      NoContentVariant.pill => _PillCard(
          asset: type.asset,
          phrase: phrase,
        ),
    };
  }
}

// ---------------------------------------------------------------------------
// PRIVATE — FLAT VARIANT  (formerly NoTournamentCardWidget)
// ---------------------------------------------------------------------------
class _FlatCard extends StatelessWidget {
  const _FlatCard({
    required this.asset,
    required this.phrase,
    required this.active,
  });

  final String asset;
  final String phrase;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? CustomFlowTheme.of(context).secondary
        : CustomFlowTheme.of(context).primaryBackground;

    return Container(
      color: bg,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        child: Container(
          width: 90.w,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: bg, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 32),
            child: _IconPhraseRow(
              asset: asset,
              phrase: phrase,
              style: active
                  ? CustomFlowTheme.of(context).bodySmall
                  : CustomFlowTheme.of(context).labelLarge,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE — BORDERED CARD VARIANT  (formerly News / Pairings / People /
//           Rankings / Rounds widgets — all identical except the asset)
// ---------------------------------------------------------------------------
class _BorderedCard extends StatelessWidget {
  const _BorderedCard({
    required this.asset,
    required this.phrase,
    required this.active,
  });

  final String asset;
  final String phrase;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90.w,
      decoration: BoxDecoration(
        color: active
            ? CustomFlowTheme.of(context).secondaryBackground
            : CustomFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: CustomFlowTheme.of(context).alternate,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(vertical: 20),
        child: _IconPhraseRow(
          asset: asset,
          phrase: phrase,
          spacing: 20,
          style: active
              ? CustomFlowTheme.of(context).labelLarge
              : CustomFlowTheme.of(context).bodySmall,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE — PILL VARIANT  (formerly NoTournamentPickCardWidget)
// ---------------------------------------------------------------------------
class _PillCard extends StatelessWidget {
  const _PillCard({
    required this.asset,
    required this.phrase,
  });

  final String asset;
  final String phrase;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.all(10),
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).primary,
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(5),
            child: _IconPhraseRow(
              asset: asset,
              phrase: phrase,
              mainAxisAlignment: MainAxisAlignment.start,
              style: CustomFlowTheme.of(context).bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE — SHARED ROW  (icon + text, extracted once used by all variants)
// ---------------------------------------------------------------------------
class _IconPhraseRow extends StatelessWidget {
  const _IconPhraseRow({
    required this.asset,
    required this.phrase,
    required this.style,
    this.spacing = 0,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final String asset;
  final String phrase;
  final TextStyle style;
  final double spacing;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        Image.asset(asset, height: 30.sp, fit: BoxFit.cover),
        if (spacing > 0) SizedBox(width: spacing),
        Flexible(
          child: Text(phrase, style: style, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
