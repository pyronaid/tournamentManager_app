import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../pages/core/create_own/create_own_widget.dart';
import '../../pages/nav_bar/nav_bar_widget.dart';
import '../../pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_widget.dart';
import '../../pages/onboarding/onboarding_verify_mail_success/onboarding_verify_mail_success_widget.dart';
import '../../pages/placeholder_widget.dart';
import '/backend/backend.dart';

import '/auth/base_auth_user_provider.dart';

import '/index.dart';
import '/app_flow/app_flow_theme.dart';
import '/app_flow/app_flow_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  AppStateNotifier._();

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();

  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  /// Determines whether the app will refresh and build again when a sign
  /// in or sign out happens. This is useful when the app is launched or
  /// on an unexpected logout. However, this must be turned off when we
  /// intend to sign in/out and then navigate or perform any actions after.
  /// Otherwise, this will trigger a refresh and interrupt the action(s).
  bool notifyOnAuthChange = true;

  bool get loading => user == null || showSplashImage;
  bool get loggedIn => user?.loggedIn ?? false;
  bool get emailVerified => user?.emailVerified ?? false;
  bool get initiallyLoggedIn => initialUser?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  String getRedirectLocation() => _redirectLocation!;
  bool hasRedirect() => _redirectLocation != null;
  void setRedirectLocationIfUnset(String loc) => _redirectLocation ??= loc;
  void clearRedirectLocation() => _redirectLocation = null;

  /// Mark as not needing to notify on a sign in / out when we intend
  /// to perform subsequent actions (such as navigation) afterwards.
  void updateNotifyOnAuthChange(bool notify) => notifyOnAuthChange = notify;

  void update(BaseAuthUser newUser) {
    final shouldUpdate =
        user?.uid == null || newUser.uid == null || user?.uid != newUser.uid;
    initialUser ??= newUser;
    user = newUser;
    // Refresh the app on auth change unless explicitly marked otherwise.
    // No need to update unless the user has changed.
    if (notifyOnAuthChange && shouldUpdate) {
      notifyListeners();
    }
    // Once again mark the notifier as needing to update on auth change
    // (in order to catch sign in / out events).
    updateNotifyOnAuthChange(true);
  }

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) =>
          appStateNotifier.loggedIn ? (appStateNotifier.emailVerified ? const NavBarPage() : const OnboardingVerifyMailWidget()) : const SplashWidget(),
      routes: [
        CustomRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) =>
          appStateNotifier.loggedIn ? (appStateNotifier.emailVerified ? const NavBarPage() : const OnboardingVerifyMailWidget()) : const SplashWidget(),
          routes: [
            CustomRoute(
              name: 'Splash',
              path: 'splash',
              builder: (context, params) => const SplashWidget(),
            ),
            CustomRoute(
              name: 'SignIn',
              path: 'sign-in',
              builder: (context, params) => const SignInWidget(),
            ),
            CustomRoute(
              name: 'Onboarding_VerifyMail',
              path: 'onboarding-verify-mail',
              builder: (context, params) => const OnboardingVerifyMailWidget(),
            ),
            CustomRoute(
              name: 'Onboarding_VerifyMailSuccess',
              path: 'onboarding-verify-mail-success',
              requireAuth: true,
              builder: (context, params) => const OnboardingVerifyMailSuccessWidget(),
            ),
            CustomRoute(
              name: 'Onboarding_Slideshow',
              path: 'onboarding-slideshow',
              builder: (context, params) => const OnboardingSlideshowWidget(),
            ),
            CustomRoute(
              name: 'Onboarding_CreateAccount',
              path: 'onboarding-create-account',
              builder: (context, params) => const OnboardingCreateAccountWidget(),
            ),
            CustomRoute(
              name: 'Dashboard',
              path: 'dashboard',
              requireAuth: true,
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'Dashboard')
                  : const PlaceholderWidget(),
            ),
            CustomRoute(
              name: 'CreateOwn',
              path: 'create-own',
              requireAuth: true,
              builder: (context, params) => const CreateOwnWidget(),
            ),
            CustomRoute(
              name: 'Profile',
              path: 'profile',
              requireAuth: true,
              builder: (context, params) => params.isEmpty
                  ? const NavBarPage(initialPage: 'Profile')
                  : const ProfileWidget(),
            ),
            CustomRoute(
              name: 'EditProfile',
              path: 'edit-profile',
              requireAuth: true,
              builder: (context, params) => const EditProfileWidget(),
            ),
            CustomRoute(
              name: 'AboutUs',
              path: 'about-us',
              requireAuth: true,
              builder: (context, params) => const AboutUsWidget(),
            ),
            CustomRoute(
              name: 'SupportCenter',
              path: 'support-center',
              requireAuth: true,
              builder: (context, params) => const SupportCenterWidget(),
            ),
            CustomRoute(
              name: 'ForgotPassword',
              path: 'forgot-password',
              builder: (context, params) => const ForgotPasswordWidget(),
            ),
            CustomRoute(
              name: 'EditPreferences',
              path: 'edit-preferences',
              requireAuth: true,
              builder: (context, params) => EditPreferencesWidget(
                page: params.getParam(
                  'page',
                  ParamType.int,
                ),
              ),
            ),
            CustomRoute(
              name: 'Onboarding',
              path: 'preferences-onboarding',
              builder: (context, params) => const OnboardingWidget(),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void goNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : goNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void pushNamedAuth(
    String name,
    bool mounted, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Object? extra,
    bool ignoreRedirect = false,
  }) =>
      !mounted || GoRouter.of(this).shouldRedirect(ignoreRedirect)
          ? null
          : pushNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              extra: extra,
            );

  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    if (canPop()) {
      pop();
    } else {
      go('/');
    }
  }
}

