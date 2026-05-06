import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/app_flow/nav/routes/auth_routes.dart';
import 'package:tournamentmanager/app_flow/nav/routes/first_level_routes.dart';
import 'package:tournamentmanager/app_flow/nav/routes/tournament_routes.dart';
import 'package:tournamentmanager/pages/onboarding/loading/loading_container.dart';

import '../../backend/firebase_analytics/analytics.dart';
import '../../pages/onboarding/splash/splash_container.dart';
import 'nav_basics.dart';
import 'navigation_keys.dart';

class RouteConfig {
  static GoRouter createRouter(AppStateNotifier appStateNotifier) {
    GoRouter.optionURLReflectsImperativeAPIs=true;
    return GoRouter(
      navigatorKey: NavigatorKeys.rootNavigator,
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      redirect: (context, state) {
        if (appStateNotifier.loading) {
          return '/loading';
        }

        // Get the current location
        final currentLocation = state.matchedLocation;

        // Check if we're at the initial route
        if (currentLocation == '/loading') {
          if (appStateNotifier.loggedIn) {
            if (appStateNotifier.emailVerified) {
              return '/dashboard';
            }
            return '/onboarding-verify-mail';
          }
          return '/splash';
        }


        return null;
      },
      routes: [
        // Initial route that handles authentication state
        CustomRoute(
          name: '_initialize',
          path: '/',
          parentNavigatorKey: NavigatorKeys.rootNavigator,
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'Splash'});
            return const SplashContainer();
          },
          routes: [
            CustomRoute(
              name: 'Splash',
              path: 'splash',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'Splash'});
                return const SplashContainer();
              },
            ).toRoute(appStateNotifier),

            CustomRoute(
              name: 'Loading',
              path: 'loading',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              builder: (context, params) {
                logFirebaseEvent('screen_view', parameters: {'screen_name': 'Loading'});
                return const LoadingContainer();
              },
            ).toRoute(appStateNotifier),

            // Authentication related routes
            ...AuthRoutes.getRoutes(appStateNotifier),

            // First level app navigation structure
            StatefulShellRoute.indexedStack(
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              builder: FirstLevelRoutes.shellBuilder,
              branches: FirstLevelRoutes.getBranches(appStateNotifier),
            ),

            // Tournament details navigation
            CustomRoute(
              name: 'TournamentBase',
              path: ':tournamentId',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              redirect: (context, state) {
                final authCheck = RouteGuard.authGuard(appStateNotifier, context, state);
                if (authCheck != null) return authCheck;

                final tournamentId = state.pathParameters['tournamentId'];
                final currentPath = state.uri.path;
                if (tournamentId != null && currentPath == '/$tournamentId') {
                  return '/$tournamentId/tournament-dets';
                }

                return null;
              },
              builder: (context, params) => const SizedBox.shrink(),
              routes: [
                StatefulShellRoute.indexedStack(
                  parentNavigatorKey: NavigatorKeys.rootNavigator,
                  builder: TournamentRoutes.shellBuilder,
                  branches: TournamentRoutes.getBranches(appStateNotifier),
                ),
              ]
            ).toRoute(appStateNotifier),
          ],
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );
  }
}


class RouteGuard {
  static String? authGuard(AppStateNotifier appStateNotifier, BuildContext context, GoRouterState state) {
    // Global loading check
    if (appStateNotifier.loading) {
      return '/splash';
    }

    // Authentication check
    if (!appStateNotifier.loggedIn) {
      return '/sign-in';
    }

    // Email verification check
    if (!appStateNotifier.emailVerified) {
      return '/onboarding-verify-mail';
    }

    return null;
  }

  static String? dashboardGuard(AppStateNotifier appStateNotifier, BuildContext context, GoRouterState state) {
    // Global loading check
    String? authCheck = authGuard(appStateNotifier, context, state) ;
    if (authCheck != null) return authCheck;
    // Get the current location
    final currentLocation = state.uri.toString();

    // Check if we're at the initial route
    if (currentLocation == '/${state.pathParameters['tournamentId']}') {
      if (context.mounted) {
        context.safePop();
      }
      return state.uri.toString();
    }

    return null;
  }
}
