import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/rounds_record.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class NotificationLogsRecord extends PocketstoreRecord {
  static const String collectionName = "device_tokens";
  
  static const String idFieldName = 'id';
  static const String titleFieldName = 'title';
  static const String messageFieldName = 'message';
  static const String notificationTypeFieldName = 'notificationType';
  static const String targetUserFieldName = 'target_user';
  static const String readStatusFieldName = 'readStatus';
  static const String metadataFieldName = 'metadata';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  NotificationLogsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late String _uid;
  String get uid => _uid;

  late String _title;
  String get title => _title;

  late String _message;
  String get message => _message;

  late NotificationType _notificationType;
  NotificationType get notificationType => _notificationType;

  late String _targetUser;
  DateTime get targetUser => _targetUser;

  late bool _readStatus;
  bool get readStatus => _readStatus;

  late String _metadata;
  String get metadata => _metadata;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _collectionId;
  late String _collectionName;


  void _initializeFields() {
  
    _uid = snapshotData[idFieldName];
    _title = snapshotData[titleFieldName];
    _message = snapshotData[messageFieldName];
    _notificationType = getNotificationTypeByName[snapshotData[notificationTypeFieldName]];
    _targetUser = snapshotData[targetUserFieldName];
    _readStatus = snapshotData[readStatusFieldName];
    _metadata = snapshotData[metadataFieldName];
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

  }

  static NotificationLogsRecord fromSnapshot(RecordModel snapshot) => NotificationLogsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<NotificationLogsRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<NotificationLogsRecord>();

    pb.collection(collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(NotificationLogsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(NotificationLogsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<NotificationLogsRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<NotificationLogsRecord>>();
    final List<NotificationLogsRecord> documents = [];

    pb.collection(collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<NotificationLogsRecord> newsList = recordList.items.map((record) => NotificationLogsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        NotificationLogsRecord record = NotificationLogsRecord.fromSnapshot(e.record!);

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
  static Future<NotificationLogsRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionName).getOne(id, expand: expand).then((s) => NotificationLogsRecord.fromSnapshot(s));
  static Future<List<NotificationLogsRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => NotificationLogsRecord.fromSnapshot(record)).toList()
      ).catchError(
              (e) => print(e)
      );
  static Future<void> deleteNotificationLog(pb, String idNL) async {
    pb.collection(collectionName).delete(idNL);
  }
  static Future<RecordModel> createNotificationLog(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
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

  static NotificationLogsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      NotificationLogsRecord._(reference, mapFromFirestore(data));

  static Future<NotificationLogsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => DeviceTokensRecord.fromSnapshot(record));

  @override
  String toString() =>
      'NotificationLogsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is NotificationLogsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}

Map<String, dynamic> createNotificationLogsRecordData({
  String? uid,
  required String title,
  required String message,
  required NotificationType notificationType,
  required String targetUser,
  String? metadata,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      NotificationLogsRecord.idFieldName: uid,
      NotificationLogsRecord.titleFieldName: title,
      NotificationLogsRecord.messageFieldName: message,
      NotificationLogsRecord.notificationTypeFieldName: notificationType.name,
      NotificationLogsRecord.targetUserFieldName: targetUser,
      NotificationLogsRecord.metadataFieldName: metadata,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class NotificationLogsRecordDocumentEquality implements Equality<NotificationLogsRecord> {
  const NotificationLogsRecordDocumentEquality();

  @override
  bool equals(NotificationLogsRecord? e1, NotificationLogsRecord? e2) {
    return e1?.uid == e2?.uid &&
        e1?.title == e2?.title &&
        e1?.message == e2?.message &&
        e1?.notificationType == e2?.notificationType &&
        e1?.targetUser == e2?.targetUser &&
        e1?.readStatus == e2?.readStatus &&
        e1?.metadata == e2?.metadata;
  }

  @override
  int hash(NotificationLogsRecord? e) => const ListEquality().hash([
    e?.uid,
    e?.title,
    e?.message,
    e?.notificationType,
    e?.targetUser,
    e?.readStatus,
    e?.metadata,
  ]);

  @override
  bool isValidKey(Object? o) => o is NotificationLogsRecord;
}

enum NotificationType {
  new_round("Nuovo Round"),
  unknown("UNKNOWN");

  final String desc;

  const NotificationType(this.desc);
}

NotificationType getNotificationTypeByName(String name) {
  return NotificationType.values.firstWhere(
        (state) => state.name == name,
    orElse: () => NotificationType.unknown,
  );
}
