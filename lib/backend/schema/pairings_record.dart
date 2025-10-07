import 'dart:async';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';

class PairingsRecord extends PocketstoreRecord {
  static const String collectionName = "pairings";
  static const String collectionNameExt = "pairings_extended";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String idRoundFieldName = 'id_round';
  static const String playerAFieldName = 'playerA';
  static const String dropPlayerAFieldName = 'dropPlayerA';
  static const String playerBFieldName = 'playerB';
  static const String dropPlayerBFieldName = 'dropPlayerB';
  static const String isByeFieldName = 'isBye';
  static const String noShowFieldName = 'noShow';
  static const String tableIndexFieldName = 'tableIndex';
  static const String winnerFieldName = 'winner';
  static const String doubleLossFieldName = 'doubleLoss';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String namePlayerAFieldName = 'namePlayerA';
  static const String namePlayerBFieldName = 'namePlayerB';
  static const String surnamePlayerAFieldName = 'surnamePlayerA';
  static const String surnamePlayerBFieldName = 'surnamePlayerB';
  static const String usernamePlayerAFieldName = 'usernamePlayerA';
  static const String usernamePlayerBFieldName = 'usernamePlayerB';

  PairingsRecord._(
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

  late String _roundId;
  String get roundId => _roundId;

  late String _playerA;
  String get playerA => _playerA;

  late String _playerB;
  String get playerB => _playerB;

  late bool _dropPlayerA;
  bool get dropPlayerA => _dropPlayerA;

  late bool _dropPlayerB;
  bool get dropPlayerB => _dropPlayerB;

  late bool _isBye;
  bool get isBye => _isBye;

  late bool _noShow;
  bool get noShow => _noShow;

  late bool _doubleLoss;
  bool get doubleLoss => _doubleLoss;

  late int _tableIndex;
  int get tableIndex => _tableIndex;

  late String _winner;
  String get winner => _winner;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;

  late String _namePlayerA;
  String get namePlayerA => _namePlayerA;

  late String _namePlayerB;
  String get namePlayerB => _namePlayerB;

  late String _surnamePlayerA;
  String get surnamePlayerA => _surnamePlayerA;

  late String _surnamePlayerB;
  String get surnamePlayerB => _surnamePlayerB;

  late String _usernamePlayerA;
  String get usernamePlayerA => _usernamePlayerA;

  late String _usernamePlayerB;
  String get usernamePlayerB => _usernamePlayerB;

  bool get completed => winner != "" || doubleLoss;
  bool get playerAWon => winner == playerA;
  bool get playerBWon => winner == playerB;

  late String _collectionId;
  late String _collectionName;


  void _initializeFields() {
    if(snapshotData.containsKey(namePlayerAFieldName)) {
      _namePlayerA = snapshotData[namePlayerAFieldName];
    } else { _namePlayerA = '';}
    if(snapshotData.containsKey(namePlayerBFieldName)) {
      _namePlayerB = snapshotData[namePlayerBFieldName];
    } else { _namePlayerB = '';}
    if(snapshotData.containsKey(surnamePlayerAFieldName)) {
      _surnamePlayerA = snapshotData[surnamePlayerAFieldName];
    } else { _surnamePlayerA = '';}
    if(snapshotData.containsKey(surnamePlayerBFieldName)) {
      _surnamePlayerB = snapshotData[surnamePlayerBFieldName];
    } else { _surnamePlayerB = '';}
    if(snapshotData.containsKey(usernamePlayerAFieldName)) {
      _usernamePlayerA = snapshotData[usernamePlayerAFieldName];
    } else { _usernamePlayerA = '';}
    if(snapshotData.containsKey(usernamePlayerBFieldName)) {
      extFlag = true;
      _usernamePlayerB = snapshotData[usernamePlayerBFieldName];
    } else {
      extFlag = false;
      _usernamePlayerB = '';
    }


    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _roundId = snapshotData[idRoundFieldName];
    _playerA = snapshotData[playerAFieldName];
    _playerB = snapshotData[playerBFieldName];
    _dropPlayerA = snapshotData[dropPlayerAFieldName];
    _dropPlayerB = snapshotData[dropPlayerBFieldName];
    _isBye = snapshotData[isByeFieldName];
    _noShow = snapshotData[noShowFieldName];
    _doubleLoss = snapshotData[doubleLossFieldName];
    _tableIndex = snapshotData[tableIndexFieldName];
    _winner = snapshotData[winnerFieldName];
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];

    //_ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
  }

