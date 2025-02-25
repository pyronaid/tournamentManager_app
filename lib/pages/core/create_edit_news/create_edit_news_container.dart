import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/pages/core/create_edit_news/create_edit_news_model.dart';
import 'package:tournamentmanager/pages/core/create_edit_news/create_edit_news_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/news_model.dart';

import '../../nav_bar/tournament_model.dart';

class CreateEditNewsContainer extends StatefulWidget {
  const CreateEditNewsContainer({
    super.key,
    required this.newsRef,
    required this.createEditFlag,
  });

  final String? newsRef;
  final bool createEditFlag;

  @override
  State<CreateEditNewsContainer> createState() => _CreateEditNewsContainerState();
}

class _CreateEditNewsContainerState extends State<CreateEditNewsContainer> {
  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateEditNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [
        ChangeNotifierProxyProvider<TournamentModel, NewsModel>(
          create: (context) => NewsModel(
            // Retrieve tournament provider from widget tree
            tournamentModel: context.read<TournamentModel>(),
            newsRef: widget.newsRef
          )..fetchObjectUsingId(),
          update: (context, tournamentModel, previousNewsModel) {
            // Optional update method
            if (previousNewsModel == null) {
              return NewsModel(
                tournamentModel: tournamentModel,
                newsRef: widget.newsRef
              )..fetchObjectUsingId();
            }
            return previousNewsModel;
          },
        ),
        ChangeNotifierProvider<CreateEditNewsModel>(
          create: (context) => CreateEditNewsModel(saveWay: widget.createEditFlag),
        ),
      ],
      builder: (context, child) {
        return const CreateEditNewsWidget();
      },
    );

  }
}
