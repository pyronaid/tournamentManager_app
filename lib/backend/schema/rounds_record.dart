import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class RoundsRecord extends PocketstoreRecord {
  static const String collectionName = "rounds";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String indexFieldName = 'index';
  static const String populationFieldName = 'population';
  static const String roundKindFieldName = 'roundKind';
  static const String completedFieldName = 'completed';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String idOwnerFieldName = 'id_owner';

  RoundsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late String _uid;
  String get uid => _uid;

  late String _tournamentId;
  String get tournamentId => _tournamentId;

  late int _index;
  int get index => _index;

  late int _population;
  int get population => _population;

  late RoundKind _roundKind;
  RoundKind get roundKind => _roundKind;

  late bool _completed;
  bool get completed => _completed;

  late String _ownerId;
  String get ownerId => _ownerId;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;


  void _initializeFields() {
    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _index = snapshotData[indexFieldName];
    _population = snapshotData[populationFieldName];
    _roundKind = getRoundKindEnum(snapshotData[roundKindFieldName]);
    _completed = snapshotData[completedFieldName] != null ? snapshotData[completedFieldName] == 1 : false;
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

    _ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
  }

  static RoundsRecord fromSnapshot(RecordModel snapshot) => RoundsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<RoundsRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<RoundsRecord>();

    pb.collection(collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(RoundsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(RoundsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<RoundsRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<RoundsRecord>>();
    final List<RoundsRecord> documents = [];

    pb.collection(collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<RoundsRecord> newsList = recordList.items.map((record) => RoundsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        RoundsRecord record = RoundsRecord.fromSnapshot(e.record!);

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
  static Future<RoundsRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionName).getOne(id, expand: expand).then((s) => RoundsRecord.fromSnapshot(s));
  static Future<List<RoundsRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => RoundsRecord.fromSnapshot(record)).toList()
      );
  static Future<void> deleteRound(pb, String idR) async {
    pb.collection(collectionName).delete(idR);
  }
  static Future<RecordModel> createRound(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
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

  static RoundsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      RoundsRecord._(reference, mapFromFirestore(data));

  static Future<RoundsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => RoundsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'RoundsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is RoundsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;

  RoundKind getRoundKindEnum(stringValue) {
    return RoundKind.values.firstWhere(
          (e) => e.name == stringValue,
      orElse: () => RoundKind.swiss,
    );
  }
}

Map<String, dynamic> createRoundsRecordData({
  String? uid,
  required String tournamentId,
  required RoundKind roundKind,
  required int index,
  required int population,
  required bool completed,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      RoundsRecord.idFieldName: uid,
      RoundsRecord.idTournamentFieldName: tournamentId,
      RoundsRecord.indexFieldName: index,
      RoundsRecord.populationFieldName: population,
      RoundsRecord.completedFieldName: completed ? 1 : 0,
      RoundsRecord.roundKindFieldName: roundKind.name,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class RoundsRecordDocumentEquality implements Equality<RoundsRecord> {
  const RoundsRecordDocumentEquality();

  @override
  bool equals(RoundsRecord? e1, RoundsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.index == e2?.index &&
        e1?.population == e2?.population &&
        e1?.roundKind == e2?.roundKind &&
        e1?.completed == e2?.completed;
  }

  @override
  int hash(RoundsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.index,
    e?.population,
    e?.roundKind,
    e?.completed,
  ]);

  @override
  bool isValidKey(Object? o) => o is RoundsRecord;
}


enum RoundKind {
  swiss("Svizzera"),
  topcut("TopCut");

  final String desc;

  const RoundKind(this.desc);
}

RoundKind getRoundKindByName(String name) {
  return RoundKind.values.firstWhere(
        (state) => state.name == name,
    orElse: () => RoundKind.swiss,
  );
}