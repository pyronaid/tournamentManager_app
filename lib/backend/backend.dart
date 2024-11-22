import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/auth/firebase_auth/auth_util.dart';
import 'package:tournamentmanager/backend/schema/company_information_record.dart';
import 'package:tournamentmanager/backend/schema/feedback_record.dart';
import 'package:tournamentmanager/backend/schema/onboarding_options_record.dart';
import 'package:tournamentmanager/backend/schema/support_center_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/users_record.dart';
import 'schema/util/firestore_util.dart';
export 'dart:async' show StreamSubscription;
export 'package:cloud_firestore/cloud_firestore.dart' hide Order;
export 'package:firebase_core/firebase_core.dart';

/// /////////////////////////////////////////////////////////////////
/// Functions to query UsersRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> queryUsersRecordCount({ Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      UsersRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<UsersRecord>> queryUsersRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      UsersRecord.collection,
      UsersRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<UsersRecord>> queryUsersRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      UsersRecord.collection,
      UsersRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// /////////////////////////////////////////////////////////////////
/// Functions to query OnboardingOptionsRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> queryOnboardingOptionsRecordCount({ Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      OnboardingOptionsRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<OnboardingOptionsRecord>> queryOnboardingOptionsRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      OnboardingOptionsRecord.collection,
      OnboardingOptionsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<OnboardingOptionsRecord>> queryOnboardingOptionsRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      OnboardingOptionsRecord.collection,
      OnboardingOptionsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// /////////////////////////////////////////////////////////////////
/// Functions to query CompanyInformationRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> queryCompanyInformationRecordCount({Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      CompanyInformationRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<CompanyInformationRecord>> queryCompanyInformationRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      CompanyInformationRecord.collection,
      CompanyInformationRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<CompanyInformationRecord>> queryCompanyInformationRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      CompanyInformationRecord.collection,
      CompanyInformationRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// /////////////////////////////////////////////////////////////////
/// Functions to query FeedbackRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> queryFeedbackRecordCount({ Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      FeedbackRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<FeedbackRecord>> queryFeedbackRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      FeedbackRecord.collection,
      FeedbackRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<FeedbackRecord>> queryFeedbackRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      FeedbackRecord.collection,
      FeedbackRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// /////////////////////////////////////////////////////////////////
/// Functions to query SupportCenterRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> querySupportCenterRecordCount({ Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      SupportCenterRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<SupportCenterRecord>> querySupportCenterRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      SupportCenterRecord.collection,
      SupportCenterRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<SupportCenterRecord>> querySupportCenterRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      SupportCenterRecord.collection,
      SupportCenterRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

/// /////////////////////////////////////////////////////////////////
/// Functions to query TournamentsRecords (as a Stream and as a Future).
/// /////////////////////////////////////////////////////////////////
Future<int> queryTournamentsRecordCount({ Query Function(Query)? queryBuilder, int limit = -1, }) =>
    queryCollectionCount(
      TournamentsRecord.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );

