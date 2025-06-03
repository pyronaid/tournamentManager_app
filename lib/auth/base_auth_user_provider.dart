class AuthUserInfo {
  const AuthUserInfo({
    this.uid,
    this.email,
    this.name,
    this.surname,
    this.username,
    this.avatar,
    this.phoneNumber,
  });

  final String? uid;
  final String? email;
  final String? name;
  final String? surname;
  final String? username;
  final String? avatar;
  final String? phoneNumber;
}

abstract class BaseAuthUser {
  bool get loggedIn;
  bool get emailVerified;

  AuthUserInfo get authUserInfo;

  Future? delete();
  Future? updateEmail(String newEmail, String password);
  Future? sendEmailVerification();
  Future refreshUser();

  String? get uid => authUserInfo.uid;
  String? get email => authUserInfo.email;
  String? get name => authUserInfo.name;
  String? get surname => authUserInfo.surname;
  String? get username => authUserInfo.username;
  String? get avatar => authUserInfo.avatar;
  String? get phoneNumber => authUserInfo.phoneNumber;
}

BaseAuthUser? currentUser;
bool get loggedIn => currentUser?.loggedIn ?? false;
