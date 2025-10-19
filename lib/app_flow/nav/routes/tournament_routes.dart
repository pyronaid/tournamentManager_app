import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_container.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_container.dart';

import '../../../pages/core/add_people/add_people_container.dart';
import '../../../pages/core/add_people/barcode_scanner_zoom.dart';
import '../../../pages/core/create_edit_news/create_edit_news_container.dart';
import '../../../pages/core/tournament_detail/tournament_detail_container.dart';
import '../../../pages/core/tournament_news/tournament_news_container.dart';
import '../../../pages/core/tournament_people/tournament_people_container.dart';
import '../../../pages/core/tournament_people/tournament_people_model.dart';
import '../../../pages/core/tournament_rankings/tournament_rankings_container.dart';
import '../../../pages/nav_bar/scaffold_leveltwo_nested_navigation.dart';
import '../../../pages/nav_bar/tournament_model.dart';
import '../../app_flow_util.dart';
import '../../dialog_page.dart';
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
          routes: [
            GoRoute(
              name: 'DialogState',
              path: 'dialog-state',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogWaitingList',
              path: 'dialog-waiting-list',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogPreIscrizioni',
              path: 'dialog-pre-registration',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogChangeCapacity',
              path: 'dialog-change-capacity',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogChangeTournamentName',
              path: 'dialog-change-tournament-name',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
          ]
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentRoundKey,
      routes: [
        CustomRoute(
          name: 'TournamentRounds',
          path: 'tournament-rounds',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) => const TournamentRoundsContainer(),
          routes: [
            CustomRoute(
                name: 'TournamentPairings',
                path: 'tournament-pairings',
                parentNavigatorKey: NavigatorKeys.tournamentRoundKey,
                redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                builder: (context, params) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider.value(
                      value: (params.state.extra as Map<String, dynamic>)["provider"] as TournamentModel,
                    ),
                  ],
                  child: TournamentPairingsContainer(
                    roundIndex: params.getParam('roundId', ParamType.String,),
                  ),
                ),
              routes: [
                CustomRoute(
                  name: 'TournamentRankings',
                  path: 'tournament-rankings',
                  parentNavigatorKey: NavigatorKeys.tournamentRoundKey,
                  redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                  builder: (context, params) =>  MultiProvider(
                    providers: [
                      ChangeNotifierProvider.value(
                        value: (params.state.extra as Map<String, dynamic>)["provider"] as TournamentModel,
                      ),
                    ],
                    child: TournamentRankingsContainer(
                      roundId: params.getParam('roundId', ParamType.String,),
                    ),
                  ),
                ).toRoute(appStateNotifier),
              ],
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogGenerateRound',
              path: 'dialog-generate-round',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogDeleteRound',
              path: 'dialog-delete-round',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
          ],
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
          builder: (context, params) => const TournamentPeopleContainer(),
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
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogDeletePerson',
              path: 'dialog-delete-person',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
            GoRoute(
              name: 'DialogPromotePerson',
              path: 'dialog-promote-person',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
          ],
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
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogDeleteNews',
              path: 'dialog-delete-news',
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              pageBuilder: (context, state) => DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],)),
            ),
          ]
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
  ];
}