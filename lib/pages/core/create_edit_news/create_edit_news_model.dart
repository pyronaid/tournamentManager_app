import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tournamentmanager/app_flow/services/ImagePickerService.dart';

import '../../nav_bar/news_model.dart';

class CreateEditNewsModel extends ChangeNotifier {

  final bool saveWay;
  final NewsModel newsModel;

  late ImagePickerService imagePickerService;


  //////////////////////////////FORM TITLE
  late TextEditingController _fieldControllerTitle;
  late String? Function(BuildContext, String?)? newsTitleTextControllerValidator;
  late FocusNode _newsTitleFocusNode;
  String? _newsTitleTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Il titolo della News è un parametro obbligatorio';
    }
    return null;
  }
  //////////////////////////////FORM SUB TITLE
  late TextEditingController _fieldControllerSubTitle;
  late String? Function(BuildContext, String?)? newsSubTitleTextControllerValidator;
  late FocusNode _newsSubTitleFocusNode;
  String? _newsSubTitleTextControllerValidator(BuildContext context, String? val) {
    return null;
  }
  //////////////////////////////FORM DESCR
  late TextEditingController _fieldControllerDescription;
  late String? Function(BuildContext, String?)? newsDescriptionTextControllerValidator;
  late FocusNode _newsDescriptionFocusNode;
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
  CreateEditNewsModel({
    required this.saveWay,
    required this.newsModel,
  }){
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
    imagePickerService = GetIt.instance<ImagePickerService>();

    // Subscribe — when the stream emits the record, populate the controllers.
    newsModel.addListener(_onNewsModelChanged);

    // If the record is already available (e.g. cached), apply it immediately.
    _applyRecordIfAvailable();
  }

  // ---------------------------------------------------------------------------
  // LISTENER
  // Fires every time NewsModel calls notifyListeners() — i.e. on every
  // stream emission. We only act on the first real record to avoid
  // overwriting user edits with stale server data mid-session.
  // ---------------------------------------------------------------------------
  bool _recordApplied = false;

  void _onNewsModelChanged() {
    _applyRecordIfAvailable();
  }

  void _applyRecordIfAvailable() {
    // Guard: only apply once — after the user starts editing we must not
    // overwrite their in-progress changes with a new stream emission.
    if (_recordApplied) return;

    final record = newsModel.currentRecord;
    if (record == null) return;

    // Populate controllers from the live record.
    _fieldControllerTitle.text = record.title;
    _fieldControllerSubTitle.text = record.subTitle;
    _fieldControllerDescription.text = record.description;
    _newsShowTimestampEnVar = record.showTimestampEn;
    _useNetworkImage = newsModel.newsImageUrl != null;

    _recordApplied = true;
    notifyListeners();
  }


  /////////////////////////////GETTER
  bool get saveWayEn => saveWay;
  TextEditingController get fieldControllerTitle => _fieldControllerTitle;
  TextEditingController fieldControllerTitleWithInitValue({required String text}) {
    if(_fieldControllerTitle.text.isEmpty && text.isNotEmpty){
      _fieldControllerTitle.text=text;
    }
    return fieldControllerTitle;
  }
  FocusNode get newsTitleFocusNode => _newsTitleFocusNode;
  TextEditingController get fieldControllerSubTitle => _fieldControllerSubTitle;
  TextEditingController fieldControllerSubTitleWithInitValue({required String text}) {
    if(_fieldControllerSubTitle.text.isEmpty && text.isNotEmpty){
      _fieldControllerSubTitle.text=text;
    }
    return fieldControllerSubTitle;
  }
  FocusNode get newsSubTitleFocusNode => _newsSubTitleFocusNode;
  TextEditingController get fieldControllerDescription => _fieldControllerDescription;
  TextEditingController fieldControllerDescriptionWithInitValue({required String text}) {
    if(_fieldControllerDescription.text.isEmpty && text.isNotEmpty){
      _fieldControllerDescription.text=text;
    }
    return fieldControllerDescription;
  }
  FocusNode get newsDescriptionFocusNode => _newsDescriptionFocusNode;
  bool get newsShowTimestampEnVar => _newsShowTimestampEnVar;
  String? get newsImageUrlTemp => _newsImageUrlTemp;
  bool get useNetworkImage => _useNetworkImage;


  /////////////////////////////SETTER
  void setUseNetworkImage(bool boolValue) {
    _useNetworkImage = boolValue;
  }
  void setNewsShowTimestampEnVar(bool boolValue) {
    _newsShowTimestampEnVar = boolValue;
  }
  Future<void> setNewsImage(bool saveWayEn) async{
    bool? isCamera = true; //TO FIX WITH DIALOG FUNCTION
    XFile? imageFile = await imagePickerService.pickCropImage(
        cropAspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        imageSource: ImageSource.camera
    );
    if(imageFile != null) {
      _newsImageUrlTemp = imageFile.path;
      _useNetworkImage = false;
    }
    notifyListeners();
  }
  Future<void> cleanNewsImage(bool saveWayEn) async{
    _newsImageUrlTemp = null;
    _useNetworkImage = false;
    notifyListeners();
  }
  void switchShowTimestampEn() async {
    _newsShowTimestampEnVar = !_newsShowTimestampEnVar;
    notifyListeners();
  }


  @override
  void dispose() {
    newsModel.removeListener(_onNewsModelChanged);
    _fieldControllerTitle.dispose();
    _fieldControllerSubTitle.dispose();
    _fieldControllerDescription.dispose();
    _newsTitleFocusNode.dispose();
    _newsSubTitleFocusNode.dispose();
    _newsDescriptionFocusNode.dispose();
    super.dispose();
  }


}