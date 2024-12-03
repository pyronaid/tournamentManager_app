import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/index.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';

class NewsRecord extends FirestoreRecord {
  NewsRecord._(
      super.reference,
      super.data,
      ) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "game" field.
  String? _tournamentUid;
  String get tournamentUid => _tournamentUid ?? '';
  bool hasTournamentUid() => _tournamentUid != null;

  // "title" field.
  String? _title;
  String get title => _title ?? 'NO_TITLE';
  Future<void> setTitle(String newTitle) async {
    _title = newTitle;
    await updateField(tournamentUid, uid, "title", newTitle);
  }
  bool hasTitle() => _title != null;

  // "sub_title" field.
  String? _subTitle;
  String get subTitle => _subTitle ?? 'NO_SUBTITLE';
  Future<void> setSubTitle(String newSubTitle) async {
    _subTitle = newSubTitle;
    await updateField(tournamentUid, uid, "sub_title", newSubTitle);
  }
  bool hasSubTitle() => _subTitle != null;

  // "description" field.
  String? _description;
  String get description => _description ?? 'NO_DESCRIPTION';
  Future<void> setDescription(String newDescription) async {
    _description = newDescription;
    await updateField(tournamentUid, uid, "description", newDescription);
  }
  bool hasDescription() => _description != null;

  // "timestamp" field.
  DateTime? _timestamp;
  DateTime? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "imageUrl" field.
  String? _imageNewsUrl;
  String? get imageNewsUrl => _imageNewsUrl;
  Future<void> setImage(String newImage) async {
    _imageNewsUrl = newImage;
    await updateField(tournamentUid, uid, "image_news_url", newImage);
  }
  bool hasImageNewsUrl() => _imageNewsUrl != null;

  bool _showTimestampEn = false;
  bool get showTimestampEn => _showTimestampEn;
  Future<void> switchShowTimestampEn() async {
    _showTimestampEn = !_showTimestampEn;
    await updateField(tournamentUid, uid, "show_timestamp_en", _showTimestampEn);
  }
  bool hasShowTimestampEn() => _showTimestampEn;

  // "uid" field.
  String? _creatorUid;
  String get creatorUid => _creatorUid ?? '';
  bool hasCreatorUid() => _creatorUid != null;

  void _initializeFields() {
    _uid = reference.id;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _title = snapshotData['title'];
    _subTitle = snapshotData['sub_title'];
    _description = snapshotData['description'];
    _imageNewsUrl = snapshotData['image_news_url'];
    _creatorUid = snapshotData['creator_uid'];
    _timestamp = snapshotData['timestamp'] as DateTime?;
    _showTimestampEn = snapshotData['show_timestamp_en'];
  }

  static CollectionReference collection(String tournamentRef) =>
      FirebaseFirestore.instance.collection('tournaments').doc(tournamentRef).collection('news');

  static Stream<List<NewsRecord>> getAllDocuments(String tournamentRef) =>
      collection(tournamentRef).snapshots().map((snapshot) => snapshot.docs.map((doc) => NewsRecord.fromSnapshot(doc)).toList());

  static Stream<NewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NewsRecord.fromSnapshot(s));

  static Future<NewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NewsRecord.fromSnapshot(s));

  static Future<void> deleteNews(String idT, String idN) async {
    try {
      await collection(idT).doc(idN).delete();
    } catch (e) {
      print("Failed to delete news: $e");
    }
  }

  static Future<void> updateField(String idT, String idN, String fieldName, dynamic newValue) async {
    try {
      await collection(idT).doc(idN).update({
        fieldName: newValue,
      });
    } catch (e) {
      print("Failed to update field: $e");
    }
  }

  static NewsRecord fromSnapshot(DocumentSnapshot snapshot) => NewsRecord._(
    snapshot.reference,
    mapFromFirestore(snapshot.data() as Map<String, dynamic>),
  );

  static NewsRecord getDocumentFromData(
      Map<String, dynamic> data,
      DocumentReference reference,
      ) =>
      NewsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'NewsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is NewsRecord &&
          reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createNewsRecordData({
  String? uid,
  required String? tournament_uid,
  required String? title,
  String? sub_title,
  required String? description,
  String? image_news_url,
  required String? creator_uid,
  bool show_timestamp_en = false,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'tournament_uid': tournament_uid,
      'title': title,
      'sub_title': sub_title,
      'description': description,
      'image_news_url': image_news_url,
      'timestamp': Timestamp.now(),
      'creator_uid': creator_uid,
      'show_timestamp_en' : show_timestamp_en,
    }.withoutNulls,
  );

  return firestoreData;
}

class NewsRecordDocumentEquality implements Equality<NewsRecord> {
  const NewsRecordDocumentEquality();

  @override
  bool equals(NewsRecord? e1, NewsRecord? e2) {
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        e1?.title == e2?.title &&
        e1?.subTitle == e2?.subTitle &&
        e1?.description == e2?.description &&
        e1?.imageNewsUrl == e2?.imageNewsUrl &&
        e1?.creatorUid == e2?.creatorUid &&
        e1?.timestamp == e2?.timestamp;
  }

  @override
  int hash(NewsRecord? e) => const ListEquality().hash([
    e?.tournamentUid,
    e?.uid,
    e?.title,
    e?.subTitle,
    e?.description,
    e?.imageNewsUrl,
    e?.timestamp,
    e?.creatorUid
  ]);

  @override
  bool isValidKey(Object? o) => o is NewsRecord;
}

