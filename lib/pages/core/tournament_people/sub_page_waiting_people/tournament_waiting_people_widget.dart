import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_waiting_people/tournament_waiting_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../../../../app_flow/app_flow_widgets.dart';
import '../../../../backend/firebase_analytics/analytics.dart';
import '../../../../components/generic_loading/generic_loading_widget.dart';
import '../../../../components/no_tournament_people_card/no_tournament_people_card_widget.dart';
import '../../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../../components/tournament_people_card/tournament_people_card_widget.dart';

class TournamentWaitingPeopleWidget extends StatefulWidget {
  const TournamentWaitingPeopleWidget({super.key});

  @override
  State<TournamentWaitingPeopleWidget> createState() => _TournamentWaitingPeopleWidgetState();
}


class _TournamentWaitingPeopleWidgetState extends State<TournamentWaitingPeopleWidget> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPeopleWaiting'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
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
      child: Consumer<TournamentWaitingPeopleModel>(builder: (context, providerWaitingPeople, _) {
        print("[BUILD IN CORSO] tournament_waiting_people_widget.dart");
        if (providerWaitingPeople.isLoading) {
          return Scaffold(
              key: _scaffoldKey,
              backgroundColor: CustomFlowTheme.of(context).primaryBackground,
              body: const SafeArea(
                  top: true,
                  child: Center(child: CircularProgressIndicator()))
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: CustomFlowTheme.of(context).primaryBackground,
          body: SafeArea(
              top: true,
              child: RefreshIndicator(
                onRefresh: () async {
                  await providerWaitingPeople.onRefresh();
                },
                child: CustomScrollView(
                  slivers: [
                    // use sliver padding if needed https://api.flutter.dev/flutter/widgets/SliverPadding-class.html

                    ////////////////
                    //TEXT INPUT AND ADD BUTTON
                    //INFINITE LIST COUNTER
                    /////////////////
                    SliverAppBar(
                      pinned: true,
                      snap: false,
                      floating: false,
                      expandedHeight: 200.0,
                      collapsedHeight: 200.0,
                      backgroundColor: CustomFlowTheme.of(context).secondary,
                      flexibleSpace: Padding(
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 65.w,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 5),
                                    child: TextField(
                                      controller: providerWaitingPeople.peopleNameTextController,
                                      focusNode: providerWaitingPeople.peopleNameFocusNode,
                                      autofocus: false,
                                      obscureText: false,
                                      decoration: standardInputDecoration(
                                        context,
                                        prefixIcon: Icon(
                                          Icons.person,
                                          color: CustomFlowTheme.of(context).secondaryText,
                                          size: 18,
                                        ),
                                      ),
                                      style: CustomFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                      ),
                                      minLines: 1,
                                      cursorColor: CustomFlowTheme.of(context).primary,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: AFButtonWidget(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      logFirebaseEvent('Button_load_pic');
                                      context.pushNamedAuth(
                                        'AddPeople', context.mounted,
                                        pathParameters: {
                                          'tournamentId': providerWaitingPeople.tournamentModel.tournamentId,
                                        }.withoutNulls,
                                        extra: {
                                          'listType' : ListType.waiting.name,
                                          'provider' : providerWaitingPeople
                                        },
                                      );
                                      logFirebaseEvent('Button_haptic_feedback');
                                      HapticFeedback.lightImpact();
                                    },
                                    text: '',
                                    icon: const Icon(Icons.add_circle,),
                                    options: AFButtonOptions(
                                      width: 50,
                                      height: 50,
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      iconColor: Colors.white,
                                      iconSize: 14,
                                      color:  CustomFlowTheme.of(context).primary,
                                      textStyle: CustomFlowTheme.of(context).labelLarge.override(
                                        color: CustomFlowTheme.of(context).info,
                                        fontSize: 0,
                                      ),
                                      elevation: 0,
                                      borderSide: const BorderSide(
                                        color: Colors.transparent,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: CustomFlowTheme.of(context).secondaryBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: CustomFlowTheme.of(context).alternate,
                                    width: 1,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.all(10),
                                  child: Text(
                                    'In lista d\'attesa: ${providerWaitingPeople.countElements}',
                                    style: CustomFlowTheme.of(context).labelLarge,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    ////////////////
                    //PEOPLE SECTION INF LIST
                    /////////////////
                    SliverPadding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
                      sliver: PagedSliverList<String?, EnrollmentsRecord> (
                        pagingController: providerWaitingPeople.pagingController,
                        builderDelegate: PagedChildBuilderDelegate<EnrollmentsRecord>(
                          itemBuilder: (context, item, index) => TournamentPeopleCardWidget(
                            key: Key('Keykia_${item.uid}_position_${index}_of_people'),
                            userRef: item,
                            indexo: index,
                            listType: ListType.waiting,
                            peopleModel: providerWaitingPeople,
                            promote: true,
                            tournamentRef: providerWaitingPeople.tournamentModel.tournamentId!,
                          ),
                          firstPageProgressIndicatorBuilder: (_) => const GenericLoadingWidget(),
                          noItemsFoundIndicatorBuilder: (_) => const NoTournamentPeopleCardWidget(
                            active: true,
                            phrase: "Nessun iscritto in questa lista",
                          ),
                          newPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator()),
                        ),
                        shrinkWrapFirstPageIndicators: true,
                      ),
                    ),
                  ],
                ),
              )
          ),
        );
      }),
    );
  }
}