import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tuple/tuple.dart';

import '../../app_flow/services/DeviceTokenService.dart';
import '../../app_flow/services/SnackBarService.dart';
import '../../app_flow/services/supportClass/snackbar_style.dart';

class PocketbaseAuthManager {
  final PocketBase _pb;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String userColl = 'users';

  late SnackBarService snackBarService;
  late final DeviceTokenService _deviceTokenService;

  PocketbaseAuthManager(this._pb){
    snackBarService = GetIt.instance<SnackBarService>();
    _deviceTokenService = DeviceTokenService(_pb);
    // Start listening for token refresh
    _deviceTokenService.listenForTokenRefresh();
  }

  //#####################################################
  //#####################################################
  //################# MAIL & PASSWORD AUTH
  //#####################################################
  //#####################################################
  Future<Tuple2<bool,String?>> signInWithEmail(String email, String password) async {
    try {
      final authData = await _pb.collection(userColl).authWithPassword(email, password,);
      await _secureStorage.write(key: _tokenKey, value: _pb.authStore.token);
      await _deviceTokenService.saveDeviceToken();
      return const Tuple2(true,null);
    } on ClientException catch (errorRef, e) {
      debugPrint('[signInWithEmail] Login error: $e');
      var convertedMessage = "";
      if(errorRef.response.isNotEmpty && errorRef.response["message"] != null){
        switch(errorRef.response["message"]){
          case "Failed to authenticate.":
            convertedMessage = "Autenticazione fallita: mail o password non corrette.";
            break;
          default:
            convertedMessage = errorRef.response["message"];
        }
      }
      return Tuple2(false,convertedMessage);
    } on Exception catch (_, e) {
      return const Tuple2(false,'Errore generico in fase di login');
    }
  }
  Future<bool> signInWithToken() async {
    try{
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Set the token in the auth store
      _pb.authStore.save(token, null);
      try {
        final authData = await _pb.collection(userColl).authRefresh();
        // Update the auth store with the full record
        _pb.authStore.save(authData.token, authData.record);
        return true;
      } catch (e){
        print('Token validation failed: $e');
        await _secureStorage.delete(key: _tokenKey);
        await _deviceTokenService.removeDeviceToken();
        _pb.authStore.clear();
        return false;
      }
    } catch (e){
      print('Error initializing auth: $e');
      return false;
    }
  }


  //#####################################################
  //#####################################################
  //################# OTP AUTH
  //#####################################################
  //#####################################################
  Future<bool> sendOTP(String email) async {
    try {
      await _pb.collection(userColl).requestOTP(email);
      return true;
    } catch (e) {
      print('OTP request error: $e');
      return false;
    }
  }
  Future<bool> signInWithOtp(String email, String otpId, String otpCode) async {
    try {
      final authData = await _pb.collection(userColl).authWithOTP(otpId, otpCode,);
      await _secureStorage.write(key: _tokenKey, value: _pb.authStore.token);
      await _deviceTokenService.saveDeviceToken();
      return true;
    } catch (e) {
      print('OTP verification error: $e');
      return false;
    }
  }

  //#####################################################
  //#####################################################
  //################# RESET PASS & UPDATE MAIL
  //#####################################################
  //#####################################################
  Future<bool> resetPassword(String email) async {
    try {
      await _pb.collection(userColl).requestPasswordReset(email);
      return true;
    } catch (e) {
      print('Password reset request error: $e');
      return false;
    }
  }
  Future<bool> confirmPasswordReset(String token, String password, String passwordConfirm) async {
    try {
      await _pb.collection(userColl).confirmPasswordReset(token, password, passwordConfirm);
      return true;
    } catch (e) {
      print('Password reset confirmation error: $e');
      return false;
    }
  }
  Future<bool> updateEmail(String oldEmail, String newEmail, String password) async {
    try {
      if (!_pb.authStore.isValid) {
        return false;
      }
      // Get the current user record
      await _pb.collection(userColl).authWithPassword(oldEmail, password);
      await _pb.collection(userColl).requestEmailChange(newEmail);
      return true;
    } catch (e) {
      print('Email update error: $e');
      return false;
    }
  }
  Future<bool> confirmEmailChange(String token, String password) async {
    try {
      await _pb.collection(userColl).confirmEmailChange(token, password);
      return true;
    } catch (e) {
      print('Password reset confirmation error: $e');
      return false;
    }
  }

