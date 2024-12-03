import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/index.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';

class MatchesRecord extends FirestoreRecord {
  MatchesRecord._(
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

  // "game" field.
  String? _roundUid;
  String get roundUid => _roundUid ?? '';
  bool hasRoundUid() => _roundUid != null;

  // "index" field.
  int? _table;
  int get table => _table ?? 0;
  bool hasTable() => _table! > 0;

  // "playerA" field.
  UsersRecord? _playerA;
  UsersRecord? get playerA => _playerA;
  bool hasPlayerA() => _playerA != null;

  // "playerB" field.
  UsersRecord? _playerB;
  UsersRecord? get playerB => _playerB;
  bool hasPlayerB() => _playerB != null;

  // "winner" field.
  UsersRecord? _winner;
  UsersRecord? get winner => _winner;
  bool hasWinner() => _winner != null;

  // "game" field.
  StateMatch?  _state;
  StateMatch? get state => _state;
  bool hasState() => true;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _roundUid = snapshotData['round_uid'] as String;
    _table = snapshotData['table'];
    _playerA = snapshotData['player_A'];
    _playerB = snapshotData['player_B'];
    _winner = snapshotData['winner'];
    _state = snapshotData['state'];
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('matches');

  static Stream<MatchesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MatchesRecord.fromSnapshot(s));

  static Future<MatchesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MatchesRecord.fromSnapshot(s));

  static MatchesRecord fromSnapshot(DocumentSnapshot snapshot) => MatchesRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static MatchesRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      MatchesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MatchesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MatchesRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMatchesRecordData({
  String? uid,
  String? tournament_uid,
  String? round_uid,
  int? table,
  UsersRecord? player_A,
  UsersRecord? player_B,
  StateMatch? state,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'tournament_uid': tournament_uid,
      'round_uid': round_uid,
      'table': table,
      'player_A': player_A,
      'player_B': player_B,
      'state': state,
    }.withoutNulls,
  );

  return firestoreData;
}

class MatchesRecordDocumentEquality implements Equality<MatchesRecord> {
  const MatchesRecordDocumentEquality();

  @override
  bool equals(MatchesRecord? e1, MatchesRecord? e2) {
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        e1?.roundUid == e2?.roundUid &&
        e1?.playerA == e2?.playerA &&
        e1?.playerB == e2?.playerB &&
        e1?.winner == e2?.winner &&
        e1?.state == e2?.state &&
        e1?.table == e2?.table;
  }

  @override
  int hash(MatchesRecord? e) => const ListEquality().hash([
    e?.tournamentUid,
    e?.uid,
    e?.roundUid,
    e?.playerA,
    e?.playerB,
    e?.winner,
    e?.state,
    e?.table
  ]);

  @override
  bool isValidKey(Object? o) => o is MatchesRecord;
}


enum StateMatch {
  open,
  close
}
