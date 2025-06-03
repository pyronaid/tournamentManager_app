import 'package:pocketbase/pocketbase.dart';

import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

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

String? getFileUrl(String collectionId, String id, String? pathName) {
  if(pathName == null || pathName.isEmpty){
    return null;
  }
  return '$pbBaseUri/api/files/$collectionId/$id/$pathName';
}


enum ClientErrorCodes{
  validation_not_unique('Il valore inserito è già presente nel nostro sistema.'),
  unknown('Errore sconosciuto nel processare questo campo');

  const ClientErrorCodes(this.message);
  final String message;

  static ClientErrorCodes fromString(String name) {
    for (ClientErrorCodes code in ClientErrorCodes.values) {
      if (code.name == name) return code;
    }
    return unknown;
  }

  static String getMessageFromString(String errorCode) {
    final enumValue = fromString(errorCode);
    return enumValue.message;
  }
}