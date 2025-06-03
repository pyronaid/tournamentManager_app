import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';

class DevelopersInformationRecord extends PocketstoreRecord {
  static const String collectionName = "developers_information";

  DevelopersInformationRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "surname" field.
  String? _surname;
  String get surname => _surname ?? '';
  bool hasSurname() => _surname != null;

  // "bio" field.
  String? _bio;
  String get bio => _bio ?? '';
  bool hasCompanyBio() => _bio != null;

  // "profilePicure" field.
  String? _profilePic;
  String get profilePic => _profilePic ?? '';
  bool hasProfilePic() => _profilePic != null;


  void _initializeFields() {
    _name = snapshotData['name'];
    _surname = snapshotData['surname'];
    _profilePic = getFileUrl(snapshotData['collectionId'], snapshotData['id'], snapshotData['profilePicture']);
    _bio = snapshotData['bio'];
  }

  static DevelopersInformationRecord fromSnapshot(RecordModel snapshot) => DevelopersInformationRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<DevelopersInformationRecord> getDocument(PocketBase pb, String id) {
    final controller = StreamController<DevelopersInformationRecord>();

    pb.collection(collectionName).getOne(id).then((record) {
      if (!controller.isClosed) controller.add(DevelopersInformationRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(DevelopersInformationRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }

  static Future<DevelopersInformationRecord> getDocumentOnce(PocketBase pb, bool stats, String id) =>
      pb.collection(collectionName).getOne(id).then((s) => DevelopersInformationRecord.fromSnapshot(s));

  static DevelopersInformationRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      DevelopersInformationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() => 'DevelopersInformationRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is DevelopersInformationRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}


class CompanyInformationRecordDocumentEquality
    implements Equality<DevelopersInformationRecord> {
  const CompanyInformationRecordDocumentEquality();

  @override
  bool equals(DevelopersInformationRecord? e1, DevelopersInformationRecord? e2) {
    return e1?.name == e2?.name &&
        e1?.surname == e2?.surname &&
        e1?.profilePic == e2?.profilePic &&
        e1?.bio == e2?.bio;
  }

  @override
  int hash(DevelopersInformationRecord? e) => const ListEquality().hash([
    e?.name,
    e?.surname,
    e?.profilePic,
    e?.bio
  ]);

  @override
  bool isValidKey(Object? o) => o is DevelopersInformationRecord;
}
