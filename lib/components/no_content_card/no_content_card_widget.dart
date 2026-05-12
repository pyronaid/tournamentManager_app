// no_content_card.dart
/*
// BEFORE — 7 different widgets
NoTournamentCardWidget(active: true, phrase: 'Nessun torneo trovato')
NoTournamentNewsCardWidget(active: false, phrase: 'Nessun aggiornamento')
NoTournamentPairingsCardWidget(active: true, phrase: 'Nessun abbinamento')
NoTournamentPeopleCardWidget(active: true, phrase: 'Nessuna persona')
NoTournamentPickCardWidget(phrase: 'Seleziona un torneo')
NoTournamentRankingsCardWidget(active: false, phrase: 'Nessuna classifica')
NoTournamentRoundsCardWidget(active: true, phrase: 'Nessun round')

// AFTER — one widget, self-documenting via enum
NoContentCard(type: NoContentType.tournament, phrase: 'Nessun torneo trovato', active: true)
NoContentCard(type: NoContentType.news,       phrase: 'Nessun aggiornamento',  active: false)
NoContentCard(type: NoContentType.pairings,   phrase: 'Nessun abbinamento',    active: true)
NoContentCard(type: NoContentType.people,     phrase: 'Nessuna persona',       active: true)
NoContentCard(type: NoContentType.pick,       phrase: 'Seleziona un torneo',   variant: NoContentVariant.pill)
NoContentCard(type: NoContentType.rankings,   phrase: 'Nessuna classifica',    active: false)
NoContentCard(type: NoContentType.rounds,     phrase: 'Nessun round',          active: true)
*/

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';

// ---------------------------------------------------------------------------
// DIMENSION CONSTANTS
//
// FIX 1: `90.w` (90% of screen width) on container widths in _FlatCard and
//   _BorderedCard.  A percentage width is the wrong tool here because the
//   cards are always rendered inside a sliver/scroll view that already
//   constrains the width.  `double.infinity` fills the available width
//   correctly on every screen size without any package dependency.
//
// FIX 2: `30.sp` (scaled pixels) on the icon image height in _IconPhraseRow.
//   sp is a text-scaling unit — using it for an image height means the icon
//   grows/shrinks with the user's system font size, which is semantically
//   wrong.  A fixed dp value is correct for an icon.
// ---------------------------------------------------------------------------
abstract class _Dims {
  /// Icon image size — fixed dp, not scaled with font size.
  static const double iconSize         = 28.0;

  /// Inner vertical padding of the bordered card variant.
  static const double cardPaddingV     = 20.0;

  /// Padding around the pill container content.
  static const double pillPaddingAll   = 5.0;

  /// Outer margin around the pill container.
  static const double pillMarginAll    = 10.0;

  /// Corner radius of the pill container.
  static const double pillRadius       = 20.0;

  /// Horizontal padding inside the flat card inner container.
  static const double flatCardPaddingH = 24.0;

  /// Vertical padding inside the flat card inner container.
  static const double flatCardPaddingT = 16.0;
  static const double flatCardPaddingB = 32.0;

  /// Corner radius shared by flat and bordered card variants.
  static const double cardRadius       = 8.0;

  /// Border width for the bordered card variant.
  static const double cardBorderWidth  = 1.0;
}

// ---------------------------------------------------------------------------
// ENUMS
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

enum NoContentVariant { flat, card, pill }

// ---------------------------------------------------------------------------
// ROOT WIDGET
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
// FLAT VARIANT
//
// FIX: inner Container `width: 90.w` replaced with `width: double.infinity`.
//   The card is always inside a sliver/scroll view that already constrains
//   the available width — double.infinity fills it correctly on every device.
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
        padding: const EdgeInsetsDirectional.fromSTEB(
            _Dims.flatCardPaddingH, 0, _Dims.flatCardPaddingH, 0),
        child: Container(
          // FIX: double.infinity replaces 90.w.
          width: double.infinity,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(_Dims.cardRadius),
            border: Border.all(color: bg, width: _Dims.cardBorderWidth),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(
              _Dims.flatCardPaddingH,
              _Dims.flatCardPaddingT,
              _Dims.flatCardPaddingH,
              _Dims.flatCardPaddingB,
            ),
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
// BORDERED CARD VARIANT
//
// FIX: `width: 90.w` replaced with `width: double.infinity`.
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
      // FIX: double.infinity replaces 90.w.
      width: double.infinity,
      decoration: BoxDecoration(
        color: active
            ? CustomFlowTheme.of(context).secondaryBackground
            : CustomFlowTheme.of(context).secondary,
        borderRadius: BorderRadius.circular(_Dims.cardRadius),
        border: Border.all(
          color: CustomFlowTheme.of(context).alternate,
          width: _Dims.cardBorderWidth,
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
            vertical: _Dims.cardPaddingV),
        child: _IconPhraseRow(
          asset: asset,
          phrase: phrase,
          spacing: _Dims.cardPaddingV,
          style: active
              ? CustomFlowTheme.of(context).labelLarge
              : CustomFlowTheme.of(context).bodySmall,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PILL VARIANT
// ---------------------------------------------------------------------------
class _PillCard extends StatelessWidget {
  const _PillCard({required this.asset, required this.phrase});

  final String asset;
  final String phrase;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.all(_Dims.pillMarginAll),
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).primary,
            borderRadius:
                const BorderRadius.all(Radius.circular(_Dims.pillRadius)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(_Dims.pillPaddingAll),
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
// SHARED ROW
//
// FIX: `Image.asset(height: 30.sp)` replaced with `height: _Dims.iconSize`.
//   sp is for text scaling — using it for an image height causes the icon to
//   grow/shrink with the system font size setting, which is semantically wrong.
//   A fixed dp value is correct for an icon that should always appear the
//   same physical size regardless of accessibility settings.
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
        // FIX: height: 30.sp → _Dims.iconSize (fixed dp).
        Image.asset(asset, height: _Dims.iconSize, fit: BoxFit.contain),
        if (spacing > 0) SizedBox(width: spacing),
        Flexible(
          child: Text(phrase, style: style, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
