import 'package:pocketbase/pocketbase.dart';

abstract class PocketstoreRecord {
  PocketstoreRecord(this.reference, this.snapshotData);
  Map<String, dynamic> snapshotData;
  RecordModel reference;
}

DateTime? tryParseDate(String? dateStr){
  if (dateStr == null || dateStr.isEmpty) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (e) {
    return null;
  }
}