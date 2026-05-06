import '../../../backend/firebase_analytics/analytics.dart';
import '../../../pages/onboarding/forgot_password/forgot_password_container.dart';
import '../../../pages/onboarding/onboarding_create_account/onboarding_create_account_container.dart';
import '../../../pages/onboarding/onboarding_slideshow/onboarding_slideshow_container.dart';
import '../../../pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_container.dart';
import '../../../pages/onboarding/onboarding_verify_mail_success/onboarding_verify_mail_success_container.dart';
import '../../../pages/onboarding/sign_in/sign_in_container.dart';
import '../../app_flow_util.dart';
import '../navigation_keys.dart';
import '../route_config.dart';

class AuthRoutes {
  static List<GoRoute> getRoutes(AppStateNotifier appStateNotifier) => [
    CustomRoute(
      name: 'SignIn',
      path: 'sign-in',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'SignIn'});
        return const SignInContainer();
      },
    ),
    CustomRoute(
      name: 'ForgotPassword',
      path: 'forgot-password',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'ForgotPassword'});
        return const ForgotPasswordContainer();
      },
    ),
    CustomRoute(
      name: 'Onboarding_Slideshow',
      path: 'onboarding-slideshow',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_Slideshow'});
        return const OnboardingSlideshowContainer();
      },
    ),
    CustomRoute(
      name: 'Onboarding_CreateAccount',
      path: 'onboarding-create-account',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_CreateAccount'});
        return const OnboardingCreateAccountContainer();
      },
    ),
    CustomRoute(
      name: 'Onboarding_VerifyMail',
      path: 'onboarding-verify-mail',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) {
        logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_VerifyMail'});
        return const OnboardingVerifyMailContainer();
      },
      routes: [
        CustomRoute(
          name: 'Onboarding_VerifyMailSuccess',
          path: 'success',
          parentNavigatorKey: NavigatorKeys.rootNavigator,
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) {
            logFirebaseEvent('screen_view', parameters: {'screen_name': 'Onboarding_VerifyMailSuccess'});
            return const OnboardingVerifyMailSuccessContainer();
          },
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList()
    ),
  ].map((r) => r.toRoute(appStateNotifier)).toList();
}
