import 'package:flutter/cupertino.dart';

class NavigatorKeys {
  // Root Navigator Key
  static final GlobalKey<NavigatorState> rootNavigator = GlobalKey<NavigatorState>();

  // Level One Navigation Keys
  //root
  static final GlobalKey<NavigatorState> firstLevelKey = GlobalKey<NavigatorState>();
  //detail
  static final GlobalKey<NavigatorState> profileKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> dashboardKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> ownTournamentsKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tournamentFinderKey = GlobalKey<NavigatorState>();

  // Level Two Navigation Keys
  //root
  static final GlobalKey<NavigatorState> tournamentKey = GlobalKey<NavigatorState>();
  //detail
  static final GlobalKey<NavigatorState> tournamentDetailsKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tournamentNewsKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tournamentPeopleKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> tournamentRoundKey = GlobalKey<NavigatorState>();
}