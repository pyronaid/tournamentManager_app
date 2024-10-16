import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/pages/nav_bar/news_model.dart';
import 'package:tuple/tuple.dart';

import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../backend/backend.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import 'create_edit_news_model.dart';

class CreateEditNewsWidget extends StatefulWidget {
  const CreateEditNewsWidget({super.key});

  @override
  State<CreateEditNewsWidget> createState() => _CreateEditNewsWidgetState();
}


class _CreateEditNewsWidgetState extends State<CreateEditNewsWidget> with TickerProviderStateMixin {

  late CreateEditNewsModel createEditNewsModel;
  late NewsModel newsModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    createEditNewsModel = context.read<CreateEditNewsModel>();
    createEditNewsModel.initContextVars(context);
    newsModel = context.read<NewsModel>();
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => createEditNewsModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(createEditNewsModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Consumer<NewsModel>(
                    builder: (context, providerNews, _){
                      print("[BUILD IN CORSO] create_edit_news_widget.dart");
                      if(newsModel.isLoading){
                        return const Center(child: CircularProgressIndicator());
                      }
                      if(newsModel.newsImageUrl != null){
                        createEditNewsModel.setUseNetworkImage(true);
                      }
                      createEditNewsModel.setNewsShowTimestampEnVar(newsModel.newsShowTimestampEn);


                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          wrapWithModel(
                            model: createEditNewsModel.customAppbarModel,
                            updateCallback: () => setState(() {}),
                            child: CustomAppbarWidget(
                              backButton: true,
                              actionButton: false,
                              actionButtonAction: () async {},
                              optionsButtonAction: () async {},
                            ),
                          ),
                          ////////////////
                          //PAGE TITLE
                          /////////////////
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
                            child: Text(
                              createEditNewsModel.saveWayEn ? 'Crea una nuova notizia' : 'Modifica notizia',
                              style: CustomFlowTheme.of(context).displaySmall,
                            ),
                          ),
                          ////////////////
                          //FORM
                          /////////////////
                          Form(
                            key: _formKey,
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
                                        controller: createEditNewsModel.fieldControllerTitleWithInitValue(text: providerNews.newsTitle),
                                        focusNode: createEditNewsModel.newsTitleFocusNode,
                                        autofocus: false,
                                        autofillHints: const [AutofillHints.name],
                                        textCapitalization: TextCapitalization.sentences,
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
                                        validator: createEditNewsModel.newsTitleTextControllerValidator.asValidator(context),
                                      ),
                                    ],
                                  ),
                                ),
                                //////////////////////////////////////////
                                // Image News
                                //////////////////////////////////////////
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                                        child: Text(
                                          'Immagine news (facoltativo)',
                                          style: CustomFlowTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: CustomFlowTheme.of(context).accent1,
                                          ),
                                          child: Selector<CreateEditNewsModel, Tuple2<String?, bool>>(
                                            selector: (_, createEditNewsModelSelector) => Tuple2(createEditNewsModelSelector.newsImageUrlTemp, createEditNewsModelSelector.useNetworkImage),
                                            builder: (context, tuple,child) {
                                              if(tuple.item2){
                                                return Image.network(
                                                  providerNews.newsImageUrl!,
                                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) {
                                                      return child; // Image has fully loaded
                                                    } else {
                                                      return CircularProgressIndicator(
                                                        value: loadingProgress.expectedTotalBytes != null
                                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                            : null, // Shows a progress indicator if the loading size is known
                                                      );
                                                    }
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.error,
                                                      color: CustomFlowTheme.of(context).error,
                                                      size: 18,
                                                    ); // Display an error icon if the image fails to load
                                                  },
                                                );
                                              } else if(tuple.item1 != null){
                                                return Image.file(File(tuple.item1!),);
                                              } else {
                                                return Text("Nessuna immagine caricata");
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      Selector<CreateEditNewsModel, bool>(
                                        selector: (_, createEditNewsModelSelector) => createEditNewsModelSelector.useNetworkImage,
                                        builder: (context, flag, child) {
                                          return Row(
                                            children: [
                                              AFButtonWidget(
                                                onPressed: () async {
                                                  FocusScope.of(context).unfocus();
                                                  logFirebaseEvent('Button_load_pic');
                                                  createEditNewsModel.setNewsImage(createEditNewsModel.saveWay);
                                                  logFirebaseEvent('Button_haptic_feedback');
                                                  HapticFeedback.lightImpact();
                                                },
                                                text: 'Carica immagine',
                                                options: AFButtonOptions(
                                                  width: 40.w,
                                                  height: 50,
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                  color: CustomFlowTheme.of(context).primary,
                                                  textStyle: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).info),
                                                  elevation: 0,
                                                  borderSide: const BorderSide(
                                                    color: Colors.transparent,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(0),
                                                ),
                                              ),
                                              if(flag) ...[
                                                const SizedBox(width: 10,),
                                                AFButtonWidget(
                                                  onPressed: () async {
                                                    FocusScope.of(context).unfocus();
                                                    logFirebaseEvent('Button_load_pic');
                                                    createEditNewsModel.cleanNewsImage(createEditNewsModel.saveWay);
                                                    logFirebaseEvent('Button_haptic_feedback');
                                                    HapticFeedback.lightImpact();
                                                  },
                                                  text: 'Elimina immagine',
                                                  options: AFButtonOptions(
                                                    width: 40.w,
                                                    height: 50,
                                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                    iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                                    color: CustomFlowTheme.of(context).primary,
                                                    textStyle: CustomFlowTheme.of(context).labelLarge.override(color: CustomFlowTheme.of(context).info),
                                                    elevation: 0,
                                                    borderSide: const BorderSide(
                                                      color: Colors.transparent,
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius.circular(0),
                                                  ),
                                                ),
                                              ]
                                            ],
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                                //////////////////////////////////////////
                                // Sub-Title News
                                //////////////////////////////////////////
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                        child: Text(
                                          'Sotto Titolo news (facoltativo)',
                                          style: CustomFlowTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: createEditNewsModel.fieldControllerSubTitleWithInitValue(text: providerNews.newsSubTitle),
                                        focusNode: createEditNewsModel.newsSubTitleFocusNode,
                                        autofocus: false,
                                        autofillHints: const [AutofillHints.name],
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: standardInputDecoration(
                                          context,
                                          prefixIcon: Icon(
                                            Icons.text_fields,
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
                                        validator: createEditNewsModel.newsSubTitleTextControllerValidator.asValidator(context),
                                      ),
                                    ],
                                  ),
                                ),
                                //////////////////////////////////////////
                                // Description News
                                //////////////////////////////////////////
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                        child: Text(
                                          'Testo news',
                                          style: CustomFlowTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: createEditNewsModel.fieldControllerDescriptionWithInitValue(text: providerNews.newsDescription),
                                        focusNode: createEditNewsModel.newsDescriptionFocusNode,
                                        autofocus: false,
                                        autofillHints: const [AutofillHints.name],
                                        textCapitalization: TextCapitalization.sentences,
                                        textInputAction: TextInputAction.next,
                                        obscureText: false,
                                        decoration: standardInputDecoration(
                                          context,
                                          prefixIcon: Icon(
                                            Icons.article,
                                            color: CustomFlowTheme.of(context).secondaryText,
                                            size: 18,
                                          ),
                                        ),
                                        style: CustomFlowTheme.of(context).bodyLarge.override(
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 1,
                                        ),
                                        minLines: 5,
                                        maxLines: 5,
                                        cursorColor: CustomFlowTheme.of(context).primary,
                                        validator: createEditNewsModel.newsDescriptionTextControllerValidator.asValidator(context),
                                      ),
                                    ],
                                  ),
                                ),
                                //////////////////////////////////////////
                                // SHOW TIMESTAMP switch
                                //////////////////////////////////////////
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 30),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        child: Text(
                                          'Mostra data/ora della notizia',
                                          style: CustomFlowTheme.of(context).bodyMedium,
                                        ),
                                      ),
                                      Selector<CreateEditNewsModel, bool>(
                                        selector: (context, createEditNewsModelSelector) => createEditNewsModelSelector.newsShowTimestampEnVar,
                                        builder: (context, boolVar, child) {
                                          return Switch(
                                            value: boolVar,
                                            onChanged: (value) {
                                              createEditNewsModel.switchShowTimestampEn();
                                            },
                                          );
                                        },
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
                                createEditNewsModel.saveWayEn ? logFirebaseEvent('ONBOARDING_CREATE_NEWS_CREATE_NEWS') : logFirebaseEvent('ONBOARDING_EDIT_NEWS_EDIT_NEWS');
                                logFirebaseEvent('Button_validate_form');
                                if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                  return;
                                }

                                bool result = await newsModel.saveEditNews(
                                    createEditNewsModel.saveWayEn,
                                    createEditNewsModel.fieldControllerTitle.text,
                                    createEditNewsModel.fieldControllerSubTitle.text,
                                    createEditNewsModel.fieldControllerDescription.text,
                                    createEditNewsModel.newsImageUrlTemp,
                                    createEditNewsModel.newsShowTimestampEnVar
                                );
                                if(result){ Navigator.of(context).pop(); }
                                logFirebaseEvent('Button_haptic_feedback');
                                HapticFeedback.lightImpact();
                              },
                              text: createEditNewsModel.saveWayEn ? 'Crea News' : 'Modifica News',
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
                      );
                    }
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}