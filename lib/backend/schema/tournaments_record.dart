
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';
import 'package:tournamentmanager/backend/schema/standings_record.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
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
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "date" field.
  Timestamp? _date;
  Timestamp? get date => _date;
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
  bool hasPreRegistrationEn() => _preRegistrationEn;

  // "waitinglist-en" field.
  bool _waitingListEn = false;
  bool get waitingListEn => _waitingListEn;
  bool hasWaitingListEn() => _waitingListEn;

  // "preregistration-list" field.
  List<UsersRecord>? _preRegisteredList;
  List<UsersRecord> get preRegisteredList => _preRegisteredList ?? const [];
  bool hasPreRegistered() => _preRegisteredList != null;

  // "waitinglist-list" field.
  List<UsersRecord>? _waitingList;
  List<UsersRecord> get waitingList => _waitingList ?? const [];
  bool hasWaitingList() => _waitingList != null;

  // "registered-list" field.
  List<UsersRecord>? _registeredList;
  List<UsersRecord> get registeredList => _registeredList ?? const [];
  bool hasRegisteredList() => _registeredList != null;

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
    _uid = snapshotData['uid'] as String?;
    _game = snapshotData['game'] as Game;
    _name = snapshotData['name'] as String?;
    _date = snapshotData['date'] as Timestamp?;
    _address = snapshotData['address'] as String?;
    _capacity = snapshotData['capacity'];
    _creatorUid = snapshotData['creator_uid'];
    _preRegistrationEn = snapshotData['pre_registration_en'];
    _waitingListEn = snapshotData['waiting_list_en'];
    _preRegisteredList = getDataList(snapshotData['pre_registered_list']);
    _waitingList = getDataList(snapshotData['waiting_list']);
    _registeredList = getDataList(snapshotData['registered_list']);
    _roundList = getDataList(snapshotData['round_list']);
    _standingList = getDataList(snapshotData['standing_list']);
    _state = snapshotData['state'] as StateTournament;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('tournaments');

  static Stream<TournamentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TournamentsRecord.fromSnapshot(s));

  static Future<TournamentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TournamentsRecord.fromSnapshot(s));

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
      other is TournamentsRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
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
  magic
}

enum StateTournament {
  open,
  ready,
  ongoing,
  close
}