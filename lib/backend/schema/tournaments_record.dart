
import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class TournamentsRecord extends PocketstoreRecord {
  static const String collectionNameExt = "tournament_with_stats";
  static const String collectionName = "tournaments";
  static const String idFieldName = 'id';
  static const String idOwnerFieldName = 'id_owner';
  static const String nameFieldName = 'name';
  static const String capacityFieldName = 'capacity';
  static const String dateFieldName = 'date';
  static const String gameFieldName = 'game';
  static const String stateFieldName = 'state';
  static const String imageFieldName = 'image';
  static const String preRegistrationFieldName = 'preRegistrationEn';
  static const String waitingListFieldName = 'waitingListEn';
  static const String isOnlineFieldName = 'isOnline';
  static const String addressFieldName = 'address';
  static const String latitudeFieldName = 'latitude';
  static const String longitudeFieldName = 'longitude';
  static const String idWinnerFieldName = 'id_winner';
  static const String lastUpdatedNewsFieldName = 'lastUpdated_news';
  static const String lastUpdatedEnrollmentsFieldName = 'lastUpdated_enrollments';
  static const String lastUpdatedRoundsFieldName = 'lastUpdated_rounds';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionIdSourceFieldName = 'collectionIdSource';
  static const String collectionNameFieldName = 'collectionName';

  static const String preRegisteredCountFieldName = 'preRegisteredCount';
  static const String registeredCountFieldName = 'registeredCount';
  static const String waitingCountFieldName = 'waitingCount';


  TournamentsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late final bool extFlag;

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
    await updateField(pb, uid, nameFieldName, newName);
  }
  bool hasName() => _name != null;

  late DateTime? _date;
  DateTime? get date => _date;
  Future<void> setDate(PocketBase pb, DateTime newDate) async {
    _date = newDate;
    await updateField(pb, uid, dateFieldName, newDate.toString());
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
      addressFieldName: _address,
      latitudeFieldName: _lat,
      longitudeFieldName: _long
    });
  }

  late int? _capacity;
  int get capacity => _capacity ?? 0;
  Future<void> setCapacity(PocketBase pb, int newCapacity) async {
    _capacity = newCapacity;
    await updateField(pb, uid, capacityFieldName, newCapacity);
  }
  bool hasCapacity() => _capacity! > 0;

  late bool _preRegistrationEn = false;
  bool get preRegistrationEn => _preRegistrationEn;
  Future<void> switchPreRegistrationEn(PocketBase pb) async {
    _preRegistrationEn = !_preRegistrationEn;
    await updateField(pb, uid, preRegistrationFieldName, _preRegistrationEn);
  }

  late bool _waitingListEn = false;
  bool get waitingListEn => _waitingListEn;
  Future<void> switchWaitingListEn(PocketBase pb) async {
    _waitingListEn = !_waitingListEn;
    await updateField(pb, uid, waitingListFieldName, _waitingListEn);
  }

  late bool _isOnlineEn = false;
  bool get isOnlineEn => _isOnlineEn;
  Future<void> switchIsOnlineEn(PocketBase pb) async {
    _isOnlineEn = !_isOnlineEn;
    await updateField(pb, uid, isOnlineFieldName, _isOnlineEn);
  }

  late String? _image;
  String? get image => _image;
  Future<void> setImage(PocketBase pb, {required List<MultipartFile> files}) async {
    for(MultipartFile file in files) {
      _image = getFileUrl(snapshotData[extFlag ? collectionIdSourceFieldName : collectionIdFieldName], snapshotData[idFieldName], file.filename);
      await updateFiles(pb, uid, files: [file]);
    }
  }
  bool hasImage() => _image != null;

  late StateTournament  _state;
  StateTournament get state => _state;
  Future<void> setState(PocketBase pb, String newState) async {
    StateTournament oldState = state;
    _state = getStateTournamentByName(newState);
    if(oldState == StateTournament.close && state != StateTournament.close){
      await updateField(pb, uid, idWinnerFieldName, null);
    }
    await updateField(pb, uid, stateFieldName, newState);
  }

  late List<dynamic>? _winnerId;
  List<dynamic>? get winnerUserId => _winnerId;
  Future<void> setWinnerUserId(PocketBase pb, List<dynamic> winnerUserId) async {
    _winnerId = winnerUserId;
    await updateField(pb, uid, idWinnerFieldName, winnerUserId);
  }
  bool hasWinner() => _winnerId != null && _winnerId!.isNotEmpty;

  late int _preRegisteredCount;
  int get preRegisteredCount => _preRegisteredCount;

  late int _registeredCount;
  int get registeredCount => _registeredCount;

  late int _waitingCount;
  int get waitingCount => _waitingCount;

  late DateTime? _lastUpdatedNews;
  DateTime? get lastUpdatedNews => _lastUpdatedNews;

  late DateTime? _lastUpdatedEnrollments;
  DateTime? get lastUpdatedEnrollments => _lastUpdatedEnrollments;

  late DateTime? _lastUpdatedRounds;
  DateTime? get lastUpdatedRounds => _lastUpdatedRounds;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;

  void _initializeFields() {

    if(snapshotData.containsKey(preRegisteredCountFieldName)) {
      _preRegisteredCount = snapshotData[preRegisteredCountFieldName];
    } else { _preRegisteredCount = 0; }
    if(snapshotData.containsKey(waitingCountFieldName)) {
      _waitingCount = snapshotData[waitingCountFieldName];
    } else { _waitingCount = 0; }
    if(snapshotData.containsKey(registeredCountFieldName)) {
      extFlag = true;
      _registeredCount = snapshotData[registeredCountFieldName];
    } else {
      extFlag = false;
      _registeredCount = 0;
    }

    _uid = snapshotData[idFieldName];
    _name = snapshotData[nameFieldName];
    _capacity = snapshotData[capacityFieldName];
    _date = tryParseDate(snapshotData[dateFieldName])!;
    _game = getGameEnum(snapshotData[gameFieldName]);
    _state = getStateEnum(snapshotData[stateFieldName])!;
    _image = getFileUrl(snapshotData[extFlag ? collectionIdSourceFieldName : collectionIdFieldName], snapshotData[idFieldName], snapshotData[imageFieldName]);
    _preRegistrationEn = snapshotData[preRegistrationFieldName] ?? false;
    _waitingListEn = snapshotData[waitingListFieldName] ?? false;
    _isOnlineEn = snapshotData[isOnlineFieldName] ?? false;
    _address = snapshotData[addressFieldName];
    _lat = snapshotData[latitudeFieldName];
    _long = snapshotData[longitudeFieldName];
    _winnerId = snapshotData[idWinnerFieldName];
    if(_winnerId != null) {
      _winnerId = _winnerId!.where((obj) => obj is String || (obj is Map && obj[idFieldName] != null)).toList();
    }
    _ownerId = snapshotData[idOwnerFieldName];

    _lastUpdatedNews = tryParseDate(snapshotData[lastUpdatedNewsFieldName]);
    _lastUpdatedEnrollments = tryParseDate(snapshotData[lastUpdatedEnrollmentsFieldName]);
    _lastUpdatedRounds = tryParseDate(snapshotData[lastUpdatedRoundsFieldName]);

    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];
  }

  static TournamentsRecord fromSnapshot(RecordModel snapshot) => TournamentsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<TournamentsRecord> getDocument(PocketBase pb, bool ext, String id) {
    final controller = StreamController<TournamentsRecord>();

    pb.collection(ext ? collectionNameExt : collectionName).getOne(id, expand: idOwnerFieldName).then((record) {
      if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe(id, expand: idOwnerFieldName, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(TournamentsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(ext ? collectionNameExt : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<TournamentsRecord>> getDocuments(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<TournamentsRecord>>();
    final List<TournamentsRecord> documents = [];

    pb.collection(ext ? collectionNameExt : collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand !=null ? '$expand,$idOwnerFieldName':idOwnerFieldName).then((recordList) {
      if (!controller.isClosed) {
        List<TournamentsRecord> tournamentList = recordList.items.map((record) => TournamentsRecord.fromSnapshot(record)).toList();
        documents.addAll(tournamentList);
        controller.add(tournamentList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand !=null ? '$expand,$idOwnerFieldName':idOwnerFieldName, (e) {
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
      pb.collection(collectionNameExt).unsubscribe();
    };

    return controller.stream;
  }
  static Future<TournamentsRecord> getDocumentOnce(PocketBase pb, bool ext, String id) =>
      pb.collection(ext ? collectionNameExt : collectionName).getOne(id).then((s) => TournamentsRecord.fromSnapshot(s));
  static Future<List<TournamentsRecord>> getDocumentsOnce(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand !=null ? '$expand,$idOwnerFieldName':idOwnerFieldName,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => TournamentsRecord.fromSnapshot(record)).toList()
      );

  static Future<void> updateFiles(PocketBase pb, String id, {required List<MultipartFile> files}) async {
    try {
      await pb.collection(collectionName).update(id,
        files: files,
      );
    } catch (e) {
      print("Failed to update field: $e");
    }
  }
  static Future<void> updateField(PocketBase pb, String id, String fieldName, dynamic newValue, {List<MultipartFile>? files}) async {
    try {
      await pb.collection(collectionName).update(id,
        body: {
          fieldName: newValue,
        },
        files: files ?? [],
      );
    } catch (e) {
      print("Failed to update field: $e");
    }
  }
  static Future<void> updateFields(PocketBase pb, String id, Map<String, dynamic> dataToUpdate, {List<MultipartFile>? files}) async {
    try {
      await pb.collection(collectionName).update(id,
        body: dataToUpdate,
        files: files ?? [],
      );
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
  required bool isOnlineEn,
  StateTournament? state,
  required String? creatorUid,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      TournamentsRecord.gameFieldName: game.name,
      TournamentsRecord.nameFieldName: name,
      TournamentsRecord.dateFieldName: date.toIso8601String(),
      TournamentsRecord.addressFieldName: address,
      TournamentsRecord.latitudeFieldName: latitude,
      TournamentsRecord.longitudeFieldName: longitude,
      TournamentsRecord.preRegistrationFieldName: preRegistrationEn ? 1 : 0,
      TournamentsRecord.waitingListFieldName: waitingListEn ? 1 : 0,
      TournamentsRecord.isOnlineFieldName: isOnlineEn ? 1 : 0,
      TournamentsRecord.stateFieldName: state != null ? state.name : StateTournament.open.name,
      TournamentsRecord.capacityFieldName: capacity ?? 0,
      TournamentsRecord.idOwnerFieldName: creatorUid,
    }.withoutNulls,
  );

  return pocketstoreData;
}
Map<String, dynamic> createTournamentsRecordDataFromObj(TournamentsRecord record) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      TournamentsRecord.idFieldName: record.uid,
      TournamentsRecord.gameFieldName: record.game.name,
      TournamentsRecord.nameFieldName: record.name,
      TournamentsRecord.dateFieldName: record.date,
      TournamentsRecord.addressFieldName: record.address,
      TournamentsRecord.latitudeFieldName: record.latitude,
      TournamentsRecord.longitudeFieldName: record.longitude,
      TournamentsRecord.preRegistrationFieldName: record.preRegistrationEn,
      TournamentsRecord.waitingListFieldName: record.waitingListEn,
      TournamentsRecord.isOnlineFieldName: record.isOnlineEn,
      TournamentsRecord.stateFieldName: record.state,
      TournamentsRecord.capacityFieldName: record.capacity,
      TournamentsRecord.idOwnerFieldName: record.ownerId,
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
        e1?.isOnlineEn == e2?.isOnlineEn &&
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
    e?.isOnlineEn,
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

bool containsSameGames(List<Game> list1, List<Game> list2){
  if(list1.length != list2.length) { return false; }
  for(var g in list1){
    if(!list2.contains(g)){ return false; }
  }
  return true;
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
