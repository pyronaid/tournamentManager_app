import '../../../pages/onboarding/forgot_password/forgot_password_widget.dart';
import '../../../pages/onboarding/onboarding/onboarding_widget.dart';
import '../../../pages/onboarding/onboarding_create_account/onboarding_create_account_widget.dart';
import '../../../pages/onboarding/onboarding_slideshow/onboarding_slideshow_widget.dart';
import '../../../pages/onboarding/onboarding_verify_mail/onboarding_verify_mail_widget.dart';
import '../../../pages/onboarding/onboarding_verify_mail_success/onboarding_verify_mail_success_widget.dart';
import '../../../pages/onboarding/sign_in/sign_in_widget.dart';
import '../../app_flow_util.dart';
import '../navigation_keys.dart';
import '../route_config.dart';

class AuthRoutes {
  static List<GoRoute> getRoutes(AppStateNotifier appStateNotifier) => [
    CustomRoute(
      name: 'SignIn',
      path: 'sign-in',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const SignInWidget(),
    ),
    CustomRoute(
      name: 'ForgotPassword',
      path: 'forgot-password',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const ForgotPasswordWidget(),
    ),
    CustomRoute(
      name: 'Onboarding_Slideshow',
      path: 'onboarding-slideshow',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const OnboardingSlideshowWidget(),
    ),
    CustomRoute(
      name: 'Onboarding_CreateAccount',
      path: 'onboarding-create-account',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const OnboardingCreateAccountWidget(),
    ),
    CustomRoute(
      name: 'Onboarding_VerifyMail',
      path: 'onboarding-verify-mail',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const OnboardingVerifyMailWidget(),
      routes: [
        CustomRoute(
          name: 'Onboarding_VerifyMailSuccess',
          path: 'success',
          parentNavigatorKey: NavigatorKeys.rootNavigator,
          redirect: (context, state) => RouteGuard.authGuard(appStateNotifier, context, state),
          builder: (context, params) => const OnboardingVerifyMailSuccessWidget(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList()
    ),
    CustomRoute(
      name: 'Onboarding',
      path: 'preferences-onboarding',
      parentNavigatorKey: NavigatorKeys.rootNavigator,
      builder: (context, params) => const OnboardingWidget(),
    ),
  ].map((r) => r.toRoute(appStateNotifier)).toList();
}