
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

final FirebaseStorage _storage = FirebaseStorage.instance;

class FirestorageUtilData {

  static Future<String?> uploadImageToStorage(String path, XFile? file) async {
    if(file != null) {
      Reference ref = _storage.ref().child(path);
      Uint8List imageData = await file.readAsBytes();
      UploadTask uploadTask = ref.putData(imageData);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      return imageUrl;
    }
    return null;
  }

}