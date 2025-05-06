import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_users_record.dart';

class PocketbaseAuthManager {
  final PocketBase _pb;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String userColl = 'users';

  PocketbaseAuthManager(this._pb);

  //#####################################################
  //#####################################################
  //################# MAIL & PASSWORD AUTH
  //#####################################################
  //#####################################################
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final authData = await _pb.collection(userColl).authWithPassword(email, password,);
      await _secureStorage.write(key: _tokenKey, value: _pb.authStore.token);
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
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
  Future<bool> createAccountWithEmail(String mail, String password) async {
    try{
      RecordModel userData = await _pb.collection(userColl).create(body: {
        'email' : mail,
        'password': password,
        'passwordConfirm': password,
        'emailVisibility': true,
      });

      PocketbaseUser user = PocketbaseUser.getDocumentFromData(userData.toJson(), userData);

      // After creating, you might want to automatically sign in
      bool sendMailFlag = await sendEmailVerification(user.email!);
      if(!sendMailFlag){ return false;}
      return await signInWithEmail(user.email!, password);
    } catch (e) {
      print('Account creation error: $e');
      return false;
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