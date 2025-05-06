
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class TournamentsRecord extends PocketstoreRecord {
  static const String collectionName = "tournaments";

  TournamentsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }


  // "id" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "uid" field.
  String? _creatorUid;
  String get creatorUid => _creatorUid ?? '';
  void setCreatorUid(String newCreatorUid) => _creatorUid = newCreatorUid;
  bool hasCreatorUid() => _creatorUid != null;

  // "game" field.
  Game?  _game;
  Game? get game => _game;
  bool hasGame() => true;
  
  // "name" field.
  String? _name;
  String get name => _name ?? 'Unknown name';
  Future<void> setName(PocketBase pb, String newName) async {
    _name = newName;
    await updateField(pb, uid, "name", newName);
  }
  bool hasName() => _name != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  Future<void> setDate(PocketBase pb, DateTime newDate) async {
    _date = newDate;
    await updateField(pb, uid, "date", newDate);
  }
  bool hasDate() => _date != null;

  // "address" and lat long field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;
  double? _lat;
  double get latitude => _lat ?? 0;
  double? _long;
  double get longitude => _long ?? 0;
  bool hasLatLong() => _lat != null && _long != null;
  Future<void> setAddress(PocketBase pb, String newAddress, LatLng coordinates) async {
    _address = newAddress;
    _lat = coordinates.latitude;
    _long = coordinates.longitude;
    await updateFields(pb, uid, {
      "address": _address,
      "latitude": _lat,
      "longitude": _long
    });
  }

  // "capacity" field.
  int? _capacity;
  int get capacity => _capacity ?? 0;
  Future<void> setCapacity(PocketBase pb, int newCapacity) async {
    _capacity = newCapacity;
    await updateField(pb, uid, "capacity", newCapacity);
  }
  bool hasCapacity() => _capacity! > 0;

  // "preregistration-en" field.
  bool _preRegistrationEn = false;
  bool get preRegistrationEn => _preRegistrationEn;
  Future<void> switchPreRegistrationEn(PocketBase pb) async {
    _preRegistrationEn = !_preRegistrationEn;
    await updateField(pb, uid, "pre_registration_en", _preRegistrationEn);
  }
  bool hasPreRegistrationEn() => _preRegistrationEn;

  // "waitinglist-en" field.
  bool _waitingListEn = false;
  bool get waitingListEn => _waitingListEn;
  Future<void> switchWaitingListEn(PocketBase pb) async {
    _waitingListEn = !_waitingListEn;
    await updateField(pb, uid, "waiting_list_en", _waitingListEn);
  }
  bool hasWaitingListEn() => _waitingListEn;

  // "image" field.
  String? _image;
  String? get image => _image;
  Future<void> setImage(PocketBase pb, String newImage) async {
    _image = newImage;
    await updateField(pb, uid, "image", newImage);
  }
  bool hasImage() => _image != null;

  // "game" field.
  StateTournament?  _state;
  StateTournament? get state => _state;
  Future<void> setState(PocketBase pb, String newState) async {
    _state = getStateTournamentByName(newState);
    await updateField(pb, uid, "state", newState);
  }
  bool hasState() => true;

  //'winner' field
  String? _winnerUserId;
  String get winnerUserId => _winnerUserId ?? 'Unknown Id';
  Future<void> setWinnerUserId(PocketBase pb, String winnerUserId) async {
    _winnerUserId = winnerUserId;
    await updateField(pb, uid, "winner_user_id", winnerUserId);
  }
  bool hasWinner() => _winnerUserId != null;

  void _initializeFields() {
    _uid = snapshotData['id'];
    _game = getGameEnum(snapshotData['game']);
    _name = snapshotData['name'];
    _image = snapshotData['image'];
    _date = snapshotData['date'] as DateTime?;
    _address = snapshotData['address'];
    _lat = snapshotData['latitude'];
    _long = snapshotData['longitude'];
    _capacity = snapshotData['capacity'];
    _creatorUid = snapshotData['creator_uid'];
    _preRegistrationEn = snapshotData['pre_registration_en'] as bool;
    _waitingListEn = snapshotData['waiting_list_en'] as bool;
    _state = getStateEnum(snapshotData['state']);
  }

  static TournamentsRecord fromSnapshot(RecordModel snapshot) => TournamentsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<TournamentsRecord> getDocument(PocketBase pb, String id) {
    final controller = StreamController<TournamentsRecord>();

    pb.collection(collectionName).getOne(id, expand: 'id_owner').then((record) {
      if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, expand: 'id_owner', (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<TournamentsRecord>> getDocuments(PocketBase pb, String filter, {String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<TournamentsRecord>>();
    final List<TournamentsRecord> documents = [];

    pb.collection(collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: 'id_owner').then((recordList) {
      if (!controller.isClosed) {
        List<TournamentsRecord> tournamentList = recordList.items.map((record) => TournamentsRecord.fromSnapshot(record)).toList();
        documents.addAll(tournamentList);
        controller.add(tournamentList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: 'id_owner', (e) {
      if (!controller.isClosed && e.record != null) {
        TournamentsRecord record = TournamentsRecord.fromSnapshot(e.record!);

        switch (e.action) {
          case 'create':
            documents.add(record);
            break;
          case 'update':
            final index = documents.indexWhere((r) => r.uid == record.uid);
            if (index != -1) { documents[index] = record; }
            break;
          case 'delete':
            documents.removeWhere((r) => r.uid == record.uid);
            break;
        }
        controller.add(List.from(documents));
      }
    });


    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Future<TournamentsRecord> getDocumentOnce(PocketBase pb, String id) =>
      pb.collection(collectionName).getOne(id).then((s) => TournamentsRecord.fromSnapshot(s));

  static Future<void> updateField(PocketBase pb, String id, String fieldName, dynamic newValue) async {
    try {
      await pb.collection(collectionName).update(id, body: {
        fieldName: newValue,
      });
    } catch (e) {
      print("Failed to update field: $e");
    }
  }
  static Future<void> updateFields(PocketBase pb, String id, Map<String, dynamic> dataToUpdate) async {
    try {
      await pb.collection(collectionName).update(id, body: dataToUpdate);
    } catch (e) {
      print("Failed to update fields: $e");
    }
  }

  static TournamentsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      TournamentsRecord._(reference, mapFromFirestore(data));

  static Future<TournamentsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async => pb.collection(collectionName).create(body: body).then((record){
    return TournamentsRecord.fromSnapshot(record);
  });

  @override
  String toString() => 'TournamentsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
    other is TournamentsRecord && (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;

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
  required double latitude,
  required double longitude,
  int? capacity,
  required bool preRegistrationEn,
  required bool waitingListEn,
  StateTournament? state,
  required String? creatorUid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'game': game.name,
      'name': name,
      'date': date,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pre_registration_en': preRegistrationEn,
      'waiting_list_en': waitingListEn,
      'state': state != null ? state.name : StateTournament.open.name,
      'capacity': capacity ?? 0,
      'creator_uid': creatorUid,
    }.withoutNulls,
  );

  return firestoreData;
}
Map<String, dynamic> createTournamentsRecordDataFromObj(TournamentsRecord record) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': record.uid,
      'game': record.game?.name ?? Game.unknown,
      'name': record.name,
      'date': record.date,
      'address': record.address,
      'latitude': record.latitude,
      'longitude': record.longitude,
      'pre_registration_en': record.preRegistrationEn,
      'waiting_list_en': record.waitingListEn,
      'state': record.state,
      'capacity': record.capacity,
      'creator_uid': record.creatorUid,
    }.withoutNulls,
  );

  return firestoreData;
}

class TournamentsRecordDocumentEquality implements Equality<TournamentsRecord> {
  const TournamentsRecordDocumentEquality();

  @override
  bool equals(TournamentsRecord? e1, TournamentsRecord? e2) {
    return e1?.address == e2?.address &&
        e1?.latitude == e2?.latitude &&
        e1?.longitude == e2?.longitude &&
        e1?.date == e2?.date &&
        e1?.game == e2?.game &&
        e1?.uid == e2?.uid &&
        e1?.name == e2?.name &&
        e1?.image == e2?.image &&
        e1?.preRegistrationEn == e2?.preRegistrationEn &&
        e1?.waitingListEn == e2?.waitingListEn &&
        e1?.state == e2?.state &&
        e1?.creatorUid == e2?.creatorUid;
  }

  @override
  int hash(TournamentsRecord? e) => const ListEquality().hash([
    e?.address,
    e?.latitude,
    e?.longitude,
    e?.date,
    e?.game,
    e?.uid,
    e?.name,
    e?.image,
    e?.preRegistrationEn,
    e?.waitingListEn,
    e?.state,
    e?.creatorUid
  ]);

  @override
  bool isValidKey(Object? o) => o is TournamentsRecord;
}


enum Game {
  ygoAdv("Yu-Gi-Oh! Avanzato", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/ygoadv_pointer.png', Colors.orange),
  ygoRetro("Yu-Gi-Oh! Retroformat", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/ygoretro_pointer.png', Colors.deepOrangeAccent),
  lorcana("Lorcana", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/lorcana_pointer.png', Colors.deepPurpleAccent),
  onepiece("One Piece", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/onepiece_pointer.png', Colors.red),
  altered("Altered", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/altered_pointer.png', Colors.lightBlueAccent),
  magic("Magic", 'assets/images/card_back/game_ygo_adv.jpg', 'assets/images/icons/magic_pointer.png', Colors.black54),
  unknown("UNKNOWN", 'assets/images/card_back/game_ygo_adv.jpg', null, Colors.white),
  none("", 'assets/images/card_back/game_ygo_adv.jpg', null, Colors.white);

  final String desc;
  final String resource;
  final String? iconResource;
  final Color color;

  const Game(this.desc, this.resource, this.iconResource, this.color);

}

enum ListType {
  waiting("waiting_list_info"),
  preregistered("preregistered_list_info"),
  registered("registered_list_info");

  final String listName;
  const ListType(this.listName);
}

ListType getListTypeByName(String name) {
  return ListType.values.firstWhere(
        (state) => state.name == name,
    orElse: () => ListType.waiting,
  );
}

enum StateTournament {
  open("Creato", 1),
  ready("Aperto", 2),
  ongoing("In Corso", 3),
  close("Chiuso", 4),
  unknown("UNKNOWN", 0);

  final String desc;
  final int indexState;

  const StateTournament(this.desc, this.indexState);
}

StateTournament getStateTournamentByName(String name) {
  return StateTournament.values.firstWhere(
        (state) => state.name == name,
    orElse: () => StateTournament.unknown,
  );
}