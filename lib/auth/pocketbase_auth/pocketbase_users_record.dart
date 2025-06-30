
import 'package:collection/collection.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/auth/base_auth_user_provider.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

import '../../backend/schema/util/firestore_util.dart';

class PocketbaseUser extends BaseAuthUser {
  Map<String, dynamic> snapshotData;
  RecordModel? recordObj;
  static const String collectionName = "users";
  static const String idFieldName = "id";
  static const String emailFieldName = "email";
  static const String emailVisibilityFieldName = "emailVisibility";
  static const String verifiedFieldName = "verified";
  static const String nameFieldName = "name";
  static const String surnameFieldName = "surname";
  static const String usernameFieldName = "username";
  static const String avatarFieldName = "avatar";
  static const String phoneNumberFieldName = "phoneNumber";
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  PocketbaseUser._(
    this.snapshotData,
    this.recordObj
  ) {
    _initializeFields();
  }

  late String _id;
  @override
  String? get uid => _id;
  late String? _email;
  @override
  String? get email => _email;
  late String? _name;
  @override
  String? get name => _name;
  late String? _surname;
  @override
  String? get surname => _surname;
  late String _username;
  @override
  String? get username => _username;
  late String? _avatar;
  @override
  String? get avatar => _avatar;
  late String? _phoneNumber;
  @override
  String? get phoneNumber => _phoneNumber;
  late bool _emailVisibility;
  late bool _emailVerified;
  @override
  bool get emailVerified => _emailVerified;

  late DateTime? _createdTime;
  late DateTime? _updatedTime;

  late String _collectionId;
  late String _collectionName;

  @override
  AuthUserInfo get authUserInfo => AuthUserInfo(
    uid: _id,
    email: _email,
    name: _name,
    surname: _surname,
    username: _username,
    avatar: _avatar,
    phoneNumber: _phoneNumber,
  );


  void _initializeFields() {
    _id = recordObj != null ? snapshotData[idFieldName] as String : "NA";
    _email = recordObj != null ? snapshotData[emailFieldName] as String? : null;
    _emailVisibility = recordObj != null ? snapshotData[emailVisibilityFieldName] as bool : false;
    _emailVerified = recordObj != null ? snapshotData[verifiedFieldName] as bool : false;

    _name = recordObj != null ? snapshotData[nameFieldName] as String? : null;
    _surname = recordObj != null ? snapshotData[surnameFieldName] as String? : null;
    _username = recordObj != null ? snapshotData[usernameFieldName] as String : "NA";
    _avatar = recordObj != null ? snapshotData[avatarFieldName] as String? : null;
    _phoneNumber = recordObj != null ? snapshotData[phoneNumberFieldName] as String? : null;

    _createdTime = recordObj != null ? tryParseDate(snapshotData[createdFieldName]) as DateTime : null;
    _updatedTime = recordObj != null ? tryParseDate(snapshotData[updatedFieldName]) as DateTime : null;

    _collectionId = recordObj != null ? snapshotData[collectionIdFieldName] as String : "NA";
    _collectionName = recordObj != null ? snapshotData[collectionNameFieldName] as String : "NA";
  }

  static PocketbaseUser fromSnapshot(RecordModel snapshot) => PocketbaseUser._(
    snapshot.toJson(),
    snapshot
  );

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
  static Future<PocketbaseUser> getDocumentOnce(PocketBase pb, String id) =>
      pb.collection(collectionName).getOne(id).then((s) => PocketbaseUser.fromSnapshot(s));
  Map<String, dynamic> toPocketbaseMap() {
    return {
      idFieldName: _id,
      emailFieldName: _email,
      emailVisibilityFieldName: _emailVisibility,
      verifiedFieldName: _emailVerified,
      nameFieldName: _name,
      surnameFieldName: _surname,
      usernameFieldName: _username,
      avatarFieldName: _avatar,
      phoneNumberFieldName: _phoneNumber,
    };
  }

  static Future<void> updateFields(PocketBase pb, String id, Map<String, dynamic> dataToUpdate) async {
    try {
      await pb.collection(collectionName).update(id, body: dataToUpdate);
    } catch (e) {
      print("Failed to update fields: $e");
    }
  }

  @override
  String toString() =>
      'UsersRecord(reference: ${recordObj!.id}-${recordObj!.collectionId}-${recordObj!.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (recordObj!.id+recordObj!.collectionId+recordObj!.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is PocketbaseUser &&
          (recordObj!.id+recordObj!.collectionId+recordObj!.collectionName).hashCode == (other.recordObj!.id+other.recordObj!.collectionId+other.recordObj!.collectionName).hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? name,
  String? surname,
  String? username,
  String? photoUrl,
  String? id,
  DateTime? createdTime,
  String? phoneNumber,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      PocketbaseUser.emailFieldName: email,
      PocketbaseUser.nameFieldName: name,
      PocketbaseUser.surnameFieldName: surname,
      PocketbaseUser.usernameFieldName: username,
      PocketbaseUser.avatarFieldName: photoUrl,
      PocketbaseUser.idFieldName: id,
      PocketbaseUser.createdFieldName: createdTime,
      PocketbaseUser.phoneNumberFieldName: phoneNumber,
    }.withoutNulls,
  );
  return pocketstoreData;
}

class PocketbaseUsersRecordDocumentEquality implements Equality<PocketbaseUser> {
  const PocketbaseUsersRecordDocumentEquality();

  @override
  bool equals(PocketbaseUser? e1, PocketbaseUser? e2) {
    return e1?.email == e2?.email &&
        e1?.name == e2?.name &&
        e1?.surname == e2?.name &&
        e1?.username == e2?.username &&
        e1?.avatar == e2?.avatar &&
        e1?.uid == e2?.uid &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?._emailVisibility == e2?._emailVisibility &&
        e1?._emailVerified == e2?._emailVerified &&
        e1?._createdTime == e2?._createdTime &&
        e1?._updatedTime == e2?._updatedTime &&
        e1?._collectionId == e2?._collectionId &&
        e1?._collectionName == e2?._collectionName;
  }

  @override
  int hash(PocketbaseUser? e) => const ListEquality().hash([
    e?.email,
    e?.name,
    e?.surname,
    e?.username,
    e?.avatar,
    e?.uid,
    e?.phoneNumber,
    e?._emailVisibility,
    e?._emailVerified,
    e?._createdTime,
    e?._updatedTime,
    e?._collectionId,
    e?._collectionName,
  ]);

  @override
  bool isValidKey(Object? o) => o is PocketbaseUser;
}
