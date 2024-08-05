import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

import 'matches_record.dart';

class StandingsRecord extends FirestoreRecord {
  StandingsRecord._(
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
  int? _roundIndex;
  int get roundIndex => _roundIndex ?? 0;
  bool hasRoundIndex() => _roundIndex! > 0;

  // "matches-list" field.
  List<PositionsRecord>? _positionList;
  List<PositionsRecord> get positionList => _positionList ?? const [];
  bool hasPosition() => _positionList != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _roundIndex = snapshotData['round_index'];
    _positionList = getDataList(snapshotData['position_list']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rounds');

  static Stream<StandingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => StandingsRecord.fromSnapshot(s));

  static Future<StandingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => StandingsRecord.fromSnapshot(s));

  static StandingsRecord fromSnapshot(DocumentSnapshot snapshot) => StandingsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static StandingsRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      StandingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'StandingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is StandingsRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoundsRecordData({
  String? uid,
  String? tournament_uid,
  int? round_index,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'tournament_uid': tournament_uid,
      'round_index': round_index,
    }.withoutNulls,
  );

  return firestoreData;
}

class StandingsRecordDocumentEquality implements Equality<StandingsRecord> {
  const StandingsRecordDocumentEquality();

  @override
  bool equals(StandingsRecord? e1, StandingsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        listEquality.equals(e1?.positionList, e2?.positionList);
  }

  @override
  int hash(StandingsRecord? e) => const ListEquality().hash([
    e?.tournamentUid,
    e?.uid,
    e?.positionList
  ]);

  @override
  bool isValidKey(Object? o) => o is StandingsRecord;
}

