import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';

class OnboardingOptionsRecord extends FirestoreRecord {
  OnboardingOptionsRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "arrayOne_options" field.
  List<String>? _arrayOneOptions;
  List<String> get arrayOneOptions => _arrayOneOptions ?? const [];
  bool hasArrayOneOptions() => _arrayOneOptions != null;


  void _initializeFields() {
    _arrayOneOptions = getDataList(snapshotData['allergen_options']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('onboarding_options');

  static Stream<OnboardingOptionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => OnboardingOptionsRecord.fromSnapshot(s));

  static Future<OnboardingOptionsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => OnboardingOptionsRecord.fromSnapshot(s));

  static OnboardingOptionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      OnboardingOptionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static OnboardingOptionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      OnboardingOptionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'OnboardingOptionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is OnboardingOptionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createOnboardingOptionsRecordData() {
  final firestoreData = mapToFirestore(
    <String, dynamic>{}.withoutNulls,
  );

  return firestoreData;
}

class OnboardingOptionsRecordDocumentEquality implements Equality<OnboardingOptionsRecord> {
  const OnboardingOptionsRecordDocumentEquality();

  @override
  bool equals(OnboardingOptionsRecord? e1, OnboardingOptionsRecord? e2) {
    const listEquality = ListEquality();
    return listEquality.equals(e1?.arrayOneOptions, e2?.arrayOneOptions);
  }

  @override
  int hash(OnboardingOptionsRecord? e) => const ListEquality().hash([
        e?.arrayOneOptions
      ]);

  @override
  bool isValidKey(Object? o) => o is OnboardingOptionsRecord;
}
