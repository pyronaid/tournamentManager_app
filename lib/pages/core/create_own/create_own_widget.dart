import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:petsy/app_flow/app_flow_util.dart';
import 'package:petsy/auth/base_auth_user_provider.dart';
import 'package:petsy/backend/schema/tournaments_record.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
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
      'imageOnPageLoadAnimation1': standardAnimationInfo(context),
      'imageOnPageLoadAnimation2': standardAnimationInfo(context),
      'imageOnPageLoadAnimation3': standardAnimationInfo(context),
      'imageOnPageLoadAnimation4': standardAnimationInfo(context),
      'imageOnPageLoadAnimation5': standardAnimationInfo(context),
      'imageOnPageLoadAnimation6': standardAnimationInfo(context),
    });

    _model.tournamentAddressTextController ??= TextEditingController();
    _model.tournamentAddressFocusNode ??= FocusNode();
    _model.tournamentNameTextController ??= TextEditingController();
    _model.tournamentNameFocusNode ??= FocusNode();
    _model.tournamentCapacityTextController ??= TextEditingController();
    _model.tournamentCapacityFocusNode ??= FocusNode();
    _model.tournamentDateTextController ??= TextEditingController();
    _model.tournamentDateFocusNode ??= FocusNode();


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
          child: Align(
            alignment: const AlignmentDirectional(0, 0),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    ////////////////
                    //PAGE TITLE
                    /////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 30),
                      child: Text(
                        'Crea un nuovo torneo',
                        style: CustomFlowTheme.of(context).displaySmall,
                      ),
                    ),
                    ////////////////
                    //CAROUSEL
                    /////////////////
                    Container(
                      width: double.infinity,
                      height: 22.h,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: PageView(
                          controller: _model.pageViewController ??= PageController(initialPage: 0),
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (value){
                            setState(() {});
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
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Image.asset(
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
                                    fit: BoxFit.cover,
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
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
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
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
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
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
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
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
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
                                    'assets/images/card_back/game_ygo_adv.jpg',
                                    height: 20.h,
                                    fit: BoxFit.fill,
                                  ).animateOnPageLoad(animationsMap['imageOnPageLoadAnimation6']!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    ////////////////
                    //FORM
                    /////////////////
                    Form(
                      key: _model.formKey,
                      autovalidateMode: AutovalidateMode.disabled,
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            //////////////////////////////////////////
                            // Game tournament
                            //////////////////////////////////////////
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButton<int>(
                                      itemHeight: null,
                                      menuMaxHeight: 50.h,
                                      value: _model.pageViewCurrentIndex,
                                      items: List.generate(
                                            _model.games.length,
                                            (index) => DropdownMenuItem(
                                                value: index,
                                                child: Text(
                                                    _model.games[index],
                                                    textAlign: TextAlign.center,
                                                ),
                                        ),
                                      ),
                                      style: CustomFlowTheme.of(context).bodyMedium.override(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                      ),
                                      onChanged: (int? value) {
                                        setState(() {
                                          _model.pageViewController?.animateToPage(value!, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                        });
                                      },
                                  ),
                                ],
                              ),
                            ),
                            //////////////////////////////////////////
                            // Name tournament
                            //////////////////////////////////////////
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 4),
                                    child: Text(
                                      'Nome torneo',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _model.tournamentNameTextController,
                                    focusNode: _model.tournamentNameFocusNode,
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
                                    validator: _model
                                        .tournamentNameTextControllerValidator
                                        .asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                            //////////////////////////////////////////
                            // DateTournament
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
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _model.tournamentDateTextController,
                                    focusNode: _model.tournamentDateFocusNode,
                                    autofocus: false,
                                    readOnly: true,
                                    //autofillHints: const [AutofillHints.name],
                                    //textCapitalization: TextCapitalization.words,
                                    //textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: standardInputDecoration(
                                      context,
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.calendar_today),
                                        onPressed: () async {
                                          final DateTime? datetime = await _model.selectDate(context);
                                          if (datetime != null){
                                            setState(() {
                                              _model.tournamentDateTextController?.text = DateFormat('dd/MM/yyyy').format(datetime);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
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
                                      style: CustomFlowTheme.of(context).bodyMedium,
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
                                    decoration: standardInputDecoration(context),
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
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
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: _model.tournamentCapacityTextController,
                                    focusNode: _model.tournamentCapacityFocusNode,
                                    autofocus: false,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    // autofillHints: const [AutofillHints.name],
                                    textCapitalization: TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: standardInputDecoration(
                                      context,
                                      prefixIcon: Icon(
                                        Icons.reduce_capacity,
                                        color: CustomFlowTheme.of(context).secondaryText,
                                        size: 18,
                                      ),
                                    ),
                                    onChanged: (value){
                                      setState(() {
                                        if (value == "" || value == "0") {
                                          _model.tournamentCapacityTextController.text = 'Nessun limite';
                                          _model.waitingListEnabled = false;
                                        }
                                      });
                                    },
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
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
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                    child: Text(
                                      'Pre-registrazione abilitata',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  Switch(
                                    value: _model.preRegistrationEnabled,
                                    onChanged: (value){
                                      setState(() {
                                        _model.preRegistrationEnabled = value;
                                      });
                                    }
                                  )
                                ],
                              ),
                            ),
                            //////////////////////////////////////////
                            // WAITINIG-LIST switch
                            //////////////////////////////////////////
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 18, 0, 0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                    child: Text(
                                      'Lista d\'attesa abilitata',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  Switch(
                                    value: _model.waitingListEnabled,
                                    onChanged: int.tryParse(_model.tournamentCapacityTextController.text) != null ? (value){
                                      setState(() {
                                        _model.waitingListEnabled = value;
                                      });
                                    } : null,
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
                          logFirebaseEvent('ONBOARDING_CREATE_OWN_CREATE_OWN');
                          logFirebaseEvent('Button_validate_form');
                          if (_model.formKey.currentState == null ||
                              !_model.formKey.currentState!.validate()) {
                            return;
                          }
                          logFirebaseEvent('Button_haptic_feedback');
                          HapticFeedback.lightImpact();

                          //SAVING TOURNAMENT HER
                          Game game;
                          switch(_model.pageViewController?.page){
                            case 0:
                              game = Game.ygoAdv;
                              break;
                            case 1:
                              game = Game.ygoRetro;
                              break;
                            case 2:
                              game = Game.onepiece;
                              break;
                            case 3:
                              game = Game.magic;
                              break;
                            case 4:
                              game = Game.altered;
                              break;
                            case 5:
                              game = Game.lorcana;
                              break;
                            default:
                              game = Game.none;
                          }
                          int convertedCapacity = 0;
                          if(int.tryParse(_model.tournamentCapacityTextController.text) != null){
                            convertedCapacity = int.parse(_model.tournamentCapacityTextController.text);
                          }

                          Map<String, dynamic> ownTournament = createTournamentsRecordData(
                            game: game,
                            name: _model.tournamentNameTextController.text,
                            address: _model.tournamentAddressTextController.text,
                            pre_registration_en: _model.preRegistrationEnabled,
                            waiting_list_en : _model.waitingListEnabled,
                            date: DateFormat('dd/MM/yyyy').parse(_model.tournamentDateTextController.text),
                            capacity: convertedCapacity,
                            creator_uid: currentUser!.uid,
                          );
                          await TournamentsRecord.collection.add(ownTournament)
                            .then(
                              (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Torneo creato con successo',
                                      style: CustomFlowTheme.of(context).displaySmall.override( color: CustomFlowTheme.of(context).primary ),
                                    ),
                                  ),
                                );
                                logFirebaseEvent('Button_navigate_to');
                                context.goNamedAuth('Dashboard', context.mounted);
                              }
                            ).catchError((onError){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Errore nella creazione del Torneo. Riprova più tardi',
                                    style: CustomFlowTheme.of(context).displaySmall.override( color: CustomFlowTheme.of(context).error ),
                                  ),
                                )
                              );
                            });
                        },
                        text: 'Crea Torneo',
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
          )
        ),
      ),
    );
  }
}
