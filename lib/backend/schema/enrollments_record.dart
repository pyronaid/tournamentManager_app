import 'dart:async';
import 'dart:typed_data' as td;
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:tournamentmanager/backend/schema/util/firestore_util.dart';
import 'package:tournamentmanager/backend/schema/util/pocketbase_util.dart';
import 'package:tournamentmanager/backend/schema/util/schema_util.dart';
import 'package:ygoprodeck_api/ygoprodeck_api.dart';
import 'package:tuple/tuple.dart';


class EnrollmentsRecord extends PocketstoreRecord {
  static const String collectionNameExt = "enrollments_extended";
  static const String collectionName = "enrollments";
  static const String idFieldName = 'id';
  static const String idTournamentFieldName = 'id_tournament';
  static const String idUserFieldName = 'id_user';
  static const String listKindFieldName = 'listKind';
  static const String decklistFieldName = 'decklist';
  static const String decklistImageFieldName = 'decklistImage';
  static const String createdFieldName = 'created';
  static const String updatedFieldName = 'updated';
  static const String collectionIdSourceFieldName = 'collectionIdSource';
  static const String collectionIdFieldName = 'collectionId';
  static const String collectionNameFieldName = 'collectionName';

  static const String nameFieldName = 'name';
  static const String surnameFieldName = 'surname';
  static const String usernameFieldName = 'username';
  static const String idOwnerFieldName = 'id_owner';


