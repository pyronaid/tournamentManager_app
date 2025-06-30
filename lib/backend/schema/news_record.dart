import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

import '../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class NewsRecord extends PocketstoreRecord {
  static const String collectionName = "news";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String titleFieldName = 'title';
  static const String subTitleFieldName = 'subTitle';
  static const String descriptionFieldName = 'description';
  static const String imageFieldName = 'imageNews';
  static const String showTimestampFieldName = 'showTimestampEn';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String idOwnerFieldName = 'id_owner';

  NewsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  late String _uid;
  String get uid => _uid;

  late String _tournamentId;
  String get tournamentId => _tournamentId;

  late String? _title;
  String get title => _title ?? 'NO_TITLE';
  Future<void> setTitle(String newTitle) async {
    _title = newTitle;
    await updateField(pb, uid, titleFieldName, newTitle);
  }
  bool hasTitle() => _title != null;

  late String? _subTitle;
  String get subTitle => _subTitle ?? 'NO_SUBTITLE';
  Future<void> setSubTitle(String newSubTitle) async {
    _subTitle = newSubTitle;
    await updateField(pb, uid, subTitleFieldName, newSubTitle);
  }
  bool hasSubTitle() => _subTitle != null;

  late String? _description;
  String get description => _description ?? 'NO_DESCRIPTION';
  Future<void> setDescription(String newDescription) async {
    _description = newDescription;
    await updateField(pb, uid, descriptionFieldName, newDescription);
  }
  bool hasDescription() => _description != null;

  late String? _imageNews;
  String? get imageNews => _imageNews;
  Future<void> setImage(String newImage) async {
    _imageNews = newImage;
    await updateField(pb, uid, imageFieldName, newImage);
  }
  bool hasImageNews() => _imageNews != null;

  bool _showTimestampEn = false;
  bool get showTimestampEn => _showTimestampEn;
  Future<void> switchShowTimestampEn() async {
    _showTimestampEn = !_showTimestampEn;
    await updateField(pb, uid, showTimestampFieldName, _showTimestampEn);
  }

  late String _ownerId;
  String get ownerId => _ownerId;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;
  bool hasCreatedTime() => true;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;
  bool hasUpdatedTime() => true;

  late String _collectionId;
  late String _collectionName;

  void _initializeFields() {
    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _title = snapshotData[titleFieldName];
    _subTitle = snapshotData[subTitleFieldName];
    _description = snapshotData[descriptionFieldName];
    _imageNews = getFileUrl(snapshotData[collectionIdFieldName], snapshotData[idFieldName], snapshotData[imageFieldName]);
    _showTimestampEn = snapshotData[showTimestampFieldName];
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

    _ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
  }

  static NewsRecord fromSnapshot(RecordModel snapshot) => NewsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<NewsRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<NewsRecord>();

    pb.collection(collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(NewsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(NewsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<NewsRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<NewsRecord>>();
    final List<NewsRecord> documents = [];

    pb.collection(collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<NewsRecord> newsList = recordList.items.map((record) => NewsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        NewsRecord record = NewsRecord.fromSnapshot(e.record!);

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
  static Future<NewsRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionName).getOne(id, expand: expand).then((s) => NewsRecord.fromSnapshot(s));
  static Future<List<NewsRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => NewsRecord.fromSnapshot(record)).toList()
      );
  static Future<void> deleteNews(pb, String idN) async {
    pb.collection(collectionName).delete(idN);
  }
  static Future<RecordModel> createNews(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
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

  static NewsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      NewsRecord._(reference, mapFromFirestore(data));

  static Future<NewsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => NewsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'NewsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is NewsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}


Map<String, dynamic> createNewsRecordData({
  String? uid,
  required String tournamentId,
  required String title,
  String? subTitle,
  String? description,
  String? imageNews,
  bool showTimestampEn = false,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      NewsRecord.idFieldName: uid,
      NewsRecord.idTournamentFieldName: tournamentId,
      NewsRecord.titleFieldName: title,
      NewsRecord.subTitleFieldName: subTitle,
      NewsRecord.descriptionFieldName: description,
      NewsRecord.imageFieldName: imageNews,
      NewsRecord.showTimestampFieldName : showTimestampEn,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class NewsRecordDocumentEquality implements Equality<NewsRecord> {
  const NewsRecordDocumentEquality();

  @override
  bool equals(NewsRecord? e1, NewsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.title == e2?.title &&
        e1?.subTitle == e2?.subTitle &&
        e1?.description == e2?.description &&
        e1?.imageNews == e2?.imageNews;
  }

  @override
  int hash(NewsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.title,
    e?.subTitle,
    e?.description,
    e?.imageNews,
  ]);

  @override
  bool isValidKey(Object? o) => o is NewsRecord;
}