extension GoRouterExtensions on GoRouter {
  AppStateNotifier get appState => AppStateNotifier.instance;
  void prepareAuthEvent([bool ignoreRedirect = false]) =>
      appState.hasRedirect() && !ignoreRedirect
          ? null
          : appState.updateNotifyOnAuthChange(false);
  bool shouldRedirect(bool ignoreRedirect) => !ignoreRedirect && appState.hasRedirect();
  void clearRedirectLocation() => appState.clearRedirectLocation();
  void setRedirectLocationIfUnset(String location) =>
      appState.updateNotifyOnAuthChange(false);
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(pathParameters)
    ..addAll(uri.queryParameters)
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class AFParameters {
  AFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.allParams.length == 1 && state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) => asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, {
    bool isList = false,
    List<String>? collectionNamePath,
    StructBuilder<T>? structBuilder,
  }) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
      collectionNamePath: collectionNamePath,
      structBuilder: structBuilder,
    );
  }
}

class CustomRoute {
  const CustomRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, AFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        redirect: (context, state) {
          if (appStateNotifier.shouldRedirect) {
            final redirectLocation = appStateNotifier.getRedirectLocation();
            appStateNotifier.clearRedirectLocation();
            return redirectLocation;
          }

          if (requireAuth && (!appStateNotifier.loggedIn || !appStateNotifier.emailVerified)) {
            appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
            if(!appStateNotifier.loggedIn) {
              return '/splash';
            } else {
              return '/onboarding-verify-mail';
            }
          }
          return null;
        },
        pageBuilder: (context, state) {
          fixStatusBarOniOS16AndBelow(context);
          final afParams = AFParameters(state, asyncParams);
          final page = afParams.hasFutures
              ? FutureBuilder(
                  future: afParams.completeFutures(),
                  builder: (context, _) => builder(context, afParams),
                )
              : builder(context, afParams);
          final child = appStateNotifier.loading
              ? Container(
                  width: 92.w,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          CustomFlowTheme.of(context).gradientBackgroundBegin,
                          CustomFlowTheme.of(context).gradientBackgroundEnd,
                        ],
                      )
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Lottie.asset(
                          'assets/animation/splash_animation.json',
                          fit: BoxFit.cover,
                          width: 80.sp, // Adjust the width and height as needed
                          height: 70.sp,
                          repeat: true, // Set to true if you want the animation to loop
                        ),
                      ),
                      Center(
                        child: DefaultTextStyle(
                          style: TextStyle(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent
                          ),
                          child: const Center(
                            child: Text(
                              "Tournament Manager",
                              textAlign: TextAlign.center,
                            )
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) =>
                          PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).buildTransitions(
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ),
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
  );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => const TransitionInfo(hasTransition: false);
}

class RootPageContext {
  const RootPageContext(this.isRootPage, [this.errorRoute]);
  final bool isRootPage;
  final String? errorRoute;

  static bool isInactiveRootPage(BuildContext context) {
    final rootPageContext = context.read<RootPageContext?>();
    final isRootPage = rootPageContext?.isRootPage ?? false;
    final location = GoRouterState.of(context).uri.toString();
    return isRootPage &&
        location != '/' &&
        location != rootPageContext?.errorRoute;
  }

  static Widget wrap(Widget child, {String? errorRoute}) => Provider.value(
        value: RootPageContext(true, errorRoute),
        child: child,
      );
}

extension GoRouterLocationExtension on GoRouter {
  String getCurrentLocation() {
    final RouteMatch lastMatch = routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }
}
