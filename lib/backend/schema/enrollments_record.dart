import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';
import 'package:tuple/tuple.dart';

class EnrollmentsRecord extends PocketstoreRecord {
  static const String collectionNameExt = "enrollments_extended";
  static const String collectionName = "enrollments";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String idUserFieldName = 'id_user';
  static const String listKindFieldName = 'listKind';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String nameFieldName = 'name';
  static const String surnameFieldName = 'surname';
  static const String usernameFieldName = 'username';
  static const String idOwnerFieldName = 'id_owner';


  EnrollmentsRecord._(
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

  late String _userId;
  String get userId => _userId;

  late ListType _listKind;
  ListType get listKind => _listKind ;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;
  bool hasCreatedTime() => true;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;
  bool hasUpdatedTime() => true;

  // ignore: unused_field
  late String _collectionId;
  // ignore: unused_field
  late String _collectionName;

  late String _ownerId;
  String get ownerId => _ownerId;

  late String _name;
  String get name => _name;

  late String _surname;
  String get surname => _surname;

  late String _username;
  String get username => _username;

  void _initializeFields() {
    if(snapshotData.containsKey(idOwnerFieldName)) {
      extFlag = true;
      _ownerId = snapshotData[idOwnerFieldName];
    } else {
      extFlag = false;
      _ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
    }
    if(snapshotData.containsKey(nameFieldName)) {
      _name = snapshotData[nameFieldName];
    } else {
      _name = getExpandendValue(snapshotData['expand'], idUserFieldName, nameFieldName)!;
    }
    if(snapshotData.containsKey(surnameFieldName)) {
      _surname = snapshotData[surnameFieldName];
    } else {
      _surname = getExpandendValue(snapshotData['expand'], idUserFieldName, surnameFieldName)!;
    }
    if(snapshotData.containsKey(usernameFieldName)) {
      _username = snapshotData[usernameFieldName];
    } else {
      _username = getExpandendValue(snapshotData['expand'], idUserFieldName, usernameFieldName)!;
    }

    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _userId = snapshotData[idUserFieldName];
    _listKind = getListTypeEnum(snapshotData[listKindFieldName]);
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];
  }

  static EnrollmentsRecord fromSnapshot(RecordModel snapshot) => EnrollmentsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<EnrollmentsRecord> getDocument(PocketBase pb, bool ext, String id, {String? expand}) {
    final controller = StreamController<EnrollmentsRecord>();

    pb.collection(ext ? collectionNameExt : collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(EnrollmentsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(EnrollmentsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(ext ? collectionNameExt : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<EnrollmentsRecord>> getDocuments(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<EnrollmentsRecord>>();
    final List<EnrollmentsRecord> documents = [];

    pb.collection(ext ? collectionNameExt : collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<EnrollmentsRecord> newsList = recordList.items.map((record) => EnrollmentsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        EnrollmentsRecord record = EnrollmentsRecord.fromSnapshot(e.record!);

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
      pb.collection(ext ? collectionNameExt : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Future<EnrollmentsRecord> getDocumentOnce(PocketBase pb, bool ext, String id, {String? expand}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getOne(id, expand: expand).then((s) => EnrollmentsRecord.fromSnapshot(s));
  static Future<Tuple2<int,List<EnrollmentsRecord>>> getDocumentsOnce(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => Tuple2(
                  s.totalItems,
                  s.items.map((record) => EnrollmentsRecord.fromSnapshot(record)).toList())
              );
  static Future<void> deleteEnrollments(pb, String idE) async {
    pb.collection(collectionName).delete(idE);
  }
  static Future<RecordModel> createEnrollments(PocketBase pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
    return pb.collection(collectionName).create(
      body: mapObj,
      files: files??[],
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

  static EnrollmentsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      EnrollmentsRecord._(reference, mapFromFirestore(data));

  static Future<EnrollmentsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => EnrollmentsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'EnrollmentsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is EnrollmentsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;

  ListType getListTypeEnum(stringValue) {
    return ListType.values.firstWhere(
          (e) => e.name == stringValue,
      orElse: () => ListType.registered,
    );
  }
}


Map<String, dynamic> createEnrollmentsRecordData({
  String? uid,
  required String tournamentId,
  required String userId,
  required ListType listKind,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      EnrollmentsRecord.idFieldName: uid,
      EnrollmentsRecord.idTournamentFieldName: tournamentId,
      EnrollmentsRecord.idUserFieldName: userId,
      EnrollmentsRecord.listKindFieldName: listKind,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class EnrollmentsRecordDocumentEquality implements Equality<EnrollmentsRecord> {
  const EnrollmentsRecordDocumentEquality();

  @override
  bool equals(EnrollmentsRecord? e1, EnrollmentsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.userId == e2?.userId &&
        e1?.listKind == e2?.listKind;
  }

  @override
  int hash(EnrollmentsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.userId,
    e?.listKind
  ]);

  @override
  bool isValidKey(Object? o) => o is EnrollmentsRecord;
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