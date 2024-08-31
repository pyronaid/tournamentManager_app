import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerService{
  Future<XFile?> pickCropImage({
    required CropAspectRatio cropAspectRatio,
    required ImageSource imageSource,
  }) async {
    //PIckImage step
    XFile? pickedImage = await ImagePicker().pickImage(source: imageSource);
    if(pickedImage == null) return null;

    //CropImage step
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: cropAspectRatio,
      compressQuality: 90,
      compressFormat: ImageCompressFormat.jpg
    );
    if(croppedFile == null) return null;
    
    return XFile(croppedFile.path);
  }
}