  //#####################################################
  //#####################################################
  //################# CREATE & VERIFY USER
  //#####################################################
  //#####################################################
  Future<Tuple3<bool,String,String>> createAccountWithEmail({required String mail, required String password, String? name, String? surname, String? username}) async {
    try{
      RecordModel userData = await _pb.collection(userColl).create(body: {
        'email': mail,
        'password': password,
        'passwordConfirm': password,
        'emailVisibility': true,
        'name': (name?.isEmpty ?? true) ? null : name,
        'surname': (surname?.isEmpty ?? true) ? null : surname,
        'username': (username?.isEmpty ?? true) ? null : username,
      });

      PocketbaseUser user = PocketbaseUser.getDocumentFromData(userData.toJson(), userData);

      // After creating, you might want to automatically sign in
      bool sendMailFlag = await sendEmailVerification(user.email!);
      if(!sendMailFlag){ return const Tuple3(false, '', '');}
      bool signInFlag = (await signInWithEmail(user.email!, password)).item1;
      return Tuple3(signInFlag, '', '');
    } catch (e) {
      Map<String, dynamic>? dataError = (e as ClientException).response['data'];
      if(dataError != null && dataError.isNotEmpty){
        String key = dataError.entries.first.key;
        String errorCode = dataError.entries.first.value['code'];
        String errorMessage = ClientErrorCodes.getMessageFromString(errorCode);
        return Tuple3(false, key, errorMessage);
      }
      snackBarService.showSnackBar(
          message: 'Qualcosa è andato storto. Riprova più tardi',
          title: 'Errore di registrazione utente',
          style: SnackbarStyle.error
      );
      print('Account creation error: $e');
      return const Tuple3(false, '', '');
    }
  }
  Future<bool> sendEmailVerification(String email) async {
    try{
      await _pb.collection(userColl).requestVerification(email);
      return true;
    } catch (e) {
      print('Email verification request error: $e');
      return false;
    }
  }
  Future<bool> confirmEmailVerification(String token) async {
    try{
      await _pb.collection(userColl).confirmVerification(token);
      return true;
    } catch (e) {
      print('Email verification request error: $e');
      return false;
    }
  }

  //#####################################################
  //#####################################################
  //################# SIGNOUT & DELETE
  //#####################################################
  //#####################################################
  Future<void> signOut() async {
    _pb.authStore.clear();
    await _secureStorage.delete(key: _tokenKey);
    await _deviceTokenService.removeDeviceToken();
  }
  Future<bool> deleteUser() async {
    try {
      if (!_pb.authStore.isValid) {
        return false;
      }

      final String? userId = _pb.authStore.record?.id;
      await _pb.collection(userColl).delete(userId!);
      await signOut();

      return true;
    } catch (e) {
      print('User deletion error: $e');
      return false;
    }
  }
  Future<bool> refreshUser() async {
    try {
      if (!_pb.authStore.isValid) {
        // Try to load token from secure storage
        final token = await _secureStorage.read(key: _tokenKey);
        if (token == null) {
          return false;
        }

        // Set the token to auth store
        _pb.authStore.save(token, null);
      }

      // Fetch the latest user data
      final userId = _pb.authStore.record?.id;
      final freshUserData = await _pb.collection(userColl).getOne(userId!);
      _pb.authStore.save(_pb.authStore.token, freshUserData);

      return true;
    } catch (e) {
      print('User refresh error: $e');
      await signOut();
      return false;
    }
  }
  bool isValid() {
    try {
      return _pb.authStore.isValid;
    } catch (e) {
      print('User validation check error: $e');
      return false;
    }
  }
}