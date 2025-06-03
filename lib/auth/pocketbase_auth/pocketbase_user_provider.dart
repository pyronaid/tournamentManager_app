import 'dart:async';
import 'package:pocketbase/pocketbase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_manager.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';

import '../base_auth_user_provider.dart';

class PocketbaseUserProvider{
  final PocketBase _pb;

  PocketbaseUserProvider(this._pb){
    // Set initial state
    _authStateController.add(_pb.authStore.record);
  }

  final _authStateController = BehaviorSubject<RecordModel?>();

  Stream<BaseAuthUser> pocketbaseUserStream() {
    final StreamController<BaseAuthUser> controller = StreamController<BaseAuthUser>();
    StreamSubscription? userSubscription;

    void emitCurrentUser() {
      try {
        final pbUser = _pb.authStore.record;
        currentUser = PocketbaseUser.getDocumentFromData(pbUser != null ? pbUser.toJson() : {}, pbUser);
      } catch (e) {
        print('Error emitting current user: $e');
        // Ensure we emit something even on error
        currentUser = PocketbaseUser.getDocumentFromData({}, null);
      }
      controller.add(currentUser!);
    }
    void setupUserSubscription() {
      userSubscription?.cancel();
      userSubscription = null;
      if (currentUser != null && currentUser!.loggedIn && currentUser!.uid != null) {
        try {
          userSubscription = _pb.collection(PocketbaseAuthManager.userColl)
              .subscribe(currentUser!.uid.toString(), (e) {
            if (e.action == 'update') {
              print("########### An update in authStore is detected ");
              // Check if verification status has changed (optional)
              final newUserData = e.record!.toJson();
              // Update current user with new data
              currentUser = PocketbaseUser.getDocumentFromData(newUserData, e.record);
              // emit to the stream so subscribers get updated
              controller.add(currentUser!);

              /*
              // If verification status changed, refresh auth
              final oldVerified = _pb.authStore.record?.get('verified') ?? false;
              final newVerified = e.record?.get('verified') ?? false;

              if (oldVerified != newVerified && newVerified) {
                // User just got verified, refresh auth
                _pb.collection(PocketbaseAuthManager.userColl).authRefresh()
                    .catchError((err) => print('Error refreshing auth: $err'));
              }*/
            }
          }) as StreamSubscription;
        } catch (e) {
          print('Error setting up user subscription: $e');
        }
      }
    }


    final authSubscription = _pb.authStore.onChange.listen((AuthStoreEvent event) {
      print("########### A change in authStore is detected ");
      emitCurrentUser();
      setupUserSubscription();
    });

    emitCurrentUser();
    setupUserSubscription();

    controller.onCancel = () {
      userSubscription?.cancel();
      authSubscription.cancel();
    };

    return controller.stream.debounce((user) => user.loggedIn == false && !loggedIn
        ? TimerStream(true, const Duration(seconds: 1))
        : Stream.value(user));

  }

}