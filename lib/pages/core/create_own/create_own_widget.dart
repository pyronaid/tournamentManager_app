import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_model.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../backend/firebase_analytics/analytics.dart';
import '../../../components/custom_appbar_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_page_indicator;

import 'create_own_model.dart';

class CreateOwnWidget extends StatefulWidget {
  const CreateOwnWidget({super.key});

   @override
  State<CreateOwnWidget> createState() => _CreateOwnWidgetState();
}


class _CreateOwnWidgetState extends State<CreateOwnWidget> with TickerProviderStateMixin {
  late CreateOwnModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final animationsMap = <String, AnimationInfo>{};


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateOwnModel());

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Create_Own'});
    animationsMap.addAll({
      'imageOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
      'imageOnPageLoadAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
          ),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }


  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child: Column(/*
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Align(
                  alignment: const AlignmentDirectional(0, 0),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        wrapWithModel(
                          model: _model.customAppbarModel,
                          updateCallback: () => setState(() {}),
                          child: CustomAppbarWidget(
                            backButton: true,
                            actionButton: false,
                            actionButtonAction: () async {},
                            optionsButtonAction: () async {},
                          ),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            height: 30.h,  
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 50),
                                  child: PageView(
                                    controller: _model.pageViewController ??= PageController(initialPage: 0),
                                    scrollDirection: Axis.horizontal,
                                    onPageChanged: (int page) {
                                        setState(() {
                                        _model.currentPage = page;
                                      });
                                    },
                                    children: [
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_ygo_adv.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation1']!),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_ygo_rtf.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation2']!),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_ygo_mtg.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation3']!),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_op.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation4']!),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_op.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation5']!),
                                          ),
                                        ],
                                      ),
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      //////////////////////////////////////////////////
                                      // ELEMENT OF CAROUSEL
                                      Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                            child: Image.asset(
                                              'assets/images/game_alt.png',
                                              height: 35.h,
                                              fit: BoxFit.fill,
                                            ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation6']!),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                //////////////////////////////////////////
                                // FORM
                                //////////////////////////////////////////
                                Form(
                                  key: _model.formKey,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      //////////////////////////////////////////
                                      // Dropdown banner obj
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Gioco',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            DropdownButton<int>(
                                              value: _model.currentPage,
                                              items: List.generate(
                                                _model.games.length,
                                                (index) => DropdownMenuItem(
                                                  value: index,
                                                  child: Text(_model.games[index]),
                                                ),
                                              ),
                                              onChanged: (int value) {
                                                setState(() {
                                                  _model.currentPage = value;
                                                  _model.gameDropDownButtonController.animateToPage(
                                                    value,
                                                    duration: Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                });
                                              },
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              validator: _model
                                                .gameDropDownButtonControllerValidator
                                                .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // Name tournament
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Nome torneo',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _model.tournamentNameTextController,
                                              focusNode: _model.tournamentNameFocusNode,
                                              autofocus: false,
                                              // autofillHints: const [AutofillHints.name],
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).primary,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                                                errorMaxLines: 2,
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              minLines: 1,
                                              cursorColor: CustomFlowTheme.of(context).primary,
                                              validator: _model
                                                  .tournamentNameTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // datepicker obj
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Data torneo',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _model.tournamentDateTextController,
                                              focusNode: _model.tournamentDateFocusNode,
                                              autofocus: false,
                                              readOnly: true,
                                              // autofillHints: const [AutofillHints.name],
                                              //textCapitalization: TextCapitalization.words,
                                              //textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).primary,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                                                errorMaxLines: 2,
                                                labelText: 'Data',
                                                suffixIcon: IconButton(
                                                  icon: Icon(Icons.calendar_today),
                                                  onPressed: () => _model.selectDate(context),
                                                ),
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              minLines: 1,
                                              cursorColor: CustomFlowTheme.of(context).primary,
                                              validator: _model
                                                  .tournamentDateTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // city Name 
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Città',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            DropdownButton<String>(
                                              value: _model.currentCity,
                                              items: italianCities.map<DropdownMenuItem<String>>((String city) {
                                                return DropdownMenuItem<String>(
                                                  value: city,
                                                  child: Text(city),
                                                );
                                              }).toList(),
                                              onChanged: (int value) {
                                                setState(() {
                                                  _model.currentCity = value;
                                                  _model.gameDropDownButtonController.animateToPage(
                                                    value,
                                                    duration: Duration(milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                });
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'Città',
                                                hintText: 'Scegli la città',
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              validator: _model
                                                .cityDropDownButtonControllerValidator
                                                .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // address tournament
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Indirizzo torneo',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _model.tournamentAddressTextController,
                                              focusNode: _model.tournamentAddressFocusNode,
                                              autofocus: false,
                                              // autofillHints: const [AutofillHints.name],
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).primary,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                                                errorMaxLines: 2,
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              minLines: 1,
                                              cursorColor: CustomFlowTheme.of(context).primary,
                                              validator: _model
                                                  .tournamentAddressTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // capacity tournament
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Capienza torneo',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _model.tournamentCapacityTextController,
                                              focusNode: _model.tournamentCapacityFocusNode,
                                              autofocus: false,
                                              // autofillHints: const [AutofillHints.name],
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).primary,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                                                errorMaxLines: 2,
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              minLines: 1,
                                              cursorColor: CustomFlowTheme.of(context).primary,
                                              validator: _model
                                                  .tournamentCapacityTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // PRE-REGISTRATION switch
                                      //////////////////////////////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                              child: Text(
                                                'Abilita pre registrazione',
                                                style: CustomFlowTheme.of(context)
                                                    .bodyMedium
                                                    .override(
                                                      fontFamily: 'Inter',
                                                      letterSpacing: 0,
                                                ),
                                              ),
                                            ),
                                            FormField<bool>(
                                              initialValue: _model.preregistrationEnable,



                                              
                                              controller: _model.tournamentCapacityTextController,
                                              focusNode: _model.tournamentCapacityFocusNode,
                                              autofocus: false,
                                              // autofillHints: const [AutofillHints.name],
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.next,
                                              obscureText: false,
                                              decoration: InputDecoration(
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).alternate,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).primary,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                errorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                focusedErrorBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: CustomFlowTheme.of(context).error,
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                filled: true,
                                                fillColor: CustomFlowTheme.of(context).secondaryBackground,
                                                errorMaxLines: 2,
                                              ),
                                              style: CustomFlowTheme.of(context)
                                                  .bodyMedium
                                                  .override(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w500,
                                                    lineHeight: 1,
                                              ),
                                              minLines: 1,
                                              cursorColor: CustomFlowTheme.of(context).primary,
                                              validator: _model
                                                  .tournamentCapacityTextControllerValidator
                                                  .asValidator(context),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //////////////////////////////////////////
                                      // Waiting-list switch
                                      //////////////////////////////////////////
                                      
                                    ],
                                  ),
                                ),











                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              //BUTTON CONTINUE
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      child: AFButtonWidget(
                        onPressed: () async {
                          logFirebaseEvent('ONBOARDING_SLIDESHOW_CONTINUE_BTN_ON_TAP');
                          logFirebaseEvent('Button_haptic_feedback');
                          HapticFeedback.lightImpact();
                          if (_model.pageViewCurrentIndex == 2) {  
                            logFirebaseEvent('Button_navigate_to');
                            context.pushNamed('Onboarding_CreateAccount');
                          } else {
                            logFirebaseEvent('Button_page_view');
                            await _model.pageViewController?.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          }
                        },
                        text: 'Continua',
                        options: AFButtonOptions(
                          width: double.infinity,
                          height: 50,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                          color: CustomFlowTheme.of(context).primary,
                          textStyle: CustomFlowTheme.of(context).titleSmall.override(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0,
                                  ),
                          elevation: 0,
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                  ],
                ),
              ),
            ],*/
          ),
        ),
      ),
    );
  }
}
