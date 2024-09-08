

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../backend/backend.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import 'create_edit_news_model.dart';

class CreateEditNewsWidget extends StatefulWidget {
  const CreateEditNewsWidget({
    super.key,
    this.tournamentsRef,
  });

  final TournamentsRecord? tournamentsRef;

  @override
  State<CreateEditNewsWidget> createState() => _CreateEditNewsWidgetState();
}


class _CreateEditNewsWidgetState extends State<CreateEditNewsWidget> with TickerProviderStateMixin {

  late final CreateEditNewsModel createEditNewsModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late final TextEditingController fieldControllerTitle;
  FocusNode? newsTitleFocusNode;
  String? Function(BuildContext, String?)? newsTitleTextControllerValidator;

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateNews'});
    //WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    createEditNewsModel = context.read<CreateEditNewsModel>();
    fieldControllerTitle = createEditNewsModel.fieldControllerTitle;
    newsTitleFocusNode = createEditNewsModel.newsTitleFocusNode;
    newsTitleTextControllerValidator = createEditNewsModel.newsTitleTextControllerValidator;
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    final bool newsShowTimestampEn = context.select((CreateEditNewsModel i) => i.newsShowTimestampEn);
    //final String newsTitle = context.select((CreateEditNewsModel i) => i.newsTitle);
    //final String newsSubTitle = context.select((CreateEditNewsModel i) => i.newsSubTitle);
    //final String newsDescription = context.select((CreateEditNewsModel i) => i.newsDescription);
    final String? newsImageUrl = context.select((CreateEditNewsModel i) => i.newsImageUrl);

    return GestureDetector(
      onTap: () => createEditNewsModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(createEditNewsModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*
                    wrapWithModel(
                      model: createEditNewsModel.customAppbarModel,
                      updateCallback: () => setState(() {}),
                      child: CustomAppbarWidget(
                        backButton: true,
                        actionButton: false,
                        actionButtonAction: () async {},
                        optionsButtonAction: () async {},
                      ),
                    ),*/
                    ////////////////
                    //PAGE TITLE
                    /////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
                      child: Text(
                        createEditNewsModel.saveWay ? 'Crea una nuova notizia' : 'Modifica notizia',
                        style: CustomFlowTheme.of(context).displaySmall,
                      ),
                    ),
                    ////////////////
                    //FORM
                    /////////////////
                    Form(
                      key: createEditNewsModel.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //////////////////////////////////////////
                          // Title News
                          //////////////////////////////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                  child: Text(
                                    'Titolo news',
                                    style: CustomFlowTheme.of(context).bodyMedium,
                                  ),
                                ),
                                TextFormField(
                                  controller: fieldControllerTitle,
                                  focusNode: newsTitleFocusNode,
                                  autofocus: false,
                                  autofillHints: const [AutofillHints.name],
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  obscureText: false,
                                  decoration: standardInputDecoration(
                                    context,
                                    prefixIcon: Icon(
                                      Icons.title,
                                      color: CustomFlowTheme.of(context).secondaryText,
                                      size: 18,
                                    ),
                                  ),
                                  style: CustomFlowTheme.of(context).bodyLarge.override(
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 1,
                                  ),
                                  minLines: 1,
                                  cursorColor: CustomFlowTheme.of(context).primary,
                                  validator: newsTitleTextControllerValidator.asValidator(context),
                                ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ),
                    ////////////////
                    //VALIDATION BUTTON
                    /////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                      child: AFButtonWidget(
                        onPressed: () async {
                          FocusScope.of(context).unfocus();
                          createEditNewsModel.saveWay ? logFirebaseEvent('ONBOARDING_CREATE_NEWS_CREATE_NEWS') : logFirebaseEvent('ONBOARDING_EDIT_NEWS_EDIT_NEWS');
                          logFirebaseEvent('Button_validate_form');
                          if (createEditNewsModel.formKey.currentState == null ||
                          !createEditNewsModel.formKey.currentState!.validate()) {
                          return;
                          }
                          createEditNewsModel.saveWay ? createEditNewsModel.saveNews() : createEditNewsModel.editNews();

                          logFirebaseEvent('Button_haptic_feedback');
                          HapticFeedback.lightImpact();
                          },
                        text: createEditNewsModel.saveWay ? 'Crea News' : 'Modifica News',
                        options: AFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: CustomFlowTheme.of(context).primary,
                          textStyle: CustomFlowTheme.of(context).titleSmall,
                          elevation: 0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}