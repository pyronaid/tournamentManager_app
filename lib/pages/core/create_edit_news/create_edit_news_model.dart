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


  //////////////////////////////FORM TITLE
  late TextEditingController _fieldControllerTitle;
  late String? Function(BuildContext, String?)? newsTitleTextControllerValidator;
  late FocusNode? _newsTitleFocusNode;
  String? _newsTitleTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il titolo della News è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FORM SUB TITLE
  late TextEditingController _fieldControllerSubTitle;
  late String? Function(BuildContext, String?)? newsSubTitleTextControllerValidator;
  late FocusNode? _newsSubTitleFocusNode;
  String? _newsSubTitleTextControllerValidator(BuildContext context, String? val) {
    return null;
  }
  //////////////////////////////FORM DESCR
  late TextEditingController _fieldControllerDescription;
  late String? Function(BuildContext, String?)? newsDescriptionTextControllerValidator;
  late FocusNode? _newsDescriptionFocusNode;
  String? _newsDescriptionTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il testo della News è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FORM IMAGE
  late String? _newsImageUrlTemp;
  late bool _useNetworkImage;
  //////////////////////////////FORM SWITCH TIMESTAMP
  late bool _newsShowTimestampEnVar;


  /////////////////////////////CONSTRUCTOR
  CreateEditNewsModel({required this.saveWay}){
    _fieldControllerTitle = TextEditingController();
    newsTitleTextControllerValidator = _newsTitleTextControllerValidator;
    _newsTitleFocusNode = FocusNode();
    _fieldControllerSubTitle = TextEditingController();
    newsSubTitleTextControllerValidator = _newsSubTitleTextControllerValidator;
    _newsSubTitleFocusNode = FocusNode();
    _fieldControllerDescription = TextEditingController();
    newsDescriptionTextControllerValidator = _newsDescriptionTextControllerValidator;
    _newsDescriptionFocusNode = FocusNode();
    _newsShowTimestampEnVar = false;
    _useNetworkImage = false;
    _newsImageUrlTemp = null;
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
  TextEditingController fieldControllerTitleWithInitValue({required String text}) {
    if(_fieldControllerTitle.text.isEmpty && text.isNotEmpty){
      _fieldControllerTitle.text=text;
    }
    return fieldControllerTitle;
  }
  FocusNode? get newsTitleFocusNode{
    return _newsTitleFocusNode;
  }
  TextEditingController get fieldControllerSubTitle{
    return _fieldControllerSubTitle;
  }
  TextEditingController fieldControllerSubTitleWithInitValue({required String text}) {
    if(_fieldControllerSubTitle.text.isEmpty && text.isNotEmpty){
      _fieldControllerSubTitle.text=text;
    }
    return fieldControllerSubTitle;
  }
  FocusNode? get newsSubTitleFocusNode{
    return _newsSubTitleFocusNode;
  }
  TextEditingController get fieldControllerDescription{
    return _fieldControllerDescription;
  }
  TextEditingController fieldControllerDescriptionWithInitValue({required String text}) {
    if(_fieldControllerDescription.text.isEmpty && text.isNotEmpty){
      _fieldControllerDescription.text=text;
    }
    return fieldControllerDescription;
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


  /////////////////////////////SETTER
  void setUseNetworkImage(bool boolValue) {
    _useNetworkImage = boolValue;
  }
  void setNewsShowTimestampEnVar(bool boolValue) {
    _newsShowTimestampEnVar = boolValue;
  }
  Future<void> setNewsImage(bool saveWayEn) async{
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await ImagePickerService().pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        imageSource: ImageSource.camera
    );
    if(imageFile != null) {
      _newsImageUrlTemp = imageFile.path;
      _useNetworkImage = false;
    }
    notifyListeners();
  }
  void switchShowTimestampEn() async {
    _newsShowTimestampEnVar = !_newsShowTimestampEnVar;
    notifyListeners();
  }


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