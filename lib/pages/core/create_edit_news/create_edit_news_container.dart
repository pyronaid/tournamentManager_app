import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/create_edit_news/create_edit_news_model.dart';
import 'package:tournamentmanager/pages/core/create_edit_news/create_edit_news_widget.dart';
import 'package:tournamentmanager/pages/nav_bar/news_model.dart';

import '../../nav_bar/tournament_model.dart';

class CreateEditNewsContainer extends StatelessWidget  {
  const CreateEditNewsContainer({
    super.key,
    required this.newsRef,
    required this.createEditFlag,
  });

  final String? newsRef;
  final bool createEditFlag;

  @override
  Widget build(BuildContext context) {
    // TournamentModel is already in the tree from the shell's builder —
    // no need to re-inject it via extra/ChangeNotifierProvider.value.
    final tournamentModel = context.read<TournamentModel>();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<NewsModel>(
          create: (_) => NewsModel(
            tournamentModel: tournamentModel,
            newsRef: newsRef,
          )..fetchObjectUsingId(),
        ),
        ChangeNotifierProxyProvider<NewsModel, CreateEditNewsModel>(
          create: (innerContext) => CreateEditNewsModel(saveWay: createEditFlag, newsModel: innerContext.read<NewsModel>(),),
          update: (_, __, previous) => previous!,
        ),
      ],
      child: const CreateEditNewsWidget(),
    );
  }
}