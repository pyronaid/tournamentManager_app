import 'dart:async';

import 'package:collection/collection.dart';
import 'package:tournamentmanager/backend/schema/index.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';

class FeedbackRecord extends FirestoreRecord {
  FeedbackRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "feedback" field.
  String? _feedback;
  String get feedback => _feedback ?? '';
  bool hasFeedback() => _feedback != null;

  // "time_created" field.
  DateTime? _timeCreated;
  DateTime? get timeCreated => _timeCreated;
  bool hasTimeCreated() => _timeCreated != null;

  void _initializeFields() {
    _feedback = snapshotData['feedback'] as String?;
    _timeCreated = snapshotData['time_created'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('feedback');

  static Stream<FeedbackRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FeedbackRecord.fromSnapshot(s));

  static Future<FeedbackRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FeedbackRecord.fromSnapshot(s));

  static FeedbackRecord fromSnapshot(DocumentSnapshot snapshot) =>
      FeedbackRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FeedbackRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FeedbackRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FeedbackRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FeedbackRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFeedbackRecordData({
  String? feedback,
  DateTime? timeCreated,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'feedback': feedback,
      'time_created': timeCreated,
    }.withoutNulls,
  );

  return firestoreData;
}

class FeedbackRecordDocumentEquality implements Equality<FeedbackRecord> {
  const FeedbackRecordDocumentEquality();

  @override
  bool equals(FeedbackRecord? e1, FeedbackRecord? e2) {
    return e1?.feedback == e2?.feedback &&
        e1?.timeCreated == e2?.timeCreated;
  }

  @override
  int hash(FeedbackRecord? e) =>
      const ListEquality().hash([e?.feedback, e?.timeCreated]);

  @override
  bool isValidKey(Object? o) => o is FeedbackRecord;
}
