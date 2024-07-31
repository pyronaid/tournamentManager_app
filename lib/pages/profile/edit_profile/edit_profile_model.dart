import 'package:flutter/cupertino.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../components/custom_appbar_model.dart';
import '../../../components/title_with_subtitle/title_with_subtitle_model.dart';
import 'edit_profile_widget.dart';

class EditProfileModel extends CustomFlowModel<EditProfileWidget> {
  ///  Local state fields for this page.

  bool unsavedChanges = false;

  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // Model for customAppbar component.
  late CustomAppbarModel customAppbarModel;
  // State field(s) for fullName widget.
  FocusNode? fullNameFocusNode;
  TextEditingController? fullNameTextController;
  String? Function(BuildContext, String?)? fullNameTextControllerValidator;
  // Model for titleWithSubtitle component.
  late TitleWithSubtitleModel titleWithSubtitleModel1;
  // Model for titleWithSubtitle component.
  late TitleWithSubtitleModel titleWithSubtitleModel2;
  // State field(s) for emailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {
    customAppbarModel = createModel(context, () => CustomAppbarModel());
    titleWithSubtitleModel1 = createModel(context, () => TitleWithSubtitleModel());
    titleWithSubtitleModel2 = createModel(context, () => TitleWithSubtitleModel());
  }

  @override
  void dispose() {
    unfocusNode.dispose();
    customAppbarModel.dispose();
    fullNameFocusNode?.dispose();
    fullNameTextController?.dispose();

    titleWithSubtitleModel1.dispose();
    titleWithSubtitleModel2.dispose();
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
