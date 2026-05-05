// components/title_with_subtitle/title_with_subtitle_widget.dart

import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';

/// Displays a two-line header: a bold title and a muted subtitle.
/// Purely presentational — no state, no model needed.
class TitleWithSubtitleWidget extends StatelessWidget {
  const TitleWithSubtitleWidget({
    super.key,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 32, 0, 4),
          child: Text(
            valueOrDefault<String>(title, 'Test title'),
            style: theme.bodyMedium.override(fontSize: 16),
          ),
        ),
        Text(
          valueOrDefault<String>(subtitle, 'Test subtitle'),
          style: theme.labelMedium,
        ),
      ].divide(const SizedBox(height: 4)),
    );
  }
}
