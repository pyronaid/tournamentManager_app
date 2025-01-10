import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/preregisteredlist_record.dart';
import 'package:tournamentmanager/backend/schema/registeredlist_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class WaitinglistRecord extends FirestoreRecord {
  WaitinglistRecord._(
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
      FirebaseFirestore.instance.collection('waiting_list_info');

  static Stream<WaitinglistRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WaitinglistRecord.fromSnapshot(s));

  static Stream<List<WaitinglistRecord>> getDocuments(Query<Object?> query) {
    return query.snapshots().map((snapshot) => snapshot.docs.map((doc) {
      return WaitinglistRecord.fromSnapshot(doc);
    }).toList());
  }

  static Future<WaitinglistRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WaitinglistRecord.fromSnapshot(s));

  static Future<List<WaitinglistRecord>> getDocumentsOnce(Query query) {
    return query.get().then((s) => s.docs.map((doc) {
      return WaitinglistRecord.fromSnapshot(doc);
    }).toList());
  }

  static Future<void> deletePeople(String idU, String idT) async {
    try {
      QuerySnapshot querySnapshot = await collection
          .where('user_uid', isEqualTo: idU)
          .where('tournament_uid', isEqualTo: idT)
          .get();
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (DocumentSnapshot doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print("Failed to delete news: $e");
    }
  }
  static Future<void> promotePeopleToRegistered(String idU, String idT) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot waitingListSnapshot = await collection
            .where('user_uid', isEqualTo: idU)
            .where('tournament_uid', isEqualTo: idT)
            .get();
        for (DocumentSnapshot doc in waitingListSnapshot.docs) {
          Map<String, dynamic> dataToInsertIntoRegistered = {
            "tournament_uid" : doc['tournament_uid'],
            "user_uid" : doc['user_uid'],
            "display_name" : doc['display_name'],
            "timestamp" : doc['timestamp'],
          };
          transaction.set(RegisteredlistRecord.collection.doc(), dataToInsertIntoRegistered, SetOptions(merge: true));
          transaction.delete(doc.reference);
        }
      }).then(
        (value) => print("DocumentSnapshot successfully promoted!"),
          onError: (e) => print("Error promoting document $e"),
      );
    } catch (e) {
      print("Failed to delete news: $e");
    }
  }
  static Future<void> promotePeople(String idU, String idT, ListType from) async {
    CollectionReference fromCollection;
    switch(from){
      case ListType.waiting:
        fromCollection = WaitinglistRecord.collection;
        break;
      case ListType.registered:
        fromCollection = RegisteredlistRecord.collection;
        break;
      case ListType.preregistered:
        fromCollection = PreregisteredlistRecord.collection;
        break;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        QuerySnapshot fromListSnapshot = await fromCollection
            .where('user_uid', isEqualTo: idU)
            .where('tournament_uid', isEqualTo: idT)
            .get();
        for (DocumentSnapshot doc in fromListSnapshot.docs) {
          Map<String, dynamic> dataToInsertIntoHere = {
            "tournament_uid" : doc['tournament_uid'],
            "user_uid" : doc['user_uid'],
            "display_name" : doc['display_name'],
            "timestamp" : doc['timestamp'],
          };
          transaction.set(collection.doc(), dataToInsertIntoHere, SetOptions(merge: true));
          transaction.delete(doc.reference);
        }
      }).then(
            (value) => print("DocumentSnapshot successfully promoted!"),
        onError: (e) => print("Error promoting document $e"),
      );
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

  static WaitinglistRecord fromSnapshot(DocumentSnapshot snapshot) => WaitinglistRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static WaitinglistRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      WaitinglistRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WaitinglistRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
    other is WaitinglistRecord && reference.path.hashCode == other.reference.path.hashCode;

}

Map<String, dynamic> createWaitingListRecordData({
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

class WaitinglistRecordDocumentEquality implements Equality<WaitinglistRecord> {
  const WaitinglistRecordDocumentEquality();

  @override
  bool equals(WaitinglistRecord? e1, WaitinglistRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.tournamentUid == e2?.tournamentUid &&
        e1?.userUid == e2?.userUid &&
        e1?.displayName == e2?.displayName &&
        e1?.timestamp == e2?.timestamp ;
  }

  @override
  int hash(WaitinglistRecord? e) => const ListEquality().hash([
    e?.uid,
    e?.tournamentUid,
    e?.userUid,
    e?.timestamp,
    e?.displayName,
  ]);

  @override
  bool isValidKey(Object? o) => o is WaitinglistRecord;
}