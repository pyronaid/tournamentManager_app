import 'package:flutter/cupertino.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_manager.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_user_provider.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';

import '../base_auth_user_provider.dart';

final PocketBase pb = PocketBase('http://195.201.90.14:8080');
final String pbBaseUri = pb.baseURL;
PocketbaseUser? currentUserDocument;

final PocketbaseUserProvider _pocketbaseUserProvider = PocketbaseUserProvider(pb);
PocketbaseUserProvider get pocketbaseUserProvider => _pocketbaseUserProvider;

final PocketbaseAuthManager _pocketAuthManager = PocketbaseAuthManager(pb);
PocketbaseAuthManager get pocketAuthManager => _pocketAuthManager;


String get currentUserEmail => currentUserDocument?.email ?? currentUser?.email ?? '';
String get currentUserUid => currentUser?.uid ?? '';
String get currentUserName => currentUserDocument?.name ?? currentUser?.name ?? '';
String get currentUserSurname => currentUserDocument?.surname ?? currentUser?.surname ?? '';
String get currentUserUsername => currentUserDocument?.username ?? currentUser?.username ?? '';
String get currentUserPhoto => currentUserDocument?.avatar ?? currentUser?.avatar ?? '';
String get currentPhoneNumber => currentUserDocument?.phoneNumber ?? currentUser?.phoneNumber ?? '';
bool get currentUserEmailVerified => currentUser?.emailVerified ?? false;


class AuthUserStreamWidget extends StatelessWidget {
  const AuthUserStreamWidget({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: pocketbaseUserProvider.pocketbaseUserStream(),
    builder: (context, _) => builder(context),
  );
}
