import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';
import 'package:tournamentmanager/pages/core/tournament_decklist/tournament_decklist_container.dart';
import 'package:tournamentmanager/pages/core/tournament_pairings/tournament_pairings_container.dart';
import 'package:tournamentmanager/pages/core/tournament_rounds/tournament_rounds_container.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import '../../../pages/core/add_people/add_people_container.dart';
import '../../../pages/core/add_people/barcode_scanner_zoom.dart';
import '../../../pages/core/create_edit_news/create_edit_news_container.dart';
import '../../../pages/core/tournament_detail/tournament_detail_container.dart';
import '../../../pages/core/tournament_news/tournament_news_container.dart';
import '../../../pages/core/tournament_people/tournament_people_container.dart';
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
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
            return const TournamentDetailContainer();
          },
          routes: [
            GoRoute(
              name: 'DialogState',
              path: 'dialog-state',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogState'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogWaitingListPlayer',
              path: 'dialog-waitinglist-player',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogWaitingListPlayer'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogWaitingList',
              path: 'dialog-waiting-list',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogWaitingList'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogPreRegisterPlayer',
              path: 'dialog-preregister-player',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogPreRegisterPlayer'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogPreIscrizioni',
              path: 'dialog-pre-registration',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogPreIscrizioni'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogDeEnrollPlayer',
              path: 'dialog-deenroll-player',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogDeEnrollPlayer'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogChangeCapacity',
              path: 'dialog-change-capacity',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogChangeCapacity'});
                return DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogChangeTournamentName',
              path: 'dialog-change-tournament-name',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogChangeTournamentName'});
                return DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
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
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentRounds'});
            return const TournamentRoundsContainer();
          },
          routes: [
            CustomRoute(
                name: 'TournamentPairings',
                path: 'tournament-pairings/:roundId',
                parentNavigatorKey: NavigatorKeys.tournamentRoundKey,
                redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                builder: (context, params) {
                  logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPairings'});
                  return TournamentPairingsContainer(
                    roundIndex: params.getParam('roundId', ParamType.String),
                  );
                },
              routes: [
                CustomRoute(
                  name: 'TournamentRankings',
                  path: 'tournament-rankings',
                  parentNavigatorKey: NavigatorKeys.tournamentRoundKey,
                  redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                  builder: (context, params) {
                    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentRankings'});
                    return TournamentRankingsContainer(
                      roundIndex: params.getParam('roundId', ParamType.String,),
                    );
                  },
                ).toRoute(appStateNotifier),
              ],
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogGenerateRound',
              path: 'dialog-generate-round',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogGenerateRound'});
                return DialogPage(builder: (_) =>
                  ((state.extra as Map<String, dynamic>)['pageType'] as RoundKind) == RoundKind.swiss ?
                  DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],) :
                  DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],),);
              },
            ),
            GoRoute(
              name: 'DialogDeleteRound',
              path: 'dialog-delete-round',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogDeleteRound'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogCloseTournament',
              path: 'dialog-close-tournament',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogCloseTournament'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
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
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'Tournament People'});
            return const TournamentPeopleContainer();
          },
          routes: [
            CustomRoute(
              name: 'AddPeople',
              path: 'add-people',
              parentNavigatorKey: NavigatorKeys.tournamentPeopleKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'AddPeople'});
                return  AddPeopleContainer(
                  listType: params.getParam('listType', ParamType.String,),
                );
              },
              routes: [
                CustomRoute(
                  name: 'ScannerCode',
                  path: 'scanner',
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
                  builder: (context, params) {
                    logFirebaseEvent('screen_view', parameters: {'screen_name': 'BarcodeScannerWithZoom'});
                    return const BarcodeScannerWithZoom();
                  },
                ).toRoute(appStateNotifier),
              ]
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogDeletePerson',
              path: 'dialog-delete-person',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogDeletePerson'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
            GoRoute(
              name: 'DialogPromotePerson',
              path: 'dialog-promote-person',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogPromotePerson'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
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
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentNews'});
            return const TournamentNewsContainer();
          },
          routes: [
            CustomRoute(
              name: 'CreateEditNews',
              path: 'create-edit-news/:newsId',
              parentNavigatorKey: NavigatorKeys.tournamentNewsKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateEditNews'});
                return  CreateEditNewsContainer(
                  newsRef: params.getParam('newsId', ParamType.String,),
                  createEditFlag: params.getParam('createEditFlag', ParamType.bool,),
                );
              },
            ).toRoute(appStateNotifier),
            GoRoute(
              name: 'DialogDeleteNews',
              path: 'dialog-delete-news',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogDeleteNews'});
                return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
          ]
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentDecklistKey,
      routes: [
        CustomRoute(
            name: 'TournamentDecklist',
            path: 'tournament-decklist',
            redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
            builder: (context, params) {
              logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDecklist'});
              return const TournamentDecklistContainer();
            },
            routes: []
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
  ];
}