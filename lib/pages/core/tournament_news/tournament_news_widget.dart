import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/news_record.dart';
import 'package:tournamentmanager/components/tournament_news_card/tournament_news_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_news/tournament_news_model.dart';

import '../../../components/generic_loading/generic_loading_widget.dart';
import '../../../components/no_tournament_news_card/no_tournament_news_card_widget.dart';


class TournamentNewsWidget extends StatefulWidget {
  const TournamentNewsWidget({super.key});

  @override
  State<TournamentNewsWidget> createState() => _TournamentNewsWidgetState();
}


class _TournamentNewsWidgetState extends State<TournamentNewsWidget> {

  late TournamentNewsModel tournamentNewsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentNewsModel = context.read<TournamentNewsModel>();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentNewsModel>(
        builder: (context, providerTournamentNews, _) {
          print("[BUILD IN CORSO] tournament_news_widget.dart");
          if (providerTournamentNews.isLoading) {
            return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomFlowTheme.of(context).primaryBackground,
              body: const SafeArea(
                top: true,
                child: SingleChildScrollView(
                  child: Center(child: CircularProgressIndicator())
                ),
              ),
            );
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
                    'tournamentId': providerTournamentNews.tournamentModel.tournamentsRef,
                  }.withoutNulls,
                  extra: {
                    'createEditFlag': true,
                    'provider': providerTournamentNews.tournamentModel,
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
              child: RefreshIndicator(
                onRefresh: () async {
                  await providerTournamentNews.onRefresh();
                },
                child: CustomScrollView(
                  slivers: [
                    // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                    ////////////////
                    //NEWS SECTION HEADER
                    /////////////////


                    ////////////////
                    //NEWS SECTION INF LIST
                    /////////////////
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                      sliver: PagedSliverList<String?, NewsRecord>(
                        pagingController: providerTournamentNews.pagingControllerNews,
                        builderDelegate: PagedChildBuilderDelegate<NewsRecord>(
                          itemBuilder: (context, item, index) => TournamentNewsCardWidget(
                            key: Key('Keykia_${item.uid}_position_${index}_of_news'),
                            //last: index == (providerMyTournaments.pagingControllerActive.itemList!.length - 1),
                            newsRef: item,
                            indexo: index,
                            deleteFun: (newsId) => providerTournamentNews.deleteNews(newsId),
                          ),
                          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                          noItemsFoundIndicatorBuilder: (_) => const NoTournamentNewsCardWidget(
                            active: true,
                            phrase: "Nessuna notizia pubblicata",
                          ),
                          newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                        ),
                        shrinkWrapFirstPageIndicators: true,
                      ),
                    ),

                    ////////////////
                    //NEWS SECTION END
                    /////////////////
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                        width: 100.w,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}