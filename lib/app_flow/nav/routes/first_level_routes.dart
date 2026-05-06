import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/pages/core/my_tournaments/my_tournaments_container.dart';
import 'package:tournamentmanager/pages/core/own_tournaments/own_tournaments_container.dart';
import 'package:tournamentmanager/pages/core/tournament_finder/tournament_finder_container.dart';
import 'package:tournamentmanager/pages/profile/profile/profile_container.dart';

import '../../../backend/firebase_analytics/analytics.dart';
import '../../../pages/core/create_own/create_own_container.dart';
import '../../../pages/nav_bar/scaffold_levelone_nested_navigation.dart';
import '../../../pages/profile/about_us/about_us_container.dart';
import '../../../pages/profile/edit_preferences/edit_preferences_container.dart';
import '../../../pages/profile/edit_profile/edit_profile_container.dart';
import '../../../pages/profile/support_center/support_center_container.dart';
import '../../app_flow_util.dart';
import '../../dialog_page.dart';
import '../navigation_keys.dart';
import '../route_config.dart';
import '../serialization_util.dart';

class FirstLevelRoutes {
  static Widget shellBuilder(BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
    return ScaffoldWithLevelOneNestedNavigation(navigationShell: navigationShell);
  }

  static List<StatefulShellBranch> getBranches(AppStateNotifier appStateNotifier) => [
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.dashboardKey,
      routes: [
        CustomRoute(
          name: 'Dashboard',
          path: 'dashboard',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'My_Tournaments'});
            return const MyTournamentsContainer();
          },
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.ownTournamentsKey,
      routes: [
        CustomRoute(
          name: 'OwnTournaments',
          path: 'own-tournaments',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'Own_Tournaments'});
            return const OwnTournamentsContainer();
          },
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.tournamentFinderKey,
      routes: [
        CustomRoute(
          name: 'TournamentFinder',
          path: 'tournament-finder',
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentFinder'});
            return const TournamentFinderContainer();
          },
          routes: [
            GoRoute(
              name: 'DialogChangeTournamentFinderSettings',
              path: 'dialog-change-tournament-finder-settings',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                if (state.extra == null) return '/';
                return RouteGuard.authGuard(appStateNotifier, context, state);
              },
              pageBuilder: (context, state) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogChangeTournamentFinderSettings'});
                return DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],));
              },
            ),
          ],
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
    StatefulShellBranch(
      navigatorKey: NavigatorKeys.profileKey,
      routes: [
        CustomRoute(
          name: 'Profile',
          path: 'profile',
          parentNavigatorKey: NavigatorKeys.profileKey,
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'Profile'});
            return const ProfileContainer();
          },
          routes: [
            CustomRoute(
              name: 'EditProfile',
              path: 'edit-profile',
              parentNavigatorKey: NavigatorKeys.profileKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'EditProfile'});
                return const EditProfileContainer();
              },
              routes: [
                GoRoute(
                  name: 'DialogDeleteAccount',
                  path: 'dialog-delete-account',
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  redirect: (context, state) {
                    if (state.extra == null) return '/';
                    return RouteGuard.authGuard(appStateNotifier, context, state);
                  },
                  pageBuilder: (context, state) {
                    logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogDeleteAccount'});
                    return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
                  },
                ),
                GoRoute(
                  name: 'DialogResetPassword',
                  path: 'dialog-reset-password',
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  redirect: (context, state) {
                    if (state.extra == null) return '/';
                    return RouteGuard.authGuard(appStateNotifier, context, state);
                  },
                  pageBuilder: (context, state) {
                    logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogResetPassword'});
                    return DialogPage(builder: (_) => DialogWidget(request: (state.extra as Map<String, dynamic>)['req'],));
                  },
                ),
                GoRoute(
                  name: 'DialogChangeMail',
                  path: 'dialog-change-mail',
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  redirect: (context, state) {
                    if (state.extra == null) return '/';
                    return RouteGuard.authGuard(appStateNotifier, context, state);
                  },
                  pageBuilder: (context, state) {
                    logFirebaseEvent('screen_view', parameters: {'screen_name': 'DialogChangeMail'});
                    return DialogPage(builder: (_) => DialogFormWidget(request: (state.extra as Map<String, dynamic>)['req'],));
                  },
                ),
              ],
            ),
            CustomRoute(
              name: 'AboutUs',
              path: 'about-us',
              parentNavigatorKey: NavigatorKeys.profileKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'AboutUs'});
                return const AboutUsContainer();
              },
            ),
            CustomRoute(
              name: 'SupportCenter',
              path: 'support-center',
              parentNavigatorKey: NavigatorKeys.profileKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'SupportCenter'});
                return const SupportCenterContainer();
              },
            ),
            CustomRoute(
              name: 'CreateOwn',
              path: 'create-own',
              parentNavigatorKey: NavigatorKeys.profileKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateOwn'});
                return const CreateOwnContainer();
              },
            ),
            CustomRoute(
              name: 'EditPreferences',
              path: 'edit-preferences',
              parentNavigatorKey: NavigatorKeys.profileKey,
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'EditPreferences'});
                return EditPreferencesContainer(
                  page: params.getParam('page', ParamType.int),
                );
              },
            ),
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    ),
  ];
}