Stream<List<TournamentsRecord>> queryTournamentsRecord({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollection(
      TournamentsRecord.collection,
      TournamentsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );

Future<List<TournamentsRecord>> queryTournamentsRecordOnce({ Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) =>
    queryCollectionOnce(
      TournamentsRecord.collection,
      TournamentsRecord.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );



/// /////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////
/// /////////////////////////////////////////////////////////////////




Future<int> queryCollectionCount(
    Query collection,
    { Query Function(Query)? queryBuilder, int limit = -1, }) {
      final builder = queryBuilder ?? (q) => q;
      var query = builder(collection);
      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.count().get().catchError((err) {
        print('Error querying $collection: $err');
      }).then((value) => value.count!);
}

Stream<List<T>> queryCollection<T>(
  Query collection,
  RecordBuilder<T> recordBuilder,
  { Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false,}) {
    final builder = queryBuilder ?? (q) => q;
    var query = builder(collection);
    if (limit > 0 || singleRecord) {
      query = query.limit(singleRecord ? 1 : limit);
    }
    return query.snapshots().handleError((err) {
      print('Error querying $collection: $err');
    }).map((s) => s.docs
        .map(
          (d) => safeGet(
            () => recordBuilder(d),
            (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
          ),
        )
        .where((d) => d != null)
        .map((d) => d!)
        .toList());
}

Future<List<T>> queryCollectionOnce<T>(
  Query collection,
  RecordBuilder<T> recordBuilder,
  { Query Function(Query)? queryBuilder, int limit = -1, bool singleRecord = false, }) {
    final builder = queryBuilder ?? (q) => q;
    var query = builder(collection);
    if (limit > 0 || singleRecord) {
      query = query.limit(singleRecord ? 1 : limit);
    }
    return query.get().then((s) => s.docs
        .map(
          (d) => safeGet(
            () => recordBuilder(d),
            (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
          ),
        )
        .where((d) => d != null)
        .map((d) => d!)
        .toList());
}

Filter filterIn(String field, List? list) => (list?.isEmpty ?? true) ? Filter(field, whereIn: null) : Filter(field, whereIn: list);

Filter filterArrayContainsAny(String field, List? list) =>
    (list?.isEmpty ?? true) ? Filter(field, arrayContainsAny: null) : Filter(field, arrayContainsAny: list);

extension QueryExtension on Query {
  Query whereIn(String field, List? list) => (list?.isEmpty ?? true) ? where(field, whereIn: null) : where(field, whereIn: list);

  Query whereNotIn(String field, List? list) => (list?.isEmpty ?? true) ? where(field, whereNotIn: null) : where(field, whereNotIn: list);

  Query whereArrayContainsAny(String field, List? list) =>
      (list?.isEmpty ?? true) ? where(field, arrayContainsAny: null) : where(field, arrayContainsAny: list);
}


class FFFirestorePage<T> {
  final List<T> data;
  final Stream<List<T>>? dataStream;
  final QueryDocumentSnapshot? nextPageMarker;

  FFFirestorePage(this.data, this.dataStream, this.nextPageMarker);
}

Future<FFFirestorePage<T>> queryCollectionPage<T>(
  Query collection,
  RecordBuilder<T> recordBuilder, {
  Query Function(Query)? queryBuilder,
  DocumentSnapshot? nextPageMarker,
  required int pageSize,
  required bool isStream,
}) async {
  final builder = queryBuilder ?? (q) => q;
  var query = builder(collection).limit(pageSize);
  if (nextPageMarker != null) {
    query = query.startAfterDocument(nextPageMarker);
  }
  Stream<QuerySnapshot>? docSnapshotStream;
  QuerySnapshot docSnapshot;
  if (isStream) {
    docSnapshotStream = query.snapshots();
    docSnapshot = await docSnapshotStream.first;
  } else {
    docSnapshot = await query.get();
  }
  getDocs(QuerySnapshot s) => s.docs
      .map(
        (d) => safeGet(
          () => recordBuilder(d),
          (e) => print('Error serializing doc ${d.reference.path}:\n$e'),
        ),
      )
      .where((d) => d != null)
      .map((d) => d!)
      .toList();
  final data = getDocs(docSnapshot);
  final dataStream = docSnapshotStream?.map(getDocs);
  final nextPageToken = docSnapshot.docs.isEmpty ? null : docSnapshot.docs.last;
  return FFFirestorePage(data, dataStream, nextPageToken);
}

// Creates a Firestore document representing the logged in user if it doesn't yet exist
Future maybeCreateUser(User user) async {
  final userRecord = UsersRecord.collection.doc(user.uid);
  final userExists = await userRecord.get().then((u) => u.exists);
  if (userExists) {
    currentUserDocument = await UsersRecord.getDocumentOnce(userRecord);
    return;
  }

  final userData = createUsersRecordData(
    email: user.email ??
        FirebaseAuth.instance.currentUser?.email ??
        user.providerData.firstOrNull?.email,
    displayName:
        user.displayName ?? FirebaseAuth.instance.currentUser?.displayName,
    photoUrl: user.photoURL,
    uid: user.uid,
    phoneNumber: user.phoneNumber,
    createdTime: getCurrentTimestamp,
  );

  await userRecord.set(userData);
  currentUserDocument = UsersRecord.getDocumentFromData(userData, userRecord);
}

Future updateUserDocument({String? email}) async {
  await currentUserDocument?.reference
      .update(createUsersRecordData(email: email));
}

//TODO REMOVE USERDATA
// not sure to do it bc i lose history not for now at least
Future deleteUserDocument({String? uid}) async {
  await currentUserDocument?.reference
      .delete();
}

