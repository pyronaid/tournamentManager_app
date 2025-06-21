
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class TournamentsRecord extends PocketstoreRecord {
  static const String collectionNameStats = "tournament_with_stats";
  static const String collectionName = "tournaments";

  TournamentsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late String _uid;
  String get uid => _uid;

  late String _ownerId;
  String get ownerId => _ownerId;

  late Game  _game;
  Game get game => _game;

  late String? _name;
  String get name => _name ?? 'N/A';
  Future<void> setName(PocketBase pb, String newName) async {
    _name = newName;
    await updateField(pb, uid, "name", newName);
  }
  bool hasName() => _name != null;

  late DateTime? _date;
  DateTime? get date => _date;
  Future<void> setDate(PocketBase pb, DateTime newDate) async {
    _date = newDate;
    await updateField(pb, uid, "date", newDate);
  }
  bool hasDate() => _date != null;

  late String? _address;
  String get address => _address ?? 'N/A';
  bool hasAddress() => _address != null;
  late double? _lat;
  double get latitude => _lat ?? 0;
  late double? _long;
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

  late int? _capacity;
  int get capacity => _capacity ?? 0;
  Future<void> setCapacity(PocketBase pb, int newCapacity) async {
    _capacity = newCapacity;
    await updateField(pb, uid, "capacity", newCapacity);
  }
  bool hasCapacity() => _capacity! > 0;

  late bool _preRegistrationEn = false;
  bool get preRegistrationEn => _preRegistrationEn;
  Future<void> switchPreRegistrationEn(PocketBase pb) async {
    _preRegistrationEn = !_preRegistrationEn;
    await updateField(pb, uid, "pre_registration_en", _preRegistrationEn);
  }

  late bool _waitingListEn = false;
  bool get waitingListEn => _waitingListEn;
  Future<void> switchWaitingListEn(PocketBase pb) async {
    _waitingListEn = !_waitingListEn;
    await updateField(pb, uid, "waiting_list_en", _waitingListEn);
  }

  late String? _image;
  String? get image => _image;
  Future<void> setImage(PocketBase pb, String newImage) async {
    _image = newImage;
    await updateField(pb, uid, "image", newImage);
  }
  bool hasImage() => _image != null;

  late StateTournament  _state;
  StateTournament get state => _state;
  Future<void> setState(PocketBase pb, String newState) async {
    _state = getStateTournamentByName(newState);
    await updateField(pb, uid, "state", newState);
  }

  late String? _winnerId;
  String? get winnerUserId => _winnerId;
  Future<void> setWinnerUserId(PocketBase pb, String winnerUserId) async {
    _winnerId = winnerUserId;
    await updateField(pb, uid, "winnerId", winnerUserId);
  }
  bool hasWinner() => _winnerId != null;

  late int _preRegisteredCount;
  int get preRegisteredCount => _preRegisteredCount;

  late int _registeredCount;
  int get registeredCount => _registeredCount;

  late int _waitingCount;
  int get waitingCount => _waitingCount;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;

  void _initializeFields() {
    _uid = snapshotData['id'];
    _name = snapshotData['name'];
    _capacity = snapshotData['capacity'];
    _date = tryParseDate(snapshotData['date'])!;
    _game = getGameEnum(snapshotData['game']);
    _state = getStateEnum(snapshotData['state'])!;
    _image = getFileUrl(snapshotData['collectionId'], snapshotData['id'], snapshotData['image']);
    _preRegistrationEn = snapshotData['preRegistrationEn'] != null ? snapshotData['preRegistrationEn'] == 1 : false;
    _waitingListEn = snapshotData['waitingListEn'] != null ? snapshotData['waitingListEn'] == 1 : false;
    _address = snapshotData['address'];
    _lat = snapshotData['latitude'];
    _long = snapshotData['longitude'];
    _winnerId = snapshotData['id_winner'];
    _ownerId = snapshotData['id_owner'];

    if(snapshotData.containsKey('preRegisteredCount')) { _preRegisteredCount = snapshotData['preRegisteredCount']; }
    if(snapshotData.containsKey('registeredCount')) { _registeredCount = snapshotData['registeredCount']; }
    if(snapshotData.containsKey('waitingCount')) { _waitingCount = snapshotData['waitingCount']; }

    _createdTime = tryParseDate(snapshotData['created'])!;
    _updatedTime = tryParseDate(snapshotData['updated'])!;
    _collectionId = snapshotData['collectionId'];
    _collectionName = snapshotData['collectionName'];
  }

  static TournamentsRecord fromSnapshot(RecordModel snapshot) => TournamentsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<TournamentsRecord> getDocument(PocketBase pb, bool stats, String id) {
    final controller = StreamController<TournamentsRecord>();

    pb.collection(stats ? collectionNameStats : collectionName).getOne(id, expand: 'id_owner').then((record) {
      if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(stats ? collectionNameStats : collectionName).subscribe(id, expand: 'id_owner', (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(stats ? collectionNameStats : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<TournamentsRecord>> getDocuments(PocketBase pb, bool stats, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<TournamentsRecord>>();
    final List<TournamentsRecord> documents = [];

    pb.collection(stats ? collectionNameStats : collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand !=null ? '$expand,id_owner':'id_owner').then((recordList) {
      if (!controller.isClosed) {
        List<TournamentsRecord> tournamentList = recordList.items.map((record) => TournamentsRecord.fromSnapshot(record)).toList();
        documents.addAll(tournamentList);
        controller.add(tournamentList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(stats ? collectionNameStats : collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand !=null ? '$expand,id_owner':'id_owner', (e) {
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
      pb.collection(collectionNameStats).unsubscribe();
    };

    return controller.stream;
  }
  static Future<TournamentsRecord> getDocumentOnce(PocketBase pb, bool stats, String id) =>
      pb.collection(stats ? collectionNameStats : collectionName).getOne(id).then((s) => TournamentsRecord.fromSnapshot(s));
  static Future<List<TournamentsRecord>> getDocumentsOnce(PocketBase pb, bool stats, String filter, {String? expand, String? sorting, int page=1, int perPage = 30}) =>
      pb.collection(stats ? collectionNameStats : collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand !=null ? '$expand,id_owner':'id_owner').then(
              (s) => s.items.map(
                  (record) => TournamentsRecord.fromSnapshot(record)).toList()
      );

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

  static Future<TournamentsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => TournamentsRecord.fromSnapshot(record));

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
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      'game': game.name,
      'name': name,
      'date': date.toIso8601String(),
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'preRegistrationEn': preRegistrationEn ? 1 : 0,
      'waitingListEn': waitingListEn ? 1 : 0,
      'state': state != null ? state.name : StateTournament.open.name,
      'capacity': capacity ?? 0,
      'id_owner': creatorUid,
    }.withoutNulls,
  );

  return pocketstoreData;
}
Map<String, dynamic> createTournamentsRecordDataFromObj(TournamentsRecord record) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      'uid': record.uid,
      'game': record.game.name,
      'name': record.name,
      'date': record.date,
      'address': record.address,
      'latitude': record.latitude,
      'longitude': record.longitude,
      'preRegistrationEn': record.preRegistrationEn,
      'waitingListEn': record.waitingListEn,
      'state': record.state,
      'capacity': record.capacity,
      'id_owner': record.ownerId,
    }.withoutNulls,
  );

  return pocketstoreData;
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
        e1?.ownerId == e2?.ownerId;
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
    e?.ownerId
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