  EnrollmentsRecord._(
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

  late String _userId;
  String get userId => _userId;

  late ListType _listKind;
  ListType get listKind => _listKind ;

  late DateTime _createdTime;
  DateTime get createdTime => _createdTime;
  bool hasCreatedTime() => true;

  late DateTime _updatedTime;
  DateTime get updatedTime => _updatedTime;
  bool hasUpdatedTime() => true;

  late Decklist? _decklist;
  Decklist? get decklist => _decklist;
  bool hasDecklist() => _decklist != null;

  late String? _decklistImage;
  String? get decklistImage => _decklistImage;
  Future<void> setImage(PocketBase pb, {required List<MultipartFile> files}) async {
    for(MultipartFile file in files) {
      _decklistImage = getFileUrl(snapshotData[extFlag ? collectionIdSourceFieldName : collectionIdFieldName], snapshotData[idFieldName], file.filename);
      await updateFiles(pb, uid, files: [file]);
    }
  }
  bool hasDecklistImage() => _decklistImage != null;

  // ignore: unused_field
  late String _collectionId;
  // ignore: unused_field
  late String _collectionName;

  late String _ownerId;
  String get ownerId => _ownerId;

  late String _name;
  String get name => _name;

  late String _surname;
  String get surname => _surname;

  late String _username;
  String get username => _username;

  void _initializeFields() {
    if(snapshotData.containsKey(idOwnerFieldName)) {
      extFlag = true;
      _ownerId = snapshotData[idOwnerFieldName];
    } else {
      extFlag = false;
      _ownerId = getExpandendValue(snapshotData['expand'], idTournamentFieldName, idOwnerFieldName)!;
    }
    if(snapshotData.containsKey(nameFieldName)) {
      _name = snapshotData[nameFieldName];
    } else {
      _name = getExpandendValue(snapshotData['expand'], idUserFieldName, nameFieldName)!;
    }
    if(snapshotData.containsKey(surnameFieldName)) {
      _surname = snapshotData[surnameFieldName];
    } else {
      _surname = getExpandendValue(snapshotData['expand'], idUserFieldName, surnameFieldName)!;
    }
    if(snapshotData.containsKey(usernameFieldName)) {
      _username = snapshotData[usernameFieldName];
    } else {
      _username = getExpandendValue(snapshotData['expand'], idUserFieldName, usernameFieldName)!;
    }

    _uid = snapshotData[idFieldName];
    _tournamentId = snapshotData[idTournamentFieldName];
    _userId = snapshotData[idUserFieldName];
    _listKind = getListTypeEnum(snapshotData[listKindFieldName]);
    _createdTime = tryParseDate(snapshotData[createdFieldName])!;
    _updatedTime = tryParseDate(snapshotData[updatedFieldName])!;
    _decklist = convertJsonDecklist(snapshotData[decklistFieldName]);
    _decklistImage = getFileUrl(snapshotData[extFlag ? collectionIdSourceFieldName : collectionIdFieldName], snapshotData[idFieldName], snapshotData[decklistImageFieldName]);
    _collectionId = snapshotData[collectionIdFieldName];
    _collectionName = snapshotData[collectionNameFieldName];
  }

  static EnrollmentsRecord fromSnapshot(RecordModel snapshot) => EnrollmentsRecord._(
    snapshot,
    snapshot.toJson(),
  );

  static Stream<EnrollmentsRecord> getDocument(PocketBase pb, bool ext, String id, {String? expand}) {
    final controller = StreamController<EnrollmentsRecord>();

    pb.collection(ext ? collectionNameExt : collectionName).getOne(id, expand: expand).then((record) {
      if (!controller.isClosed) controller.add(EnrollmentsRecord.fromSnapshot(record));
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe(id, expand: expand, (e) {
      if (e.record != null) {
        if (!controller.isClosed) controller.add(EnrollmentsRecord.fromSnapshot(e.record!));
      }
    });

    // Clean up on stream cancellation
    controller.onCancel = () {
      pb.collection(ext ? collectionNameExt : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Stream<List<EnrollmentsRecord>> getDocuments(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page = 1, int perPage = 30}) {
    final controller = StreamController<List<EnrollmentsRecord>>();
    final List<EnrollmentsRecord> documents = [];

    pb.collection(ext ? collectionNameExt : collectionName).getList(filter: filter, sort: sorting, page: page, perPage: perPage, expand: expand).then((recordList) {
      if (!controller.isClosed) {
        List<EnrollmentsRecord> newsList = recordList.items.map((record) => EnrollmentsRecord.fromSnapshot(record)).toList();
        documents.addAll(newsList);
        controller.add(newsList);
      }
    }).catchError((error){
      if (!controller.isClosed) controller.addError(error);
    });

    pb.collection(ext ? collectionNameExt : collectionName).subscribe('*', filter: filter, query: {'page' : page, 'perPage' : perPage}, expand: expand, (e) {
      if (!controller.isClosed && e.record != null) {
        EnrollmentsRecord record = EnrollmentsRecord.fromSnapshot(e.record!);

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
      pb.collection(ext ? collectionNameExt : collectionName).unsubscribe();
    };

    return controller.stream;
  }
  static Future<EnrollmentsRecord> getDocumentOnce(PocketBase pb, bool ext, String id, {String? expand}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getOne(id, expand: expand).then((s) => EnrollmentsRecord.fromSnapshot(s));
  static Future<Tuple2<int,List<EnrollmentsRecord>>> getDocumentsOnce(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
              (s) => Tuple2(
                  s.totalItems,
                  s.items.map((record) => EnrollmentsRecord.fromSnapshot(record)).toList())
              );
  static Future<List<EnrollmentsRecord>> getDocumentsOncePlain(PocketBase pb, bool ext, String filter, {String? expand, String? sorting, int page=1, int perPage = 30, Map<String, dynamic> queryMap = const {}}) =>
      pb.collection(ext ? collectionNameExt : collectionName).getList(
          filter: filter,
          sort: sorting,
          page: page,
          perPage: perPage,
          expand: expand,
          query: queryMap
      ).then(
        (s) =>  s.items.map((record) => EnrollmentsRecord.fromSnapshot(record)).toList()
      );
  static Future<void> deleteEnrollments(pb, String idE) async {
    pb.collection(collectionName).delete(idE);
  }
  static Future<RecordModel> createEnrollments(PocketBase pb, Map<String,dynamic> mapObj, {List<MultipartFile>? files}) async {
    return pb.collection(collectionName).create(
      body: mapObj,
      files: files??[],
    );
  }
  static Future<void> updateFiles(PocketBase pb, String id, {required List<MultipartFile> files}) async {
    try {
      await pb.collection(collectionName).update(id,
        files: files,
      );
    } catch (e) {
      print("Failed to update field: $e");
    }
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

  static EnrollmentsRecord getDocumentFromData(
      Map<String, dynamic> data,
      RecordModel reference,
      ) =>
      EnrollmentsRecord._(reference, mapFromFirestore(data));

  static Future<EnrollmentsRecord> createRecordFromMap(PocketBase pb, Map<String, dynamic> body) async =>
      pb.collection(collectionName).create(body: body).then((record) => EnrollmentsRecord.fromSnapshot(record));

  @override
  String toString() =>
      'EnrollmentsRecord(reference: ${reference.id}-${reference.collectionId}-${reference.collectionName}, data: $snapshotData)';

  @override
  int get hashCode => (reference.id+reference.collectionId+reference.collectionName).hashCode;

  @override
  bool operator ==(other) =>
      other is EnrollmentsRecord &&
          (reference.id+reference.collectionId+reference.collectionName).hashCode == (other.reference.id+other.reference.collectionId+other.reference.collectionName).hashCode;

  ListType getListTypeEnum(stringValue) {
    return ListType.values.firstWhere(
          (e) => e.name == stringValue,
      orElse: () => ListType.registered,
    );
  }
}


Map<String, dynamic> createEnrollmentsRecordData({
  String? uid,
  required String tournamentId,
  required String userId,
  required ListType listKind,
}) {
  final pocketstoreData = mapToFirestore(
    <String, dynamic>{
      EnrollmentsRecord.idFieldName: uid,
      EnrollmentsRecord.idTournamentFieldName: tournamentId,
      EnrollmentsRecord.idUserFieldName: userId,
      EnrollmentsRecord.listKindFieldName: listKind,
    }.withoutNulls,
  );

  return pocketstoreData;
}

class EnrollmentsRecordDocumentEquality implements Equality<EnrollmentsRecord> {
  const EnrollmentsRecordDocumentEquality();

  @override
  bool equals(EnrollmentsRecord? e1, EnrollmentsRecord? e2) {
    return e1?.tournamentId == e2?.tournamentId &&
        e1?.uid == e2?.uid &&
        e1?.userId == e2?.userId &&
        e1?.decklist == e2?.decklist &&
        e1?.decklistImage == e2?.decklistImage &&
        e1?.listKind == e2?.listKind;
  }

  @override
  int hash(EnrollmentsRecord? e) => const ListEquality().hash([
    e?.tournamentId,
    e?.uid,
    e?.userId,
    e?.decklist,
    e?.decklistImage,
    e?.listKind
  ]);

  @override
  bool isValidKey(Object? o) => o is EnrollmentsRecord;
}

enum ListType {
  waiting("waiting_list_info"),
  preregistered("preregistered_list_info"),
  registered("registered_list_info");

  final String listName;
  const ListType(this.listName);
}

ListType getListTypeByName(String name) {
  return ListType.values.firstWhere(
        (state) => state.name == name,
    orElse: () => ListType.waiting,
  );
}

// ---------------------------------------------------------------------------
// 1. DATA CLASS  –  EnrollmentCheckResult
// ---------------------------------------------------------------------------

/// Result returned by [TournamentDetailModel.enrollCheckFuture].
///
/// - [count]       total number of enrollments found for the current user in
///                 this tournament (0 = not enrolled).
/// - [enrollments] the actual records, available for further inspection
///                 (e.g. to distinguish pre-reg from confirmed).
class EnrollmentCheckResult {
  const EnrollmentCheckResult({
    required this.count,
    required this.enrollments,
  });

  final int count;
  final List<EnrollmentsRecord> enrollments;

  /// Convenience getter — true when the user has no enrollment records.
  bool get isNotEnrolled => count == 0;
}

// ---------------------------------------------------------------------------
// 2. ENUM  –  RegistrationStatus
// ---------------------------------------------------------------------------

/// Drives the registration section of the tournament detail screen.
/// The widget performs a simple switch on this value — no business logic
/// leaks into the UI layer.
enum RegistrationStatus {
  /// User can pre-register (capacity not reached, pre-reg enabled).
  canRegister,

  /// Capacity is full but waiting list is enabled.
  canJoinWaiting,

  /// User is already enrolled (pre-reg or confirmed).
  alreadyEnrolled,

  /// Capacity full, waiting list disabled.
  tournamentFull,

  /// Pre-registration is not enabled for this tournament.
  preRegDisabled,
}

enum DecklistArea {
  main(10),
  side(15),
  extra(15);

  final int columnSize;
  const DecklistArea(this.columnSize);
}

extension CardTypeX on CardType {
  static CardType? tryParse(String? value) {
    return value != null ? CardType.values.where((e) => e.name == value).firstOrNull : null;
  }
}

enum CardType {
  synchro(Color(0xFFCFD3DA), Color(0xFF000000)),
  fusion(Color(0xFF9966cc), Color(0xFF000000)),
  effect(Color(0xFFEA742C), Color(0xFF000000)),
  ritual(Color(0xFF99ccff), Color(0xFF000000)),
  xyz(Color(0xFF333333), Color(0xFFffffff)),
  link(Color(0xFF003399), Color(0xFF000000)),
  normal(Color(0xFFffcc77), Color(0xFF000000)),
  spell(Color(0xFF1F9585), Color(0xFF000000)),
  trap(Color(0xFFa249a4), Color(0xFF000000));

  final Color outer;
  final Color inner;

  const CardType(this.outer, this.inner);
}

class DecklistAndImage {
  Decklist list;
  td.Uint8List img;

  DecklistAndImage({
    required this.list,
    required this.img,
  });
}

class Decklist {
  late Map<CardRef, int> main;
  late Map<CardRef, int> side;
  late Map<CardRef, int> extra;

  Decklist(){
    main = {};
    side = {};
    extra = {};
  }

  void addCardRef(CardRef cardRef, DecklistArea area){
    switch(area){
      case DecklistArea.main:
        main[cardRef] = (main[cardRef] ?? 0) + 1;
      case DecklistArea.side:
        side[cardRef] = (side[cardRef] ?? 0) + 1;
      case DecklistArea.extra:
        extra[cardRef] = (extra[cardRef] ?? 0) + 1;
    }
  }
  void addCardRefRaw({
    required int id,
    required String name,
    required String type,
    String? frameType,
    String? imageUrl,
    required DecklistArea area
  }){
    CardRef cardRef = CardRef(id: id, cardName: name);
    switch(area){
      case DecklistArea.main:
        main[cardRef] = (main[cardRef] ?? 0) + 1;
      case DecklistArea.side:
        side[cardRef] = (side[cardRef] ?? 0) + 1;
      case DecklistArea.extra:
        extra[cardRef] = (extra[cardRef] ?? 0) + 1;
    }
  }

  Map<String, dynamic> toJson() => {
    'main':  _encodeZone(main),
    'side':  _encodeZone(side),
    'extra': _encodeZone(extra),
  };

  factory Decklist.fromJson(Map<String, dynamic> json) {
    final decklist = Decklist();
    decklist.main  = _decodeZone(json['main']);
    decklist.side  = _decodeZone(json['side']);
    decklist.extra = _decodeZone(json['extra']);
    return decklist;
  }

  static List<Map<String, dynamic>> _encodeZone(Map<CardRef, int> zone) =>
      zone.entries.map((e) => {
        ...e.key.toJson(),
        'count': e.value,
      }).toList();

  static Map<CardRef, int> _decodeZone(List<dynamic> list) => {
    for (final e in list.cast<Map<String, dynamic>>())
      CardRef.fromJson(e): e['count'] as int,
  };
}

class CardRef {
  CardRef({
    required this.id,
    required this.cardName,
    this.type,
    this.frameType,
    this.imgUrl
  });

  int id;
  String cardName;
  String? type;
  String? frameType;
  Uri? imgUrl;

  Map<String, dynamic> toJson() => {
    'id': id,
    'cardName': cardName,
    'type': type,
    'frameType': frameType,
    'imgUrl': imgUrl?.toString(),
  };

  factory CardRef.fromJson(Map<String, dynamic> json) => CardRef(
    id:        json['id'] as int,
    cardName:  json['cardName'] as String,
    type:      json['type'] as String?,
    frameType: json['frameType'] as String?,
    imgUrl:    json['imgUrl'] != null ? Uri.tryParse(json['imgUrl'] as String) : null,
  );

  @override
  bool operator ==(Object other) =>
      other is CardRef &&
          other.id == id;

  @override
  int get hashCode => id.hashCode;
}

Future<DecklistAndImage> parseYdkFile(String ydkContent, int baseTileSize) async {
  final sw = Stopwatch()..start();
  //final CardsApiManagerService api = GetIt.instance<CardsApiManagerService>();
  final api = YgoProDeckClient(showDebugLogs: true);
  final lines = ydkContent.split('\n');

  // ── Pass 1: parse structure only (no I/O) ──────────────────────────────
  // Build the ordered sequence of (id, zone) and the set of unique IDs
  // that need to be fetched.
  final List<({int id, DecklistArea zone})> entries = [];
  final Set<int> uniqueIds = {};
  DecklistArea currentZone = DecklistArea.main;

  for (final raw in lines) {
    final line = raw.trim();
    if (line.isEmpty) continue;

    if (line == '#main')  { currentZone = DecklistArea.main;  continue; }
    if (line == '#extra') { currentZone = DecklistArea.extra; continue; }
    if (line == '!side')  { currentZone = DecklistArea.side;  continue; }
    // anything starting with # or ! that isn't a known section → skip
    if (line.startsWith('#') || line.startsWith('!')) continue;

    final id = int.tryParse(line);
    if (id == null) continue;

    entries.add((id: id, zone: currentZone));
    uniqueIds.add(id);
  }

  debugPrint('Pass 1 (parse): ${sw.elapsedMilliseconds}ms');
  sw.reset();

  // ── Pass 2: fetch all unique IDs in parallel ────────────────────────────
  // Future.wait fires every request at once instead of one-at-a-time.
  final CardInfoResponse info = await api.getCards(
    query: CardInfoQuery(
      id: uniqueIds.toList(),
    ),
  );
  final List<CardRef> fetched = info.data.map<CardRef>((card){
    return CardRef(
      id: card.id,
      cardName: card.name,
      type: card.type,
      frameType: card.frameType,
      imgUrl: card.cardImages != null && card.cardImages!.isNotEmpty ? Uri.parse(card.cardImages!.first.imageUrlCropped!) : null,
    );
  }).toList();
  debugPrint('Pass 2 (api and fetch): ${sw.elapsedMilliseconds}ms');
  sw.reset();

  final Map<int, ui.Image> imageCache = await _loadAll(fetched, baseTileSize);
  debugPrint('Pass 3 (load images): ${sw.elapsedMilliseconds}ms');
  sw.reset();
  final Map<int, CardRef> cache = {
    for (final ref in fetched) ref.id: ref,
  };

  // ── Pass 3: assemble the decklist in original order ─────────────────────
  final Decklist decklist = Decklist();
  for (final (:id, :zone) in entries) {
    final ref = cache[id];
    if (ref != null) decklist.addCardRef(ref, zone);
  }
  debugPrint('Pass 4 (create decklist): ${sw.elapsedMilliseconds}ms');
  sw.reset();

  final td.Uint8List png = await _render(
      imageCache,
      decklist,
      baseTileSize.toDouble()
  );
  debugPrint('Pass 5 (create image): ${sw.elapsedMilliseconds}ms');
  sw.reset();

  // Release native-backed image memory now that the PNG bytes are ready.
  for (final image in imageCache.values) {
    image.dispose();
  }
  return DecklistAndImage(list: decklist, img: png);
}

Future<Map<int, ui.Image>> _loadAll(
    List<CardRef> cards,
    int baseTileSize,
    ) async {
  final entries = await Future.wait(
    cards.map((card) async {
      final image = card.imgUrl != null
          ? await _loadImage(card.imgUrl!, baseTileSize)
          : await _placeholder(baseTileSize);
      return MapEntry(card.id, image);
    }),
  );

  return Map.fromEntries(entries);
}

Future<ui.Image> _loadImage(Uri uri, int baseTileSize) async {
  try {
    final response = await http.get(uri);
    if (response.statusCode != 200) return _placeholder(baseTileSize);
    final codec = await ui.instantiateImageCodec(
      response.bodyBytes,
      targetWidth: baseTileSize,  // decode at tile width; height stays proportional
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  } catch (_) {
    return _placeholder(baseTileSize);
  }
}

Future<ui.Image> _placeholder(int baseTileSize) async {
  final size = baseTileSize;
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    ui.Paint()..color = const ui.Color(0xFFBDBDBD),
  );
  final picture = recorder.endRecording();
  return picture.toImage(size, size);
}

Future<td.Uint8List> _render(
    Map<int, ui.Image> cacheImgMap,
    Decklist list,
    double baseTileSize,
    ) async {
  final recorder     = ui.PictureRecorder();
  final canvas       = ui.Canvas(recorder);
  final paint        = ui.Paint();
  final separatorColor  = const ui.Color(0xFFCCCCCC);
  final separatorHeight = 4.0;
  final sideTileSize  = (DecklistArea.main.columnSize * baseTileSize) / DecklistArea.side.columnSize;
  final extraTileSize = (DecklistArea.main.columnSize * baseTileSize) / DecklistArea.extra.columnSize;

  double offsetY = 0;

  // ── helper: draws one zone and advances offsetY ─────────────────────────
  void drawZone(
      Map<CardRef, int> zone,
      int columns,
      double tileSize,
      ) {
    int drawnCount = 0;
    for (final entry in zone.entries) {
      final ui.Image? img = cacheImgMap[entry.key.id];
      if (img == null) continue;

      // Center-crop: take the largest square from the middle of the image so
      // portrait/landscape art is not stretched to fill the square tile.
      final double w = img.width.toDouble();
      final double h = img.height.toDouble();
      final double cropSize = w < h ? w : h;
      final ui.Rect srcRect = ui.Rect.fromLTWH(
        (w - cropSize) / 2,
        (h - cropSize) / 2,
        cropSize,
        cropSize,
      );

      for (int i = 0; i < entry.value; i++) {
        final col = drawnCount % columns;
        final row = drawnCount ~/ columns;

        canvas.drawImageRect(
          img,
          srcRect,
          ui.Rect.fromLTWH(
            col * tileSize,
            offsetY + row * tileSize,
            tileSize,
            tileSize,
          ),
          paint,
        );
        drawnCount++;
      }
    }

    // Use the actual number of drawn cards so that skipped null-image cards
    // do not inflate the zone height with phantom empty rows.
    offsetY += (drawnCount / columns).ceil() * tileSize;
  }

  void drawSeparator() {
    canvas.drawRect(
      ui.Rect.fromLTWH(
        0, offsetY,
        DecklistArea.main.columnSize * baseTileSize,
        separatorHeight,
      ),
      ui.Paint()..color = separatorColor,
    );
    offsetY += separatorHeight;
  }

  // ── draw the three zones ────────────────────────────────────────────────
  drawZone(list.main,  DecklistArea.main.columnSize,  baseTileSize);
  drawSeparator();
  drawZone(list.side,  DecklistArea.side.columnSize,  sideTileSize);
  drawSeparator();
  drawZone(list.extra, DecklistArea.extra.columnSize, extraTileSize);

  // offsetY now holds the exact total height — no separate calculation needed
  final totalHeight = offsetY;

  // ── encode to PNG ───────────────────────────────────────────────────────
  final picture = recorder.endRecording();
  final ui.Image img = await picture.toImage(
    (DecklistArea.main.columnSize * baseTileSize).toInt(),
    totalHeight.toInt(),
  );
  final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
  img.dispose();
  return byteData!.buffer.asUint8List();
}