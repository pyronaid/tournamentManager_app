import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class DeviceTokensRecord extends PocketstoreRecord {
  static const String collectionName = "device_tokens";
  
  static const String idFieldName = 'id';
  static const String idUserFieldName = 'id_user';
  static const String fcmTokenFieldName = 'fcmToken';
  static const String deviceTypeFieldName = 'deviceType';
  static const String lastActiveFieldName = 'lastActive';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  DeviceTokensRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late String _uid;
  String get uid => _uid;

  late String _userId;
  String get userId => _userId;

  late String _fcmToken;
  String get fcmToken => _fcmToken;

  late DeviceType _deviceType;
  DeviceType get deviceType => _deviceType;

  late DateTime _lastActive;
  DateTime get lastActive => _lastActive;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;


  void _initializeFields() {
  
    _uid = snapshotData[idFieldName];
    _userId = snapshotData[idUserFieldName];
    _fcmToken = snapshotData[fcmTokenFieldName];
    _deviceType = getDeviceTypeByName(snapshotData[deviceTypeFieldName]);
    _lastActive = tryParseDate(snapshotData[lastActiveFieldName])!;
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

  }

  static DeviceTokensRecord fromSnapshot(RecordModel snapshot) => DeviceTokensRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<DeviceTokensRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<DeviceTokensRecord>();

    pb.collection(collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(DeviceTokensRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(DeviceTokensRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<DeviceTokensRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<DeviceTokensRecord>>();
    final List<DeviceTokensRecord> documents = [];

    pb.collection(collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<DeviceTokensRecord> newsList = recordList.items.map((record) => DeviceTokensRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        DeviceTokensRecord record = DeviceTokensRecord.fromSnapshot(e.record!);

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
  static Future<DeviceTokensRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionName).getOne(id, expand: expand).then((s) => DeviceTokensRecord.fromSnapshot(s));
  static Future<List<DeviceTokensRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => DeviceTokensRecord.fromSnapshot(record)).toList()
      ).catchError(
              (e) => print(e)
      );
  static Future<void> deleteDeviceToken(pb, String idDT) async {
    pb.collection(collectionName).delete(idDT);
  }
  static Future<RecordModel> createDeviceToken(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
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
      rethrow;
    }
  }

  static DeviceTokensRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      DeviceTokensRecord._(reference, mapFromFirestore(data));

  static Future<DeviceTokensRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => DeviceTokensRecord.fromSnapshot(record));

  @override
  String toString() =>
      'DeviceTokensRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is DeviceTokensRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}

Map<String, dynamic> createDeviceTokensRecordData({
  String? uid,
  required String fcmToken,
  required DeviceType deviceType,
  DateTime? lastActive,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      DeviceTokensRecord.idFieldName: uid,
      DeviceTokensRecord.fcmTokenFieldName: fcmToken,
      DeviceTokensRecord.deviceTypeFieldName: deviceType.name,
      DeviceTokensRecord.lastActiveFieldName: lastActive ?? DateTime.now(),
    }.withoutNulls,
  );

  return pocketstoreData;
}

class DeviceTokensRecordDocumentEquality implements Equality<DeviceTokensRecord> {
  const DeviceTokensRecordDocumentEquality();

  @override
  bool equals(DeviceTokensRecord? e1, DeviceTokensRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.fcmToken == e2?.fcmToken &&
        e1?.deviceType == e2?.deviceType &&
        e1?.lastActive == e2?.lastActive;
  }

  @override
  int hash(DeviceTokensRecord? e) => const ListEquality().hash([
    e?.uid,
    e?.fcmToken,
    e?.deviceType,
    e?.lastActive,
  ]);

  @override
  bool isValidKey(Object? o) => o is DeviceTokensRecord;
}

enum DeviceType {
  ios("iOs"),
  android("Android"),
  web("Web"),
  unknown("UNKNOWN");

  final String desc;

  const DeviceType(this.desc);
}

DeviceType getDeviceTypeByName(String name) {
  return DeviceType.values.firstWhere(
        (state) => state.name == name,
    orElse: () => DeviceType.unknown,
  );
}
