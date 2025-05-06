
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/base_auth_user_provider.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';

class PocketbaseUser extends BaseAuthUser {
  Map<String, dynamic> snapshotData;
  RecordModel? recordObj;

  PocketbaseUser._(
    this.snapshotData,
    this.recordObj
  ) {
    _initializeFields();
  }

  late String _id;

  late String? _email;
  @override
  String? get email => _email;

  late bool _emailVisibility;
  late bool _emailVerified;
  @override
  bool get emailVerified => _emailVerified;

  late String? _name;
  late String? _surname;
  late String _username;
  late String? _avatar;
  late String? _phoneNumber;

  late DateTime? _createdTime;
  late DateTime? _updatedTime;

  late String _collectionId;
  late String _collectionName;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
    uid: _id,
    email: _email,
    name: _name,
    avatar: _avatar,
    phoneNumber: _phoneNumber,
  );


  void _initializeFields() {
    _id = recordObj != null ? snapshotData['id'] as String : "NA";
    _email = recordObj != null ? snapshotData['email'] as String? : null;
    _emailVisibility = recordObj != null ? snapshotData['emailVisibility'] as bool : false;
    _emailVerified = recordObj != null ? snapshotData['verified'] as bool : false;

    _name = recordObj != null ? snapshotData['name'] as String? : null;
    _surname = recordObj != null ? snapshotData['surname'] as String? : null;
    _username = recordObj != null ? snapshotData['username'] as String : "NA";
    _avatar = recordObj != null ? snapshotData['avatar'] as String? : null;
    _phoneNumber = recordObj != null ? snapshotData['phoneNumber'] as String? : null;

    _createdTime = recordObj != null ? tryParseDate(snapshotData['created']) as DateTime : null;
    _updatedTime = recordObj != null ? tryParseDate(snapshotData['updated']) as DateTime : null;

    _collectionId = recordObj != null ? snapshotData['collectionId'] as String : "NA";
    _collectionName = recordObj != null ? snapshotData['collectionName'] as String : "NA";
  }

  @override
  Future? delete() => pocketAuthManager.deleteUser();
  @override
  Future? updateEmail(String newEmail, String password) {
    //TODO check if the new mail is available
    return pocketAuthManager.updateEmail(_email!, newEmail, password);
  }
  @override
  Future? sendEmailVerification() => pocketAuthManager.sendEmailVerification(_email!);
  @override
  Future refreshUser() => pocketAuthManager.refreshUser();
  @override
  bool get loggedIn => pocketAuthManager.isValid();

  static PocketbaseUser getDocumentFromData(Map<String, dynamic> data, RecordModel? recordObj) => PocketbaseUser._(data, recordObj);
  Map<String, dynamic> toPocketbaseMap() {
    return {
      "id": _id,
      "email": _email,
      "emailVisibility": _emailVisibility,
      "verified": _emailVerified,

      "name": _name,
      "surname": _surname,
      "username": _username,
      "avatar": _avatar,
      "phoneNumber": _phoneNumber,
    };
  }

}
