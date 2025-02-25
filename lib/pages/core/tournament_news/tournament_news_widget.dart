import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/no_tournament_news_card/no_tournament_news_card_widget.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';
import 'package:tournamentmanager/pages/nav_bar/news_list_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';


class TournamentNewsWidget extends StatefulWidget {
  const TournamentNewsWidget({super.key});

  @override
  State<TournamentNewsWidget> createState() => _TournamentNewsWidgetState();
}


class _TournamentNewsWidgetState extends State<TournamentNewsWidget> {

  late TournamentNewsModel tournamentNewsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentNewsModel = context.read<TournamentNewsModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tournamentNewsModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(tournamentNewsModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<NewsListModel>(
          builder: (context, providerNewsList, _) {
            print("[BUILD IN CORSO] tournament_news_widget.dart");
            if (providerNewsList.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomFlowTheme.of(context).primaryBackground,
              floatingActionButton: FloatingActionButton(
                heroTag: 'news_add',
                backgroundColor: CustomFlowTheme.of(context).primary,
                onPressed: (){
                  context.pushNamedAuth(
                    'CreateEditNews', context.mounted,
                    pathParameters: {
                      'newsId': 'NEW',
                      'tournamentId': providerNewsList.tournamentsRef,
                    }.withoutNulls,
                    extra: {
                      'createEditFlag': true,
                      'provider': providerNewsList.model,
                    },
                  );
                },
                child: Icon(
                  Icons.add,
                  color: CustomFlowTheme.of(context).info,
                ),
              ),
              body: SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: 100.w,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(providerNewsList.newsListRefObj.isEmpty)
                            const NoTournamentNewsCardWidget(
                              active: true,
                              phrase: "Nessuna notizia pubblicata",
                            )
                          else
                            Column(
                              children: List.generate(providerNewsList.newsListRefObj.length, (index) {
                                  final news = providerNewsList.newsListRefObj[index];
                                  return TournamentNewsCardWidget(
                                    key: Key('Keykia_${news.uid}_position_${index}_of_${providerNewsList.newsListRefObj.length}'),
                                    newsRef: news,
                                    indexo: index,
                                    deleteFun: (newsId) => providerNewsList.deleteNews(newsId),
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}