  static PairingsRecord fromSnapshot(RecordModel snapshot) => PairingsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<PairingsRecord> getDocument(PocketBase pb, String id, {String? expand}) {
    final controller = StreamController<PairingsRecord>();

    pb.collection(collectionNameExt).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(PairingsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionNameExt).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(PairingsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(collectionNameExt).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<PairingsRecord>> getDocuments(PocketBase pb, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<PairingsRecord>>();
    final List<PairingsRecord> documents = [];

    pb.collection(collectionNameExt).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<PairingsRecord> newsList = recordList.items.map((record) => PairingsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(collectionNameExt).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        PairingsRecord record = PairingsRecord.fromSnapshot(e.record!);

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
      pb.collection(collectionNameExt).unsubscribe();
    };

    return controller.stream;
  }
  static Future<PairingsRecord> getDocumentOnce(PocketBase pb, String id, {String? expand}) =>
      pb.collection(collectionNameExt).getOne(id, expand: expand).then((s) => PairingsRecord.fromSnapshot(s));
  static Future<List<PairingsRecord>> getDocumentsOnce(PocketBase pb, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(collectionNameExt).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => s.items.map(
                  (record) => PairingsRecord.fromSnapshot(record)).toList()
      ).catchError(
              (e) => print(e)
      );
  static Future<void> deletePairing(pb, String idP) async {
    pb.collection(collectionName).delete(idP);
  }
  static Future<RecordModel> createPairing(pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
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

  static PairingsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      PairingsRecord._(reference, mapFromFirestore(data));

  static Future<PairingsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => PairingsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'PairingRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is PairingsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;
}

Map<String, dynamic> createPairingsRecordData({
  String? uid,
  required String tournamentId,
  required String roundId,
  required String playerA,
  required String playerB,
  bool dropPlayerA = false,
  bool dropPlayerB = false,
  bool isBye = false,
  bool doubleLoss = false,
  bool noShow = false,
  String? winner,
  required int tableIndex,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      PairingsRecord.idFieldName: uid,
      PairingsRecord.idTournamentFieldName: tournamentId,
      PairingsRecord.idRoundFieldName: roundId,
      PairingsRecord.playerAFieldName: playerA,
      PairingsRecord.playerBFieldName: playerB,
      PairingsRecord.dropPlayerAFieldName: dropPlayerA,
      PairingsRecord.dropPlayerBFieldName: dropPlayerB,
      PairingsRecord.isByeFieldName: isBye,
      PairingsRecord.noShowFieldName: noShow,
      PairingsRecord.doubleLossFieldName: doubleLoss,
      PairingsRecord.winnerFieldName: winner,
      PairingsRecord.tableIndexFieldName: tableIndex,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class PairingsRecordDocumentEquality implements Equality<PairingsRecord> {
  const PairingsRecordDocumentEquality();

  @override
  bool equals(PairingsRecord? e1, PairingsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.tournamentId == e2?.tournamentId &&
        e1?.roundId == e2?.roundId &&
        e1?.playerA == e2?.playerA &&
        e1?.playerB == e2?.playerB &&
        e1?.doubleLoss == e2?.doubleLoss &&
        e1?.noShow == e2?.noShow &&
        e1?.isBye == e2?.isBye &&
        e1?.tableIndex == e2?.tableIndex &&
        e1?.dropPlayerA == e2?.dropPlayerA &&
        e1?.dropPlayerB == e2?.dropPlayerB;
  }

  @override
  int hash(PairingsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.roundId,
    e?.tableIndex,
    e?.isBye,
    e?.doubleLoss,
    e?.noShow,
    e?.playerA,
    e?.playerB,
    e?.dropPlayerB,
    e?.dropPlayerA,
  ]);

  @override
  bool isValidKey(Object? o) => o is PairingsRecord;
}