import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/backend.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';

class PositionsRecord extends FirestoreRecord {
  PositionsRecord._(
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
  String? _standingUid;
  String get standingUid => _standingUid ?? '';
  bool hasStandingUid() => _standingUid != null;

  // "game" field.
  int? _position;
  int get position => _position ?? 0;
  bool hasPosition() => _position! > 0;

  // "index" field.
  int? _numWin;
  int get numWin => _numWin ?? 0;
  bool hasWin() => _numWin! > 0;

  // "index" field.
  int? _numLose;
  int get numLose => _numLose ?? 0;
  bool hasLose() => _numLose! > 0;

  // "index" field.
  int? _numTie;
  int get numTie => _numTie ?? 0;
  bool hasTie() => _numTie! > 0;

  // "playerA" field.
  UsersRecord? _player;
  UsersRecord? get player => _player;
  bool hasPlayer() => _player != null;

  // "index" field.
  double? _tieBreak1;
  double get tieBreak1 => _tieBreak1 ?? 0.0;
  bool hasTieBreak1() => _tieBreak1! > 0;

  // "index" field.
  double? _tieBreak2;
  double get tieBreak2 => _tieBreak2 ?? 0.0;
  bool hasTieBreak2() => _tieBreak2! > 0;

  // "index" field.
  double? _tieBreak3;
  double get tieBreak3 => _tieBreak3 ?? 0.0;
  bool hasTieBreak3() => _tieBreak3! > 0;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _standingUid = snapshotData['standing_uid'] as String;
    _position = snapshotData['position'] as int?;
    _numWin = snapshotData['num_win'];
    _numLose = snapshotData['num_lose'];
    _numTie = snapshotData['num_tie'];
    _player = snapshotData['player'];
    _tieBreak1 = snapshotData['tie_break_1'];
    _tieBreak2 = snapshotData['tie_break_2'];
    _tieBreak3 = snapshotData['tie_break_3'];
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('matches');

  static Stream<PositionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PositionsRecord.fromSnapshot(s));

  static Future<PositionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PositionsRecord.fromSnapshot(s));

  static PositionsRecord fromSnapshot(DocumentSnapshot snapshot) => PositionsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static PositionsRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      PositionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PositionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PositionsRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPositionsRecordData({
  String? uid,
  String? standing_uid,
  int? position,
  int? num_win,
  int? num_lose,
  int? num_tie,
  UsersRecord? player,
  double? tie_break_1,
  double? tie_break_2,
  double? tie_break_3,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'standing_uid': standing_uid,
      'position': position,
      'num_win': num_win,
      'num_lose': num_lose,
      'num_tie': num_tie,
      'player': player,
      'tie_break_1': tie_break_1,
      'tie_break_2': tie_break_2,
      'tie_break_3': tie_break_3,
    }.withoutNulls,
  );

  return firestoreData;
}

class PositionsRecordDocumentEquality implements Equality<PositionsRecord> {
  const PositionsRecordDocumentEquality();

  @override
  bool equals(PositionsRecord? e1, PositionsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.standingUid == e2?.standingUid &&
        e1?.uid == e2?.uid &&
        e1?.position == e2?.position &&
        e1?.player == e2?.player &&
        e1?.numWin == e2?.numWin &&
        e1?.numLose == e2?.numLose &&
        e1?.numTie == e2?.numTie &&
        e1?.tieBreak1 == e2?.tieBreak1 &&
        e1?.tieBreak2 == e2?.tieBreak2 &&
        e1?.tieBreak3 == e2?.tieBreak3;
  }

  @override
  int hash(PositionsRecord? e) => const ListEquality().hash([
    e?.standingUid,
    e?.uid,
    e?.position,
    e?.player,
    e?.numWin,
    e?.numLose,
    e?.numTie,
    e?.tieBreak1,
    e?.tieBreak2,
    e?.tieBreak3
  ]);

  @override
  bool isValidKey(Object? o) => o is PositionsRecord;
}

