import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/components/tournament_card/tournament_card_model.dart';

import '../../app_flow/app_flow_animations.dart';
import '../../app_flow/app_flow_theme.dart';
import '../../pages/nav_bar/tournament_model.dart';
import '../standard_graphics/standard_graphics_widgets.dart';

class TournamentNewsCardWidget extends StatefulWidget {

  const TournamentNewsCardWidget({
    super.key,
    required this.newsRef, required this.indexo,
  });

  final NewsRecord? newsRef;
  final int indexo;

  @override
  State<TournamentNewsCardWidget> createState() => _TournamentNewsCardWidgetState();
}

class _TournamentNewsCardWidgetState extends State<TournamentNewsCardWidget> with TickerProviderStateMixin {
  late TournamentNewsCardModel _model;

  final animationsMap = <String, AnimationInfo>{};

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentNewsCardModel());

    animationsMap.addAll({
      'iconOnPageLoadAnimation': standardAnimationCard(context),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ValueKey(widget.indexo),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context){
                context.pushNamedAuth(
                  'CreateEditNews', context.mounted,
                  pathParameters: {
                    'newsId': widget.newsRef!.uid,
                  }.withoutNulls,
                  extra: {
                    'tournamentId': widget.newsRef!.tournamentUid,
                    'createEditFlag': false,
                  },
                );
              },
              backgroundColor: CustomFlowTheme.of(context).accent1,
              foregroundColor: CustomFlowTheme.of(context).info,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context){
                _showDeleteNewsDialog(context, widget.newsRef!.uid);
              },
              backgroundColor: CustomFlowTheme.of(context).error,
              foregroundColor: CustomFlowTheme.of(context).info,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          width: 1000,
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).tertiary,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(widget.newsRef!.showTimestampEn && widget.newsRef!.timestamp != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormat('dd/MM/yyyy HH:mm:ss').format(widget.newsRef!.timestamp!),
                      style: CustomFlowTheme.of(context).bodyMicro.override(color: CustomFlowTheme.of(context).cardDetail),
                    )
                  ),
                  const SizedBox(height: 10),
                ],

                Text(
                  widget.newsRef!.title,
                  style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).cardMain),
                ),
                Text(
                  widget.newsRef!.subTitle,
                  style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardSecond),
                ),

                if(widget.newsRef!.imageNewsUrl != null) ...[
                  const SizedBox(height: 10),
                  Image.network(
                    widget.newsRef!.imageNewsUrl!,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child; // Image has fully loaded
                      } else {
                        return CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null, // Shows a progress indicator if the loading size is known
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.error,
                        color: CustomFlowTheme.of(context).error,
                        size: 18,
                      ); // Display an error icon if the image fails to load
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                Text(
                  widget.newsRef!.description,
                  style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////// FUNCTIONS
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
Future<void> _showDeleteNewsDialog(BuildContext context, String newsId) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (contextDialog) {
      var tournamentModel = context.read<TournamentModel>();
      return AlertDialog(
        title: Text(
          'Attenzione',
          style: CustomFlowTheme.of(context).displaySmall.override(color: CustomFlowTheme.of(context).error),
        ),
        content: Text(
          "Sei sicuro di voler eliminare questa Nota? ",
          style: CustomFlowTheme.of(context).labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(contextDialog).pop(); // Dismiss the dialog
            },
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle saving the new value
              tournamentModel.deleteNews(newsId);
              Navigator.of(contextDialog).pop(); // Dismiss the dialog
            },
            child: const Text('Continua',),
          ),
        ],
      );
    }
  );
}