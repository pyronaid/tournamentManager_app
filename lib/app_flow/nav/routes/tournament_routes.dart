import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../pages/core/add_people/add_people_container.dart';
import '../../../pages/core/add_people/barcode_scanner_zoom.dart';
import '../../../pages/core/create_edit_news/create_edit_news_container.dart';
import '../../../pages/core/tournament_detail/tournament_detail_container.dart';
import '../../../pages/core/tournament_news/tournament_news_container.dart';
import '../../../pages/core/tournament_people/tournament_people_model.dart';
import '../../../pages/core/tournament_people/tournament_people_widget.dart';
import '../../../pages/nav_bar/scaffold_leveltwo_nested_navigation.dart';
import '../../../pages/nav_bar/tournament_model.dart';
import '../../app_flow_util.dart';
import '../navigation_keys.dart';
import '../route_config.dart';
import '../serialization_util.dart';

class TournamentRoutes {
  static Widget shellBuilder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
    final tournamentId = state.pathParameters['tournamentId'];

    return ChangeNotifierProvider(
      create: (context) => TournamentModel(tournamentsRef: tournamentId)..fetchObjectUsingId(),
      child: ScaffoldWithLevelTwoNestedNavigation(navigationShell: navigationShell,)
    );
  }

  static List<StatefulShellBranch> getBranches(AppStateNotifier appStateNotifier) => [
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentDetailsKey,
      routes: [
        CustomRoute(
          name: 'TournamentDetails',
          path: 'tournament-dets',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) => const TournamentDetailContainer(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentPeopleKey,
      routes: [
        CustomRoute(
          name: 'TournamentPeople',
          path: 'tournament-people',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) => const TournamentPeopleWidget(),
          routes: [
            CustomRoute(
              name: 'AddPeople',
              path: 'add-people',
              parentNavigatorKey: NavigatorKeys.tournamentPeopleKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) => MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: (params.state.extra as Map<String, dynamic>)["provider"] as TournamentPeopleModel,
                  ),
                ],
                child: AddPeopleContainer(
                  listType: params.getParam('listType', ParamType.String,),
                ),
              ),
              routes: [
                CustomRoute(
                  name: 'ScannerCode',
                  path: 'scanner',
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                  builder: (context, params) => const BarcodeScannerWithZoom(),
                ).toRoute(appStateNotifier),
              ]
            ),
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentNewsKey,
      routes: [
        CustomRoute(
          name: 'TournamentNews',
          path: 'tournament-news',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) => const TournamentNewsContainer(),
          routes: [
            CustomRoute(
              name: 'CreateEditNews',
              path: 'create-edit-news/:newsId',
              parentNavigatorKey: NavigatorKeys.tournamentNewsKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) =>  MultiProvider(
                providers: [
                  ChangeNotifierProvider.value(
                    value: (params.state.extra as Map<String, dynamic>)["provider"] as TournamentModel,
                  ),
                ],
                child: CreateEditNewsContainer(
                  newsRef: params.getParam('newsId', ParamType.String,),
                  createEditFlag: params.getParam('createEditFlag', ParamType.bool,),
                ),
              ),
            ),
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
  ];
}