import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class PreregisteredlistRecord extends FirestoreRecord {
  PreregisteredlistRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "uid" field.
  String? _tournamentUid;
  String get tournamentUid => _tournamentUid ?? '';
  bool hasTournamentUid() => _tournamentUid != null;

  //
  String? _userUid;
  String get userUid => _userUid ?? '';
  bool hasUserUid() => _userUid != null;

  // DUPLICATED FIELD FOR ALGOLIA INDEXES
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;


  void _initializeFields() {
    _uid = reference.id;
    _tournamentUid = snapshotData['tournament_uid'];
    _userUid = snapshotData['user_uid'];
    _displayName = snapshotData['display_name'];
    _timestamp = snapshotData['timestamp'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('preregistered_list_info');

  static Stream<PreregisteredlistRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PreregisteredlistRecord.fromSnapshot(s));

  static Stream<List<PreregisteredlistRecord>> getDocuments(Query<Object?> query) {
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      return PreregisteredlistRecord.fromSnapshot(doc);
    }).toList());
  }

  static Future<PreregisteredlistRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PreregisteredlistRecord.fromSnapshot(s));

  static Future<void> deletePeople(String idU) async {
    try {
      QuerySnapshot querySnapshot = await collection.where('user_uid', isEqualTo: idU).get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print("Failed to delete news: $e");
    }
  }

  static Future<void> updateField(String id, String fieldName, dynamic newValue) async {
    try {
      await collection.doc(id).update({
        fieldName: newValue,
      });
    } catch (e) {
      print("Failed to update field: $e");
    }
  }

  static Future<void> updateFields(String id, Map<Object, Object?> dataToUpdate) async {
    try {
      await collection.doc(id).update(dataToUpdate);
    } catch (e) {
      print("Failed to update fields: $e");
    }
  }

  static PreregisteredlistRecord fromSnapshot(DocumentSnapshot snapshot) => PreregisteredlistRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static PreregisteredlistRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      PreregisteredlistRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PreregisteredlistRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
    other is PreregisteredlistRecord && reference.path.hashCode == other.reference.path.hashCode;

}

Map<String, dynamic> createTournamentsRecordData({
  String? uid,
  required String tournament_uid,
  required String user_uid,
  required String display_name,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'tournament_uid': tournament_uid,
      'user_uid': user_uid,
      'display_name': display_name,
      'timestamp': Timestamp.now(),
    }.withoutNulls,
  );

  return firestoreData;
}

class PreregisteredlistRecordDocumentEquality implements Equality<PreregisteredlistRecord> {
  const PreregisteredlistRecordDocumentEquality();

  @override
  bool equals(PreregisteredlistRecord? e1, PreregisteredlistRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.tournamentUid == e2?.tournamentUid &&
        e1?.userUid == e2?.userUid &&
        e1?.displayName == e2?.displayName &&
        e1?.timestamp == e2?.timestamp ;
  }

  @override
  int hash(PreregisteredlistRecord? e) => const ListEquality().hash([
    e?.uid,
    e?.tournamentUid,
    e?.userUid,
    e?.timestamp,
    e?.displayName,
  ]);

  @override
  bool isValidKey(Object? o) => o is PreregisteredlistRecord;
}