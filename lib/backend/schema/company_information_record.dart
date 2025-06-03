import 'dart:async';

import 'package:collection/collection.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';

import 'developer_information_record.dart';

class CompanyInformationRecord extends PocketstoreRecord {
  static const String collectionName = "company_information";

  CompanyInformationRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "logo" field.
  String? _logo;
  String get logo => _logo ?? '';
  bool hasLogo() => _logo != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "phone" field.
  String? _phone;
  String get phone => _phone ?? '';
  bool hasPhone() => _phone != null;

  // "address" field.
  String? _address;
  String get address => _address ?? '';
  bool hasAddress() => _address != null;

  // "appleStoreURL" field.
  String? _appleStoreURL;
  String get appleStoreURL => _appleStoreURL ?? '';
  bool hasAppleStoreURL() => _appleStoreURL != null;

  // "playStoreURL" field.
  String? _playStoreURL;
  String get playStoreURL => _playStoreURL ?? '';
  bool hasPlayStoreURL() => _playStoreURL != null;

  // "coverImage" field.
  String? _coverImage;
  String get coverImage => _coverImage ?? '';
  bool hasCoverImage() => _coverImage != null;

  // "company_bio" field.
  String? _companyBio;
  String get companyBio => _companyBio ?? '';
  bool hasCompanyBio() => _companyBio != null;

  // "dev_info" field.
  List<DevelopersInformationRecord>? _devInfo;
  List<DevelopersInformationRecord> get devInfo => _devInfo ?? const [];
  bool hasDevInfo() => _devInfo != null;

  // "termsURL" field.
  String? _termsURL;
  String get termsURL => _termsURL ?? '';
  bool hasTermsURL() => _termsURL != null;

  void _initializeFields() {
    _name = snapshotData['name'];
    _logo = getFileUrl(snapshotData['collectionId'], snapshotData['id'], snapshotData['logo']);
    _email = snapshotData['email'];
    _phone = snapshotData['phone'];
    _address = snapshotData['address'];
    _appleStoreURL = snapshotData['appleStoreURL'];
    _playStoreURL = snapshotData['playStoreURL'];
    _coverImage = getFileUrl(snapshotData['collectionId'], snapshotData['id'], snapshotData['coverImage']);
    _companyBio = snapshotData['company_bio'];
    _devInfo = snapshotData['expand'] != null ? (snapshotData['expand']['developers_information_via_company'] as List)
        .map((elem) => RecordModel(elem))
        .map((el) => DevelopersInformationRecord.fromSnapshot(el))
        .toList() : [];
    _termsURL = snapshotData['termsURL'];
  }

  static CompanyInformationRecord fromSnapshot(RecordModel snapshot) => CompanyInformationRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<CompanyInformationRecord> getDocument(PocketBase pb, String id) {
    final controller = StreamController<CompanyInformationRecord>();

    pb.collection(collectionName).getOne(id).then((record) {
      if (!controller.isClosed) controller.add(CompanyInformationRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionName).subscribe(id, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(CompanyInformationRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionName).unsubscribe();
    };

    return controller.stream;
  }

  static Future<CompanyInformationRecord> getDocumentOnce(PocketBase pb, String id) =>
      pb.collection(collectionName).getOne(id).then((s) => CompanyInformationRecord.fromSnapshot(s));

  static Future<CompanyInformationRecord> getFirstDocumentByFilterOnce(PocketBase pb, String filter, bool expand) =>
      pb.collection(collectionName).getFirstListItem(filter, expand: expand ? 'developers_information_via_company' : null).then((s) => CompanyInformationRecord.fromSnapshot(s));

  static CompanyInformationRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      CompanyInformationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() => 'CompanyInformationRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is CompanyInformationRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}


class CompanyInformationRecordDocumentEquality
    implements Equality<CompanyInformationRecord> {
  const CompanyInformationRecordDocumentEquality();

  @override
  bool equals(CompanyInformationRecord? e1, CompanyInformationRecord? e2) {
    const listEquality = ListEquality();
    return e1?.name == e2?.name &&
        e1?.logo == e2?.logo &&
        e1?.email == e2?.email &&
        e1?.phone == e2?.phone &&
        e1?.address == e2?.address &&
        e1?.appleStoreURL == e2?.appleStoreURL &&
        e1?.playStoreURL == e2?.playStoreURL &&
        e1?.coverImage == e2?.coverImage &&
        e1?.companyBio == e2?.companyBio &&
        listEquality.equals(e1?.devInfo, e2?.devInfo) &&
        e1?.termsURL == e2?.termsURL;
  }

  @override
  int hash(CompanyInformationRecord? e) => const ListEquality().hash([
        e?.name,
        e?.logo,
        e?.email,
        e?.phone,
        e?.address,
        e?.appleStoreURL,
        e?.playStoreURL,
        e?.coverImage,
        e?.companyBio,
        e?.devInfo,
        e?.termsURL
      ]);

  @override
  bool isValidKey(Object? o) => o is CompanyInformationRecord;
}
