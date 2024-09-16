import 'dart:io';

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
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../nav_bar/news_model.dart';
import 'create_edit_news_model.dart';

class CreateEditNewsWidget extends StatefulWidget {
  const CreateEditNewsWidget({super.key});

  @override
  State<CreateEditNewsWidget> createState() => _CreateEditNewsWidgetState();
}


class _CreateEditNewsWidgetState extends State<CreateEditNewsWidget> with TickerProviderStateMixin {

  late CreateEditNewsModel createEditNewsModel;
  late NewsModel newsModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    newsModel = context.read<NewsModel>();
    createEditNewsModel = context.read<CreateEditNewsModel>();
    createEditNewsModel.initContextVars(context);
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
        key: scaffoldKey,
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
                    print("[REBUILD IN CORSO] create_edit_news_widget.dart");
                    if(newsModel.isLoading){
                      return const Center(child: CircularProgressIndicator());
                    }

                    createEditNewsModel.setFieldControllerTitle(newsModel.newsTitle);
                    createEditNewsModel.setFieldControllerSubTitle(newsModel.newsSubTitle);
                    createEditNewsModel.setFieldControllerDescription(newsModel.newsDescription);
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
                                      controller: createEditNewsModel.fieldControllerTitle,
                                      focusNode: createEditNewsModel.newsTitleFocusNode,
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
                                      validator: createEditNewsModel.newsTitleTextControllerValidator.asValidator(context, newsModel.newsTitle),
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
                                    //area
                                    if(newsModel.newsImageUrl != null)
                                      Image.network(
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
                                      )
                                    else if(providerNews.newsImageUrlTemp != null)
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: CustomFlowTheme.of(context).accent1,
                                          ),
                                          child: Image.file(File(providerNews.newsImageUrlTemp!),)
                                        ),
                                      ),

                                    // button upload
                                      AFButtonWidget(
                                        onPressed: () async {
                                          FocusScope.of(context).unfocus();
                                          logFirebaseEvent('Button_load_pic');
                                          newsModel.setNewsImage(createEditNewsModel.saveWay);
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
                                      controller: createEditNewsModel.fieldControllerSubTitle,
                                      focusNode: createEditNewsModel.newsSubTitleFocusNode,
                                      autofocus: false,
                                      autofillHints: const [AutofillHints.name],
                                      textCapitalization: TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: standardInputDecoration(
                                        context,
                                        prefixIcon: Icon(
                                          Icons.style,
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
                                      validator: createEditNewsModel.newsSubTitleTextControllerValidator.asValidator(context, providerNews.newsSubTitle),
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
                                      controller: createEditNewsModel.fieldControllerDescription,
                                      focusNode: createEditNewsModel.newsDescriptionFocusNode,
                                      autofocus: false,
                                      autofillHints: const [AutofillHints.name],
                                      textCapitalization: TextCapitalization.words,
                                      textInputAction: TextInputAction.next,
                                      obscureText: false,
                                      decoration: standardInputDecoration(
                                        context,
                                        prefixIcon: Icon(
                                          Icons.style,
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
                                      validator: createEditNewsModel.newsDescriptionTextControllerValidator.asValidator(context, providerNews.newsDescription),
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
                                    Switch(
                                        value: providerNews.newsShowTimestampEn,
                                        onChanged: (value){
                                          newsModel.switchTournamentWaitingListEn();
                                        }
                                    )
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
                              if (createEditNewsModel.formKey.currentState == null || !createEditNewsModel.formKey.currentState!.validate()) {
                                return;
                              }
                              if(createEditNewsModel.saveWayEn) {
                                newsModel.saveNews(
                                  createEditNewsModel.fieldControllerTitle.text,
                                  createEditNewsModel.fieldControllerSubTitle.text,
                                  createEditNewsModel.fieldControllerDescription.text,
                                ).then((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'News creata con successo',
                                        style: CustomFlowTheme.of(context).displaySmall.override( color: CustomFlowTheme.of(context).primary ),
                                      ),
                                    ),
                                  );
                                  //logFirebaseEvent('Button_navigate_to');
                                  //context.goNamedAuth('Dashboard', context.mounted);
                                }).catchError((onError){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Errore nella creazione della News. Riprova più tardi',
                                          style: CustomFlowTheme.of(context).displaySmall.override( color: CustomFlowTheme.of(context).error ),
                                        ),
                                      )
                                  );
                                });
                              } else {
                                newsModel.editNews(
                                  createEditNewsModel.fieldControllerTitle.text,
                                  createEditNewsModel.fieldControllerSubTitle.text,
                                  createEditNewsModel.fieldControllerDescription.text,
                                );
                              }

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