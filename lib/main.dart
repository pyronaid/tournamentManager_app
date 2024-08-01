
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app_flow/app_flow_theme.dart';
import 'app_flow/internationalization.dart';
import 'app_flow/nav/nav.dart';
import 'app_state.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'backend/firebase/firebase_config.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();
  await initFirebase();

  await CustomFlowTheme.initialize();

  final appState = CustomAppState();
  await appState.initializePersistedState();

  runApp(ChangeNotifierProvider(
      create: (context) => appState,
      child: const MyApp()
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}


class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = CustomFlowTheme.themeMode;

  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;

  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();

    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = petsyFirebaseUserStream()..listen(
            (user) => _appStateNotifier.update(user)
    );
    jwtTokenStream.listen((_) {});
    Future.delayed(
      const Duration(milliseconds: 4000), () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();

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
            title: 'Petsy',
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
          );
        }
    );


  }
}