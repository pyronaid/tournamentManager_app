import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/internationalization.dart';
import 'package:tournamentmanager/app_flow/nav/nav_basics.dart';
import 'package:tournamentmanager/app_flow/services/locator.dart';
import 'package:tournamentmanager/backend/firebase/firebase_config.dart';

import 'app_flow/nav/navigation_keys.dart';
import 'app_flow/nav/route_config.dart';
import 'app_flow/services/ServiceManager.dart';
import 'auth/base_auth_user_provider.dart';
import 'auth/pocketbase_auth/pocketbase_auth_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await initFirebase();

  //Service Locator
  serviceLocatorSetUp();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) => context.findAncestorStateOfType<_MyAppState>()!;
}


class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = CustomFlowTheme.themeMode;

  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  //final authUserSub = pocketbaseUserProvider.pocketbaseUserStream().listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = RouteConfig.createRouter(_appStateNotifier);
    pocketAuthManager.signInWithToken().then((success){
      userStream = pocketbaseUserProvider.pocketbaseUserStream()..listen(
         (user) => _appStateNotifier.update(user)
      );
    });
    Future.delayed(
      const Duration(milliseconds: 4000), () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    //authUserSub.cancel();

    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
    _themeMode = mode;
    CustomFlowTheme.saveThemeMode(mode);
  });

  @override
  Widget build(BuildContext context) {

    return ResponsiveSizer(
      builder: (context, orientation, deviceType){
        return MaterialApp.router(
          title: 'TournamentManager',
          localizationsDelegates: const [
            CustomLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: _locale,
          supportedLocales: const [
            Locale('en'),
          ],
          theme: ThemeData(
            brightness: Brightness.light,
            useMaterial3: false,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: false,
          ),
          themeMode: _themeMode,
          routerConfig: _router,
          builder: (context, child) {
            return Overlay(
              initialEntries: [
                OverlayEntry(
                  builder: (context) => ServiceManager(
                    navigatorKey: NavigatorKeys.rootNavigator,
                    child: child!,
                  ),
                ),
              ],
            );
          },
        );
      }
    );
  }
}