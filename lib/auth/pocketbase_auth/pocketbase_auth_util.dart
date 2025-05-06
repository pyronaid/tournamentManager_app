import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_manager.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_user_provider.dart';

final PocketBase pb = new PocketBase('http://195.201.90.14:80');

final PocketbaseUserProvider _pocketbaseUserProvider = PocketbaseUserProvider(pb);
PocketbaseUserProvider get pocketbaseUserProvider => _pocketbaseUserProvider;

final PocketbaseAuthManager _pocketAuthManager = PocketbaseAuthManager(pb);
PocketbaseAuthManager get pocketAuthManager => _pocketAuthManager;