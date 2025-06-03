import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/index.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class RoundsRecord extends FirestoreRecord {
  RoundsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "game" field.
  String? _tournamentUid;
  String get tournamentUid => _tournamentUid ?? '';
  bool hasTournamentUid() => _tournamentUid != null;

  // "index" field.
  int? _index;
  int get index => _index!;
  bool hasIndex() => true;

  // "sub_title" field.
  int? _population;
  int get population => _population!;
  bool hasPopulation() => true;

  // "game" field.
  RoundKind?  _kind;
  RoundKind get kind => _kind ?? RoundKind.unknown;
  bool hasRoundKind() => true;

  bool _completed = false;
  bool get completed => _completed;
  Future<void> setCompleted() async {
    _completed = true;
    await updateField(tournamentUid, uid, "completed", true);
  }
  bool isCompleted() => _completed;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "uid" field.
  String? _creatorUid;
  String get creatorUid => _creatorUid ?? '';
  bool hasCreatorUid() => _creatorUid != null;

  void _initializeFields() {
    _uid = reference.id;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _index = snapshotData['index'];
    _population = snapshotData['population'];
    _kind = getRoundKindByName(snapshotData['kind']);
    _completed = snapshotData['completed'];
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _creatorUid = snapshotData['creator_uid'];
  }

  static CollectionReference collection(String tournamentRef) =>
      FirebaseFirestore.instance.collection('tournaments').doc(tournamentRef).collection('rounds');

  static Stream<List<RoundsRecord>> getAllDocuments(String tournamentRef) =>
      collection(tournamentRef).snapshots().map((snapshot) => snapshot.docs.map((doc) => RoundsRecord.fromSnapshot(doc)).toList());

  static Stream<RoundsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoundsRecord.fromSnapshot(s));

  static Future<RoundsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoundsRecord.fromSnapshot(s));

  static Future<void> deleteRounds(String idT, String idR) async {
    try {
      await collection(idT).doc(idR).delete();
    } catch (e) {
      print("Failed to delete round: $e");
    }
  }

  static Future<void> updateField(String idT, String idR, String fieldName, dynamic newValue) async {
    try {
      await collection(idT).doc(idR).update({
        fieldName: newValue,
      });
    } catch (e) {
      print("Failed to update field: $e");
    }
  }

  static RoundsRecord fromSnapshot(DocumentSnapshot snapshot) => RoundsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static RoundsRecord getDocumentFromData(Map<String, dynamic> data, DocumentReference reference,) =>
      RoundsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RoundsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RoundsRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoundsRecordData({
  String? uid,
  required String? tournament_uid,
  required int index,
  required int population,
  required RoundKind kind,
  bool completed = false,
  required String? creator_uid,
  bool show_timestamp_en = false,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'tournament_uid': tournament_uid,
      'index': index,
      'population': population,
      'kind': kind.name,
      'completed': completed,
      'timestamp': Timestamp.now(),
      'creator_uid': creator_uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class RoundsRecordDocumentEquality implements Equality<RoundsRecord> {
  const RoundsRecordDocumentEquality();

  @override
  bool equals(RoundsRecord? e1, RoundsRecord? e2) {
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        e1?.index == e2?.index &&
        e1?.population == e2?.population &&
        e1?.kind == e2?.kind &&
        e1?.completed == e2?.completed &&
        e1?.creatorUid == e2?.creatorUid &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(RoundsRecord? e) => const ListEquality().hash([
    e?.tournamentUid,
    e?.uid,
    e?.index,
    e?.population,
    e?.kind,
    e?.completed,
    e?.timestamp,
    e?.creatorUid
  ]);

  @override
  bool isValidKey(Object? o) => o is RoundsRecord;
}

enum RoundKind {
  swiss("Svizzera"),
  top("Top"),
  unknown("unknown");

  final String desc;

  const RoundKind(this.desc);
}

RoundKind getRoundKindByName(String name) {
  return RoundKind.values.firstWhere(
        (state) => state.name == name,
    orElse: () => RoundKind.unknown,
  );
}