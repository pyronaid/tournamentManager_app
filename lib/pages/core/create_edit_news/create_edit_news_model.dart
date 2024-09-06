import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/services/ImagePickerService.dart';
import '../../../backend/schema/news_record.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../backend/schema/util/firestorage_util.dart';
import '../../../components/custom_appbar_model.dart';

class CreateEditNewsModel extends ChangeNotifier {

  final NewsRecord? newsRef;
  final TournamentsRecord? tournamentsRef;
  final bool saveWay;

  final unfocusNode = FocusNode();
  late CustomAppbarModel customAppbarModel;

  final formKey = GlobalKey<FormState>();
  //////////////////////////////FORM TITLE
  late TextEditingController _fieldControllerTitle;
  late String? Function(BuildContext, String?)? newsTitleTextControllerValidator;
  late FocusNode? newsTitleFocusNode;
  String? _newsTitleTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il titolo della News è un parametro obbligatorio';
    }

    if (!saveWay && val == newsTitle){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }
  //////////////////////////////FORM SUB TITLE
  late TextEditingController _fieldControllerSubTitle;
  late String? Function(BuildContext, String?)? newsSubTitleTextControllerValidator;
  late FocusNode? newsSubTitleFocusNode;
  String? _newsSubTitleTextControllerValidator(BuildContext context, String? val) {
    return null;
  }
  //////////////////////////////FORM DESCR
  late TextEditingController _fieldControllerDescription;
  late String? Function(BuildContext, String?)? newsDescriptionTextControllerValidator;
  late FocusNode? newsDescriptionFocusNode;
  String? _newsDescriptionTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il testo della News è un parametro obbligatorio';
    }

    if (!saveWay && val == newsDescription){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }
  //////////////////////////////FORM IMAGE
  late String? newsImageUrlTemp;
  //////////////////////////////FORM SWITCH TIMESTAMP
  late bool newsShowTimestampEnVar;


  /////////////////////////////CONSTRUCTOR
  CreateEditNewsModel({
    required this.newsRef,
    required this.saveWay,
    required this.tournamentsRef}){

    _fieldControllerTitle = TextEditingController(text: newsTitle);
    newsTitleTextControllerValidator = _newsTitleTextControllerValidator;
    newsTitleFocusNode = FocusNode();
    _fieldControllerSubTitle = TextEditingController(text: newsSubTitle);
    newsSubTitleTextControllerValidator = _newsSubTitleTextControllerValidator;
    newsSubTitleFocusNode = FocusNode();
    _fieldControllerDescription = TextEditingController(text: newsDescription);
    newsDescriptionTextControllerValidator = _newsDescriptionTextControllerValidator;
    newsDescriptionFocusNode = FocusNode();
    newsShowTimestampEnVar = newsShowTimestampEn;
    newsImageUrlTemp = null;
  }

  /////////////////////////////GETTER
  String? get tournamentId{
    return tournamentsRef?.uid;
  }
  String? get tournamentOwner{
    return tournamentsRef?.creatorUid;
  }
  String? get newsId{
    return newsRef?.uid;
  }
  String get newsTitle{
    return newsRef != null ? newsRef!.title : "";
  }
  String get newsSubTitle{
    return newsRef != null ? newsRef!.subTitle : "";
  }
  String get newsDescription{
    return newsRef != null ? newsRef!.description : "";
  }
  bool get newsShowTimestampEn{
    return newsRef != null ? newsRef!.showTimestampEn : false;
  }
  String? get newsImageUrl{
    return newsRef != null ? newsRef!.imageNewsUrl : newsImageUrlTemp;
  }
  TextEditingController get fieldControllerTitle{
    return _fieldControllerTitle;
  }
  TextEditingController get fieldControllerSubTitle{
    return _fieldControllerSubTitle;
  }
  TextEditingController get fieldControllerDescription{
    return _fieldControllerDescription;
  }

  /////////////////////////////SETTER
  Future<void> switchNewsShowTimestampEn() async {
    newsShowTimestampEnVar = !newsShowTimestampEnVar;
    notifyListeners();
  }
  Future<void> setNewsImage() async{

    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION

    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        imageSource: ImageSource.camera
    );

    if(saveWay && imageFile != null) {
      String? url = await FirestorageUtilData.uploadImageToStorage(
          "users/$tournamentOwner/$tournamentId/$newsId/newsImage",
          imageFile
      );
      if(url != null){
        //await newsRef?.setImage(url);
        notifyListeners();
      }
    } else if(imageFile != null){
      String? url = File(imageFile.path) as String?;
      if(url != null){
        newsImageUrlTemp = url;
        notifyListeners();
      }
    }
  }
  Future<void> saveNews() async {
    //TODO
    // no need to notify but just snackbar message
  }
  Future<void> editNews() async {
    //TODO
    // no need to notify but just snackbar message
  }


  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
    newsTitleFocusNode?.dispose();
    newsSubTitleFocusNode?.dispose();
    newsDescriptionFocusNode?.dispose();
    _fieldControllerTitle.dispose();
    _fieldControllerSubTitle.dispose();
    _fieldControllerDescription.dispose();
    super.dispose();
  }

  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

}