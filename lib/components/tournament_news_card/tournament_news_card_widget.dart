// components/tournament_news_card/tournament_news_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';

/// Displays a news item with optional edit/delete slide actions.
/// [deleteFun] is owned by the parent — this widget never decides
/// what "delete" means, it only triggers the confirmation dialog.
class TournamentNewsCardWidget extends StatelessWidget {
  const TournamentNewsCardWidget({
    super.key,
    required this.newsRef,
    required this.index,
    required this.deleteFun,
    required this.interactable,
  });

  final NewsRecord newsRef;           // non-nullable: guard at call site
  final int index;
  final Future<void> Function(String newsId) deleteFun;
  final bool interactable;

  // ── AlertRequest builder (was TournamentNewsCardModel.showDeleteNewsAlertRequest)
  AlertRequest _deleteRequest() => AlertRequest(
        title: 'ATTENZIONE: Cancellazione della nota in corso...',
        description: 'Sei sicuro di voler eliminare questa Nota?',
        buttonTitleCancelled: 'Annulla',
        buttonTitleConfirmed: 'Continua',
        functionConfirmed: (_) => deleteFun(newsRef.uid),
      );

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Slidable(
        key: ValueKey('news$index'),
        endActionPane: interactable
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => context.pushNamedAuth(
                      'CreateEditNews',
                      context.mounted,
                      pathParameters: {
                        'newsId': newsRef.uid,
                        'tournamentId': newsRef.tournamentId,
                      }.withoutNulls,
                      extra: {'createEditFlag': false},
                    ),
                    backgroundColor: theme.accent1,
                    foregroundColor: theme.info,
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (_) => context.goNamed(
                      'DialogDeleteNews',
                      pathParameters: {
                        'tournamentId': newsRef.tournamentId,
                      }.withoutNulls,
                      extra: {'req': _deleteRequest()},
                    ),
                    backgroundColor: theme.error,
                    foregroundColor: theme.info,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              )
            : null,
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
                if (newsRef.showTimestampEn) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss')
                          .format(newsRef.createdTime),
                      style: theme.bodyMicro
                          .override(color: theme.cardDetail),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(newsRef.title,
                    style: theme.titleLarge.override(color: theme.cardMain)),
                Text(newsRef.subTitle,
                    style:
                        theme.titleMedium.override(color: theme.cardSecond)),
                if (newsRef.imageNews != null) ...[
                  const SizedBox(height: 10),
                  _NewsImage(url: newsRef.imageNews!, theme: theme),
                  const SizedBox(height: 10),
                ],
                Text(newsRef.description,
                    style: theme.bodySmall.override(color: theme.cardMain)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Network image with loading + error states ────────────────────────────────
// Extracted so the parent build method stays readable.
class _NewsImage extends StatelessWidget {
  const _NewsImage({required this.url, required this.theme});

  final String url;
  final CustomFlowTheme theme;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return CircularProgressIndicator(
          value: progress.expectedTotalBytes != null
              ? progress.cumulativeBytesLoaded /
                  progress.expectedTotalBytes!
              : null,
        );
      },
      errorBuilder: (_, __, ___) => Icon(
        Icons.error,
        color: CustomFlowTheme.of(context).error,
        size: 18,
      ),
    );
  }
}
