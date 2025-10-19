import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class RankingsRecord extends PocketstoreRecord {
  static const String collectionName = "rankings";
  static const String collectionNameExt = "rankings_extended";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String idRoundFieldName = 'id_round';
  static const String idUserFieldName = 'id_user';
  static const String userNameFieldName = 'userName';
  static const String userSurnameFieldName = 'userSurname';
  static const String userUsernameFieldName = 'userUsername';
  static const String isDropFieldName = 'isDrop';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String currentRoundIndexFieldName = 'currentRoundIndex';
  static const String roundIndexFieldName = 'roundIndex';
  static const String pointsFieldName = 'points';
  static const String t1FieldName = 'T1';
  static const String t2FieldName = 'T2';
  static const String t3FieldName = 'T3';

  RankingsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late final bool extFlag;

  late String _uid;
  String get uid => _uid;

  late String _tournamentId;
  String get tournamentId => _tournamentId;

  late String _roundId;
  String get roundId => _roundId;

  late String _userId;
  String get userId => _userId;

  late String _userName;
  String get userName => _userName;

  late String _userSurname;
  String get userSurname => _userSurname;

  late String _userUsername;
  String get userUsername => _userUsername;

  late bool _isDrop;
  bool get isDrop => _isDrop;  

  late int _currentRoundIndex;
  int get currentRoundIndex => _currentRoundIndex;

  late int _points;
  int get points => _points;

  late double _t1;
  double get t1 => _t1;

  late double _t2;
  double get t2 => _t2;

  late double _t3;
  double get t3 => _t3;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;


  void _initializeFields() {
    if(snapshotData.containsKey(currentRoundIndexFieldName)) {
      _currentRoundIndex = snapshotData[currentRoundIndexFieldName];
    } else { _currentRoundIndex = getExpandendValue(snapshotData['expand'], idRoundFieldName, roundIndexFieldName)!; }
    if(snapshotData.containsKey(userNameFieldName)) {
      _userName = snapshotData[userNameFieldName];
    } else { _userName = '';}
    if(snapshotData.containsKey(userSurnameFieldName)) {
      _userSurname = snapshotData[userSurnameFieldName];
    } else { _userSurname = '';}
    if(snapshotData.containsKey(userUsernameFieldName)) {
      _userUsername = snapshotData[userUsernameFieldName];
    } else { _userUsername = '';}
    if(snapshotData.containsKey(isDropFieldName)) {
      _isDrop = snapshotData[isDropFieldName] == 1;
    } else { _isDrop = false;}
    if(snapshotData.containsKey(pointsFieldName)) {
      _points = snapshotData[pointsFieldName];
    } else { _points = 0;}
    if(snapshotData.containsKey(t1FieldName)) {
      _t1 = snapshotData[t1FieldName].toDouble();
    } else { _t1 = 0.0;}
    if(snapshotData.containsKey(t2FieldName)) {
      _t2 = snapshotData[t2FieldName].toDouble();
    } else { _t2 = 0.0;}
    if(snapshotData.containsKey(t3FieldName)) {
      extFlag = true;
      _t3 = snapshotData[t3FieldName].toDouble();
    } else { 
      extFlag = false;
      _t3 = 0.0;
    }

    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _roundId = snapshotData[idRoundFieldName];
    _userId = snapshotData[idUserFieldName];

    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

    //_ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
  }

  static RankingsRecord fromSnapshot(RecordModel snapshot) => RankingsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<RankingsRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<RankingsRecord>();

    pb.collection(collectionNameExt).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(RankingsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionNameExt).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(RankingsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionNameExt).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<RankingsRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<RankingsRecord>>();
    final List<RankingsRecord> documents = [];

    pb.collection(collectionNameExt).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<RankingsRecord> newsList = recordList.items.map((record) => RankingsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionNameExt).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        RankingsRecord record = RankingsRecord.fromSnapshot(e.record!);

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
  static Future<RankingsRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionNameExt).getOne(id, expand: expand).then((s) => RankingsRecord.fromSnapshot(s));
  static Future<List<RankingsRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionNameExt).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => RankingsRecord.fromSnapshot(record)).toList()
      );
  static Future<void> deletePairing(pb, String idP) async {
    pb.collection(collectionName).delete(idP);
  }
  static Future<RecordModel> createPairing(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
    return pb.collection(collectionName).create(
      body: mapObj,
      files: files,
    );
  }

  static Future<void> updateField(PocketBase pb, String id, String fieldName, dynamic newValue, {List<MultipartFile>? files}) async {
    try {
      await pb.collection(collectionName).update(id,
        body: {
          fieldName: formatForPocketBase(newValue),
        },
        files: files ?? [],
      );
    } catch (e) {
      print("Failed to update field: $e");
    }
  }
  static Future<void> updateFields(PocketBase pb, String id, Map<String, dynamic> dataToUpdate, {List<MultipartFile>? files}) async {
    try {
      Map<String, dynamic> convertedMap = dataToUpdate.map((key, value) => MapEntry(key, formatForPocketBase(value)));
      await pb.collection(collectionName).update(id,
        body: convertedMap,
        files: files ?? [],
      );
    } catch (e) {
      print("Failed to update fields: $e");
    }
  }

  static RankingsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      RankingsRecord._(reference, mapFromFirestore(data));

  static Future<RankingsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => RankingsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'RankingRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is RankingsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}

Map<String, dynamic> createRankingsRecordData({
  String? uid,
  required String tournamentId,
  required String roundId,
  required String userId,
  bool isDrop = false,
  required int currentRoundIndex,
  int points = 0,
  double t1 = 0.0,
  double t2 = 0.0,
  double t3 = 0.0,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      RankingsRecord.idFieldName: uid,
      RankingsRecord.idTournamentFieldName: tournamentId,
      RankingsRecord.idRoundFieldName: roundId,
      RankingsRecord.idUserFieldName: userId,
      RankingsRecord.isDropFieldName: isDrop,
      RankingsRecord.currentRoundIndexFieldName: currentRoundIndex,
      RankingsRecord.pointsFieldName: points,
      RankingsRecord.t1FieldName: t1,
      RankingsRecord.t2FieldName: t2,
      RankingsRecord.t3FieldName: t3,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class RankingsRecordDocumentEquality implements Equality<RankingsRecord> {
  const RankingsRecordDocumentEquality();

  @override
  bool equals(RankingsRecord? e1, RankingsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.tournamentId == e2?.tournamentId &&
        e1?.roundId == e2?.roundId &&
        e1?.userId == e2?.userId &&
        e1?.isDrop == e2?.isDrop &&
        e1?.currentRoundIndex == e2?.currentRoundIndex &&
        e1?.points == e2?.points &&
        e1?.t1 == e2?.t1 &&
        e1?.t2 == e2?.t2 &&
        e1?.t3 == e2?.t3;
  }

  @override
  int hash(RankingsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.roundId,
    e?.userId,
    e?.isDrop,
    e?.currentRoundIndex,
    e?.points,
    e?.t1,
    e?.t2,
    e?.t3,
  ]);

  @override
  bool isValidKey(Object? o) => o is RankingsRecord;
}
