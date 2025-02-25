import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/app_flow/nav/routes/auth_routes.dart';
import 'package:tournamentmanager/app_flow/nav/routes/first_level_routes.dart';
import 'package:tournamentmanager/app_flow/nav/routes/tournament_routes.dart';
import 'package:tournamentmanager/pages/onboarding/loading/loading_widget.dart';
import 'package:tournamentmanager/pages/placeholder2_widget.dart';

import '../../pages/core/add_people/barcode_scanner_zoom.dart';
import '../../pages/onboarding/splash/splash_widget.dart';
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
          builder: (context, params) => const SplashWidget(),
          routes: [
            CustomRoute(
              name: 'Splash',
              path: 'splash',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              builder: (context, params) => const SplashWidget(),
            ).toRoute(appStateNotifier),

            CustomRoute(
              name: 'Loading',
              path: 'loading',
              parentNavigatorKey: NavigatorKeys.rootNavigator,
              builder: (context, params) => const LoadingWidget(),
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
              redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
              builder: (context, params) => const Placeholder2Widget(),
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
        context.pop();
      }
      return state.uri.toString();
    }

    return null;
  }
}
