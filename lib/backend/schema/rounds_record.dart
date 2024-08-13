import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/backend.dart';

import 'matches_record.dart';

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
  int? _roundIndex;
  int get roundIndex => _roundIndex ?? 0;
  bool hasRoundIndex() => _roundIndex! > 0;

  // "matches-list" field.
  List<MatchesRecord>? _matchesList;
  List<MatchesRecord> get matchesList => _matchesList ?? const [];
  bool hasMatches() => _matchesList != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _roundIndex = snapshotData['round_index'];
    _matchesList = getDataList(snapshotData['matches_list']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rounds');

  static Stream<RoundsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoundsRecord.fromSnapshot(s));

  static Future<RoundsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoundsRecord.fromSnapshot(s));

  static RoundsRecord fromSnapshot(DocumentSnapshot snapshot) => RoundsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static RoundsRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
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

class RoundsRecordDocumentEquality implements Equality<RoundsRecord> {
  const RoundsRecordDocumentEquality();

  @override
  bool equals(RoundsRecord? e1, RoundsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        listEquality.equals(e1?.matchesList, e2?.matchesList);
  }

  @override
  int hash(RoundsRecord? e) => const ListEquality().hash([
    e?.tournamentUid,
    e?.uid,
    e?.matchesList
  ]);

  @override
  bool isValidKey(Object? o) => o is RoundsRecord;
}

