import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/pages/nav_bar/news_model.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/services/ImagePickerService.dart';
import '../../../components/custom_appbar_model.dart';

class CreateEditNewsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  final bool saveWay;
  late CustomAppbarModel customAppbarModel;

  final NewsModel newsModel;

  //////////////////////////////FORM TITLE
  late TextEditingController _fieldControllerTitle;
  late String? Function(BuildContext, String?, String?)? newsTitleTextControllerValidator;
  late FocusNode? _newsTitleFocusNode;
  String? _newsTitleTextControllerValidator(BuildContext context, String? val, String? valOld) {
    if (val == null || val.isEmpty) {
      return 'Il titolo della News è un parametro obbligatorio';
    }

    if (!saveWayEn && val == valOld){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }
  //////////////////////////////FORM SUB TITLE
  late TextEditingController _fieldControllerSubTitle;
  late String? Function(BuildContext, String?, String?)? newsSubTitleTextControllerValidator;
  late FocusNode? _newsSubTitleFocusNode;
  String? _newsSubTitleTextControllerValidator(BuildContext context, String? val, String? valOld) {
    return null;
  }
  //////////////////////////////FORM DESCR
  late TextEditingController _fieldControllerDescription;
  late String? Function(BuildContext, String?, String?)? newsDescriptionTextControllerValidator;
  late FocusNode? _newsDescriptionFocusNode;
  String? _newsDescriptionTextControllerValidator(BuildContext context, String? val, String? valOld) {
    if (val == null || val.isEmpty) {
      return 'Il testo della News è un parametro obbligatorio';
    }

    if (!saveWayEn && val == valOld){
      return "Non hai fatto nessun cambiamento";
    }
    return null;
  }
  //////////////////////////////FORM IMAGE
  late String? _newsImageUrlTemp;
  late bool _useNetworkImage;
  //////////////////////////////FORM SWITCH TIMESTAMP
  late bool _newsShowTimestampEnVar;


  /////////////////////////////CONSTRUCTOR
  CreateEditNewsModel({required this.saveWay, required this.newsModel}){
    _initSettings();
  }
  Future<void> _initSettings() async {
    // Wait for the profile to load
    while (newsModel.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _fieldControllerTitle = TextEditingController(text: newsModel.newsTitle);
    newsTitleTextControllerValidator = _newsTitleTextControllerValidator;
    _newsTitleFocusNode = FocusNode();
    _fieldControllerSubTitle = TextEditingController(text: newsModel.newsSubTitle);
    newsSubTitleTextControllerValidator = _newsSubTitleTextControllerValidator;
    _newsSubTitleFocusNode = FocusNode();
    _fieldControllerDescription = TextEditingController(text: newsModel.newsDescription);
    newsDescriptionTextControllerValidator = _newsDescriptionTextControllerValidator;
    _newsDescriptionFocusNode = FocusNode();
    _newsShowTimestampEnVar = newsModel.newsShowTimestampEn;
    _useNetworkImage = newsModel.newsImageUrl != null;
    _newsImageUrlTemp = newsModel.newsImageUrl;
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  bool get saveWayEn{
    return saveWay;
  }
  TextEditingController get fieldControllerTitle{
    return _fieldControllerTitle;
  }
  FocusNode? get newsTitleFocusNode{
    return _newsTitleFocusNode;
  }
  TextEditingController get fieldControllerSubTitle{
    return _fieldControllerSubTitle;
  }
  FocusNode? get newsSubTitleFocusNode{
    return _newsSubTitleFocusNode;
  }
  TextEditingController get fieldControllerDescription{
    return _fieldControllerDescription;
  }
  FocusNode? get newsDescriptionFocusNode{
    return _newsDescriptionFocusNode;
  }
  bool get newsShowTimestampEnVar{
    return _newsShowTimestampEnVar;
  }
  String? get newsImageUrlTemp{
    return _newsImageUrlTemp;
  }
  bool get useNetworkImage{
    return _useNetworkImage;
  }
  /////////////////////////////GETTER FROM OBJ
  bool get isLoading => newsModel.isLoading;
  String? get newsTitle => newsModel.newsTitle;
  String? get newsSubTitle => newsModel.newsSubTitle;
  String? get newsDescription => newsModel.newsDescription;
  get newsImageUrl => newsModel.newsImageUrl;


  /////////////////////////////SETTER
  Future<void> setNewsImage(bool saveWayEn) async{
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        imageSource: ImageSource.camera
    );
    if(imageFile != null) {
      _newsImageUrlTemp = imageFile.path;
    }
    notifyListeners();
  }
  void switchShowTimestampEn() async {
    _newsShowTimestampEnVar = !_newsShowTimestampEnVar;
    notifyListeners();
  }
  /////////////////////////////SETTER FROM OBJ
  saveEditNews(bool saveWayEn) => newsModel.saveEditNews(saveWayEn);


  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
    _fieldControllerTitle.dispose();
    _fieldControllerSubTitle.dispose();
    _fieldControllerDescription.dispose();
    _newsTitleFocusNode?.dispose();
    _newsSubTitleFocusNode?.dispose();
    _newsDescriptionFocusNode?.dispose();
    super.dispose();
  }


  void initContextVars(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
  }

}