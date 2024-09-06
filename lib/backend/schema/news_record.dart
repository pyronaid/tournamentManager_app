import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/backend.dart';

import 'matches_record.dart';

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
  bool hasTitle() => _title != null;

  // "sub_title" field.
  String? _subTitle;
  String get subTitle => _subTitle ?? 'NO_SUBTITLE';
  bool hasSubTitle() => _subTitle != null;

  // "description" field.
  String? _description;
  String get description => _description ?? 'NO_DESCRIPTION';
  bool hasDescription() => _description != null;

  // "timestamp" field.
  Timestamp? _timestamp;
  Timestamp? get timestamp => _timestamp;
  bool hasTimestamp() => _timestamp != null;

  // "imageUrl" field.
  String? _imageNewsUrl;
  String? get imageNewsUrl => _imageNewsUrl;
  bool hasImageNewsUrl() => _imageNewsUrl != null;

  bool _showTimestampEn = false;
  bool get showTimestampEn => _showTimestampEn;
  bool hasShowTimestampEn() => _showTimestampEn;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _tournamentUid = snapshotData['tournament_uid'] as String;
    _title = snapshotData['title'];
    _subTitle = snapshotData['sub_title'];
    _description = snapshotData['description'];
    _imageNewsUrl = snapshotData['image_news_url'];
    _timestamp = snapshotData['timestamp'] as Timestamp?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rounds');

  static Stream<NewsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => NewsRecord.fromSnapshot(s));

  static Future<NewsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => NewsRecord.fromSnapshot(s));

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
  String? title,
  String? sub_title,
  String? description,
  String? image_news_url,
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
    }.withoutNulls,
  );

  return firestoreData;
}

class NewsRecordDocumentEquality implements Equality<NewsRecord> {
  const NewsRecordDocumentEquality();

  @override
  bool equals(NewsRecord? e1, NewsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.tournamentUid == e2?.tournamentUid &&
        e1?.uid == e2?.uid &&
        e1?.title == e2?.title &&
        e1?.subTitle == e2?.subTitle &&
        e1?.description == e2?.description &&
        e1?.imageNewsUrl == e2?.imageNewsUrl &&
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
  ]);

  @override
  bool isValidKey(Object? o) => o is NewsRecord;
}

