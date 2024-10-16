import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../app_flow/app_flow_animations.dart';
import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/base_auth_user_provider.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/custom_appbar_widget.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';
import 'create_own_model.dart';

class CreateOwnWidget extends StatefulWidget {
  const CreateOwnWidget({super.key});

   @override
  State<CreateOwnWidget> createState() => _CreateOwnWidgetState();
}


class _CreateOwnWidgetState extends State<CreateOwnWidget> with TickerProviderStateMixin {

  late CreateOwnModel createOwnModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'Create_Own'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    createOwnModel = context.read<CreateOwnModel>();
    createOwnModel.initContextVars(context);
  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => createOwnModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(createOwnModel.unfocusNode)
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
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    wrapWithModel(
                      model: createOwnModel.customAppbarModel,
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
                    //CAROUSEL  TODO ADD SELECTOR ON pageViewController
                    /////////////////
                    Container(
                      width: double.infinity,
                      height: 22.h,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        child: PageView(
                          controller: createOwnModel.pageViewController,
                          scrollDirection: Axis.horizontal,
                          children: Game.values.where((game) => game.desc.isNotEmpty).map((game) {
                            //////////////////////////////////////////////////
                            //////////////////////////////////////////////////
                            //////////////////////////////////////////////////
                            // ELEMENT OF CAROUSEL
                            return Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                  child: Image.asset(
                                    game.resource,
                                    height: 20.h,
                                    fit: BoxFit.cover,
                                  ).animateOnPageLoad(createOwnModel.animationsMap[game.index]!),
                                ),
                              ],
                            );
                          }).toList(),
                          onPageChanged: (int value){
                            createOwnModel.jumpToPageAndNotify(value);
                          },
                        ),
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
                                Selector<CreateOwnModel, double?>(
                                  selector: (context, createOwnModel) => createOwnModel.pageViewController.page,
                                  builder: (context, controllerPage, child) {
                                    return DropdownButton<int>(
                                      itemHeight: null,
                                      menuMaxHeight: 50.h,
                                      value: controllerPage != null ? controllerPage.round() : 0,
                                      items: Game.values.where((game) => game.desc.isNotEmpty).map((game) {
                                        return DropdownMenuItem(
                                          value: game.index,
                                          child: Text(
                                            game.desc,
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }).toList(),
                                      style: CustomFlowTheme.of(context).bodyMedium.override(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                      ),
                                      onChanged: (int? value) {
                                        if (value != null) {
                                          createOwnModel.jumpToPageAndNotify(value);
                                        }
                                      },
                                    );
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
                                  controller: createOwnModel.tournamentNameTextController,
                                  focusNode: createOwnModel.tournamentNameFocusNode,
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
                                  validator: createOwnModel.tournamentNameTextControllerValidator.asValidator(context),
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
                                Selector<CreateOwnModel, String?>(
                                  selector: (context, createOwnModel) => createOwnModel.tournamentDateTextController.text,
                                  builder: (context, tournamentDate, child) {
                                    return TextFormField(
                                      controller: createOwnModel.tournamentDateTextController,
                                      focusNode: createOwnModel.tournamentDateFocusNode,
                                      autofocus: false,
                                      readOnly: true,
                                      obscureText: false,
                                      decoration: standardInputDecoration(
                                        context,
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.calendar_today),
                                          onPressed: () async {
                                            _showChangeTournamentDatePicker(context, createOwnModel);
                                          },
                                        ),
                                      ),
                                      style: CustomFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                      ),
                                      minLines: 1,
                                      cursorColor: CustomFlowTheme.of(context).primary,
                                      validator: createOwnModel.tournamentDateTextControllerValidator.asValidator(context),
                                    );
                                  }
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
                                Selector<CreateOwnModel, List<dynamic>>(
                                  selector: (context, createOwnModel) => createOwnModel.placeList,
                                  builder: (context, placeList, child) {
                                    return TypeAheadField<dynamic>(
                                      controller: createOwnModel.tournamentAddressTextController,
                                      focusNode: createOwnModel.tournamentAddressFocusNode,
                                      suggestionsCallback: (String search) {
                                         return createOwnModel.callAddressHint();
                                      },
                                      builder: (context, controller, focusNode) {
                                        return TextFormField(
                                          controller: controller,
                                          focusNode: focusNode,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          autofocus: false,
                                          decoration: standardInputDecoration(
                                            context,
                                            prefixIcon: Icon(
                                              Icons.place,
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
                                          validator: createOwnModel.tournamentAddressTextControllerValidator.asValidator(context),
                                        );
                                      },
                                      itemBuilder: (context, place) {
                                        return ListTile(
                                          title: Text(place["description"]),
                                          //subtitle: Text(city.country),
                                        );
                                      },
                                      onSelected: (place) {
                                        createOwnModel.setTournamentAddress(place);
                                      },
                                    );
                                  }
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
                                Selector<CreateOwnModel, String?>(
                                  selector: (context, createOwnModel) => createOwnModel.tournamentCapacityTextController.text,
                                  builder: (context, tournamentCapacity, child) {
                                    return TextFormField(
                                      controller: createOwnModel.tournamentCapacityTextController,
                                      focusNode: createOwnModel.tournamentCapacityFocusNode,
                                      autofocus: false,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
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
                                        if(value.isEmpty){
                                          createOwnModel.setTournamentCapacity();
                                        }
                                      },
                                      style: CustomFlowTheme.of(context).bodyLarge.override(
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 1,
                                      ),
                                      minLines: 1,
                                      cursorColor: CustomFlowTheme.of(context).primary,
                                      validator: createOwnModel.tournamentCapacityTextControllerValidator.asValidator(context),
                                    );
                                  }
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
                                Selector<CreateOwnModel, bool>(
                                  selector: (context, createOwnModel) => createOwnModel.preRegistrationEnabledVar,
                                  builder: (context, tournamentPreRegistrationEnabled, child) {
                                    return Switch(
                                        value: tournamentPreRegistrationEnabled,
                                        onChanged: (value) {
                                          createOwnModel.switchPreRegistrationEn();
                                        }
                                    );
                                  }
                                ),
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
                                Selector<CreateOwnModel, bool>(
                                  selector: (context, createOwnModel) => createOwnModel.waitingListEnabledVar,
                                  builder: (context, tournamentWaitingListEnabled, child) {
                                    return Switch(
                                      value: tournamentWaitingListEnabled,
                                      onChanged: (value) {
                                        createOwnModel.switchWaitingListEn();
                                      },
                                    );
                                  }
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
                          if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                            return;
                          }
                          logFirebaseEvent('Button_haptic_feedback');
                          HapticFeedback.lightImpact();
                          bool result = await createOwnModel.saveTournament();
                          if(result){ context.goNamedAuth('Dashboard', context.mounted); }
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


//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
//////////////////////////// FUNCTIONS
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
Future<void> _showChangeTournamentDatePicker(BuildContext context, CreateOwnModel createOwnModel) async {
  // show the dialog
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if(pickedDate != null) {
    createOwnModel.setTournamentDate(pickedDate);
  }
}