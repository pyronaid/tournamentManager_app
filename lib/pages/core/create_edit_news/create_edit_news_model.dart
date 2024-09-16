import 'package:flutter/cupertino.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';

class CreateEditNewsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();
  final bool saveWay;
  late CustomAppbarModel customAppbarModel;
  final _formKey = GlobalKey<FormState>();

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
    _newsImageUrlTemp = null;
  }


  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  bool get saveWayEn{
    return saveWay;
  }
  GlobalKey<FormState> get formKey{
    return _formKey;
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


  /////////////////////////////SETTER
  void setFieldControllerTitle(String textVal){
    _fieldControllerTitle.text = textVal;
  }
  void setFieldControllerSubTitle(String textVal){
    _fieldControllerSubTitle.text = textVal;
  }
  void setFieldControllerDescription(String textVal){
    _fieldControllerDescription.text = textVal;
  }
  void setNewsShowTimestampEnVar(bool textVal){
    _newsShowTimestampEnVar = textVal;
  }
  Future<void> switchNewsShowTimestampEn() async {
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