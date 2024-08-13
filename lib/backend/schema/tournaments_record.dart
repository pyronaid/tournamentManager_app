
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';
import 'package:tournamentmanager/backend/schema/standings_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class TournamentsRecord extends FirestoreRecord {
  TournamentsRecord._(
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
  String? _creatorUid;
  String get creatorUid => _creatorUid ?? '';
  bool hasCreatorUid() => _creatorUid != null;

  // "game" field.
  Game?  _game;
  Game? get game => _game;
  bool hasGame() => true;
  
  // "name" field.
  String? _name;
  String get name => _name ?? 'Unknown name';
  Future<void> setName(String newName) async {
    _name = newName;
    await updateField(uid, "name", newName);
  }
  bool hasName() => _name != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "address" field.
  int? _capacity;
  int get capacity => _capacity ?? 0;
  bool hasCapacity() => _capacity! > 0;

  // "preregistration-en" field.
  bool _preRegistrationEn = false;
  bool get preRegistrationEn => _preRegistrationEn;
  Future<void> switchPreRegistrationEn() async {
    _preRegistrationEn = !_preRegistrationEn;
    await updateField(uid, "pre_registration_en", _preRegistrationEn);
  }
  bool hasPreRegistrationEn() => _preRegistrationEn;

  // "waitinglist-en" field.
  bool _waitingListEn = false;
  bool get waitingListEn => _waitingListEn;
  Future<void> switchWaitingListEn() async {
    _waitingListEn = !_waitingListEn;
    await updateField(uid, "waiting_list_en", _waitingListEn);
  }
  bool hasWaitingListEn() => _waitingListEn;

  // "preregistration-list" field.
  List<String>? _preRegisteredList;
  List<String> get preRegisteredList => _preRegisteredList ?? const [];
  bool hasPreRegistered() => _preRegisteredList != null;

  // "waitinglist-list" field.
  List<String>? _waitingList;
  List<String> get waitingList => _waitingList ?? const [];
  bool hasWaitingList() => _waitingList != null;

  // "registered-list" field.
  List<String>? _registeredList;
  List<String> get registeredList => _registeredList ?? const [];
  bool hasRegisteredList() => _registeredList != null;

  // "registered-list" field.
  List<String>? _involvedList;
  List<String> get involvedList => _involvedList ?? const [];
  bool hasInvolvedList() => _involvedList != null;

  // "round-list" field.
  List<RoundsRecord>? _roundList;
  List<RoundsRecord> get roundList => _roundList ?? const [];
  bool hasRoundList() => _roundList != null;

  // "standing-list" field.
  List<StandingsRecord>? _standingList;
  List<StandingsRecord> get standingList => _standingList ?? const [];
  bool hasStandingsList() => _standingList != null;

  // "game" field.
  StateTournament?  _state;
  StateTournament? get state => _state;
  bool hasState() => true;

  void _initializeFields() {
    _uid = reference.id;
    _game = getGameEnum(snapshotData['game']);
    _name = snapshotData['name'];
    _date = snapshotData['date'] as DateTime?;
    _address = snapshotData['address'];
    _capacity = snapshotData['capacity'];
    _creatorUid = snapshotData['creator_uid'];
    _preRegistrationEn = snapshotData['pre_registration_en'] as bool;
    _waitingListEn = snapshotData['waiting_list_en'] as bool;
    _preRegisteredList = getDataList<String>(snapshotData['pre_registered_list']);
    _waitingList = getDataList<String>(snapshotData['waiting_list']);
    _registeredList = getDataList<String>(snapshotData['registered_list']);
    _involvedList = getDataList<String>(snapshotData['involved_list']);
    _roundList = getDataList<RoundsRecord>(snapshotData['round_list']);
    _standingList = getDataList<StandingsRecord>(snapshotData['standing_list']);
    _state = getStateEnum(snapshotData['state']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tournaments');

  static Stream<TournamentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TournamentsRecord.fromSnapshot(s));

  static Future<TournamentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TournamentsRecord.fromSnapshot(s));

  static Future<void> updateField(String id, String fieldName, dynamic newValue) async {
    try {
      await collection.doc(id).update({
        fieldName: newValue,
      });
    } catch (e) {
      print("Failed to update field: $e");
    }
  }

  static TournamentsRecord fromSnapshot(DocumentSnapshot snapshot) => TournamentsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static TournamentsRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      TournamentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TournamentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
    other is TournamentsRecord && reference.path.hashCode == other.reference.path.hashCode;

  Game getGameEnum(stringValue) {
    return Game.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => Game.unknown,
    );
  }

  StateTournament? getStateEnum(stringValue) {
    return StateTournament.values.firstWhere(
      (e) => e.name == stringValue,
      orElse: () => StateTournament.unknown,
    );
  }
}


Map<String, dynamic> createTournamentsRecordData({
  String? uid,
  required Game game,
  required String name,
  required DateTime date,
  required String address,
  int? capacity,
  required bool pre_registration_en,
  required bool waiting_list_en,
  StateTournament? state,
  required String? creator_uid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'game': game.name,
      'name': name,
      'date': date,
      'address': address,
      'pre_registration_en': pre_registration_en,
      'waiting_list_en': waiting_list_en,
      'state': state != null ? state.name : StateTournament.open.name,
      'capacity': capacity ?? 0,
      'creator_uid': creator_uid,
    }.withoutNulls,
  );

  return firestoreData;
}

class TournamentsRecordDocumentEquality implements Equality<TournamentsRecord> {
  const TournamentsRecordDocumentEquality();

  @override
  bool equals(TournamentsRecord? e1, TournamentsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.address == e2?.address &&
        e1?.date == e2?.date &&
        e1?.game == e2?.game &&
        e1?.uid == e2?.uid &&
        e1?.name == e2?.name &&
        e1?.preRegistrationEn == e2?.preRegistrationEn &&
        e1?.waitingListEn == e2?.waitingListEn &&
        e1?.state == e2?.state &&
        listEquality.equals(e1?.roundList, e2?.roundList) &&
        listEquality.equals(e1?.standingList, e2?.standingList) &&
        listEquality.equals(e1?.preRegisteredList, e2?.preRegisteredList) &&
        listEquality.equals(e1?.waitingList, e2?.waitingList) &&
        listEquality.equals(e1?.registeredList, e2?.registeredList);
  }

  @override
  int hash(TournamentsRecord? e) => const ListEquality().hash([
    e?.address,
    e?.date,
    e?.game,
    e?.uid,
    e?.name,
    e?.preRegistrationEn,
    e?.waitingListEn,
    e?.state,
    e?.roundList,
    e?.standingList,
    e?.preRegisteredList,
    e?.waitingList,
    e?.registeredList
  ]);

  @override
  bool isValidKey(Object? o) => o is TournamentsRecord;
}


enum Game {
  none,
  ygoAdv,
  ygoRetro,
  lorcana,
  onepiece,
  altered,
  magic,
  unknown
}

enum StateTournament {
  open,
  ready,
  ongoing,
  close,
  unknown
}