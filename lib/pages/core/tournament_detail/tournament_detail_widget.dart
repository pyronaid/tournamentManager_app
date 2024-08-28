import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../backend/schema/tournaments_record.dart';
import '../../../components/standard_graphics/standard_graphics_widgets.dart';

class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({super.key});

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}


class _TournamentDetailWidgetState extends State<TournamentDetailWidget> with TickerProviderStateMixin {

  late TournamentDetailModel tournamentDetailModel;
  final scaffoldKey = GlobalKey<ScaffoldState>();


  String? selectedValue = 'Option 1';


  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentDetailModel = context.read<TournamentDetailModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final Game tournamentGame = context.select((TournamentDetailModel i) => i.tournamentGame);
    final String tournamentName = context.select((TournamentDetailModel i) => i.tournamentName);
    final bool tournamentPreRegistrationEn = context.select((TournamentDetailModel i) => i.tournamentPreRegistrationEn);
    final bool tournamentWaitingListEn = context.select((TournamentDetailModel i) => i.tournamentWaitingListEn);
    final bool tournamentWaitingListPossible = context.select((TournamentDetailModel i) => i.tournamentWaitingListPossible);
    final bool tournamentInteractPossible = context.select((TournamentDetailModel i) => i.tournamentInteractPossible);
    final int tournamentPreRegisteredSize = context.select((TournamentDetailModel i) => i.tournamentPreRegisteredSize);
    final int tournamentWaitingListSize = context.select((TournamentDetailModel i) => i.tournamentWaitingListSize);
    final int tournamentRegisteredSize = context.select((TournamentDetailModel i) => i.tournamentRegisteredSize);
    final StateTournament tournamentState = context.select((TournamentDetailModel i) => i.tournamentState);
    final String tournamentCapacity = context.select((TournamentDetailModel i) => i.tournamentCapacity);
    final DateTime? tournamentDate = context.select((TournamentDetailModel i) => i.tournamentDate);


    return GestureDetector(
      onTap: () => tournamentDetailModel.unfocusNode.canRequestFocus
      ? FocusScope.of(context).requestFocus(tournamentDetailModel.unfocusNode)
      : FocusScope.of(context).unfocus(),
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: CustomFlowTheme.of(context).primaryBackground,
          body: SafeArea(
          top: true,
          child:  SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ////////////////
                //TITLE AREA
                /////////////////
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 35.h
                    ),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: Image.asset(
                            tournamentGame.resource,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Blurred Effect
                        Positioned.fill(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                            child: Container(color: Colors.black.withOpacity(0.1)), // Optional: Adds a color overlay
                          ),
                        ),
                        // Content
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  ////////////////
                                  //TITLE AREA -- LOGO CIRCLE EDITABLE
                                  /////////////////
                                  Stack(
                                    children: [
                                      Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: CustomFlowTheme.of(context).primary, // Border color
                                            width: 4.0, // Border width
                                          ),
                                        ),
                                        child: const CircleAvatar(
                                          radius: 61,
                                          backgroundImage: AssetImage('assets/images/icons/default_tournament.png'),
                                        ),
                                      ),
                                      if(tournamentDetailModel.tournamentInteractPossible)
                                        Positioned(
                                          bottom: 5,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () {
                                              // Add your image change logic here
                                              print("ciao");
                                            },
                                            borderRadius: BorderRadius.circular(61), // Optional: To match the CircleAvatar shape
                                            child: CircleAvatar(
                                              radius: 15,
                                              backgroundColor: CustomFlowTheme.of(context).primary,
                                              child: Icon(
                                                Icons.edit,
                                                size: 18,
                                                color: CustomFlowTheme.of(context).info,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  ////////////////
                                  //TITLE AREA -- NAME TOURNAMENT
                                  /////////////////
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 5),
                                    child: Container(
                                      width: 75.w,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                tournamentName,
                                                style: CustomFlowTheme.of(context).titleLarge,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            if(tournamentDetailModel.tournamentInteractPossible)
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 20),
                                                child: InkWell(
                                                  onTap: () {
                                                    _showChangeTournamentNameDialog(context, tournamentDetailModel);
                                                  },
                                                  borderRadius: BorderRadius.circular(61), // Optional: To match the CircleAvatar shape
                                                  child: CircleAvatar(
                                                    radius: 10,
                                                    backgroundColor: CustomFlowTheme.of(context).primary,
                                                    child: Icon(
                                                      Icons.edit,
                                                      size: 10,
                                                      color: CustomFlowTheme.of(context).info,
                                                    ),
                                                  ),
                                                ),
                                              )
                                          ],
                                        ),
                                      ),
                                    )
                                  ),
                                  ////////////////
                                  //TITLE AREA -- GAME
                                  /////////////////
                                  Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 5),
                                      child: SizedBox(
                                        width: 75.w,
                                        child: Center(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  tournamentGame.desc,
                                                  style: CustomFlowTheme.of(context).titleSmall,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                  ),
                                ],
                              ),
                              ////////////////
                              //COUNTERS AREA
                              /////////////////
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ////////////////
                                  //COUNTERS AREA -- SX
                                  /////////////////
                                  Text("quattro"),
                                  ////////////////
                                  //COUNTERS AREA -- DX
                                  /////////////////
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        if(tournamentDetailModel.tournamentPreRegistrationEn)
                                          Text.rich(
                                            textAlign: TextAlign.right,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: tournamentPreRegisteredSize.toString(),
                                                  style: CustomFlowTheme.of(context).headlineSmall,
                                                ),
                                                TextSpan(
                                                  text: ' Pre iscritti',
                                                  style: CustomFlowTheme.of(context).bodySmall,
                                                ),
                                              ]
                                            ),
                                          ),
                                        if(tournamentDetailModel.tournamentWaitingListEn)
                                          Text.rich(
                                            textAlign: TextAlign.right,
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: tournamentWaitingListSize.toString(),
                                                  style: CustomFlowTheme.of(context).headlineSmall,
                                                ),
                                                TextSpan(
                                                  text: ' Waiting list',
                                                  style: CustomFlowTheme.of(context).bodySmall,
                                                ),
                                              ]
                                            ),
                                          ),
                                        Text.rich(
                                          textAlign: TextAlign.right,
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: tournamentRegisteredSize.toString(),
                                                style: CustomFlowTheme.of(context).headlineSmall,
                                              ),
                                              TextSpan(
                                                text: ' Iscritti',
                                                style: CustomFlowTheme.of(context).bodySmall,
                                              ),
                                            ]
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ////////////////
                //SETTINGS AREA row 1
                /////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ////////////////
                    //SETTINGS AREA -- State dropdown
                    /////////////////
                    Container(
                      width: 33.w,
                      height: 30.sp,
                      decoration: BoxDecoration(
                        color: CustomFlowTheme.of(context).info, // Background color
                        border: Border.all(
                          color: CustomFlowTheme.of(context).alternate,
                          width: 1, // Border width
                        ),
                      ),
                      child: DropdownButton<String>(
                        alignment: Alignment.center,
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                        value: tournamentState.name,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                        iconSize: 30,
                        onChanged: (String? newValue){
                          if (newValue != null) {
                            _showChangeTournamentStateDialog(context, tournamentDetailModel, newValue);
                          }
                        },
                        underline: const SizedBox(), // Remove the default underline
                        items: StateTournament.values
                          .where((StateTournament state){
                            if(state.indexState == 0 || state.indexState > (tournamentState.indexState+1) || state.indexState < (tournamentState.indexState-1)){
                              return false;
                            }
                            return true;
                          })
                          .map((StateTournament state){
                            return DropdownMenuItem<String>(
                              value: state.name,
                              child: Text(
                                state.desc,
                                style: TextStyle(
                                  color: state.indexState == tournamentState.indexState ? CustomFlowTheme.of(context).primary : CustomFlowTheme.of(context).info,
                                ),
                              ),
                            );
                          }).toList(),
                        selectedItemBuilder: (BuildContext context) {
                          return StateTournament.values
                            .where((StateTournament state){
                              if(state.indexState == 0 || state.indexState > (tournamentState.indexState+1) || state.indexState < (tournamentState.indexState-1)){
                                return false;
                              }
                              return true;
                            })
                            .map<Widget>((StateTournament value) {
                              return Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'STATO',
                                    style: CustomFlowTheme.of(context).titleMedium.override(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    value.desc,
                                    style: CustomFlowTheme.of(context).titleSmall.override(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              );
                            }).toList();
                        },
                      ),
                    ),
                    ////////////////
                    //SETTINGS AREA -- Date dropdown like
                    /////////////////
                    InkWell(
                      onTap: () {
                        if(tournamentDetailModel.tournamentInteractPossible) {
                          _showChangeTournamentDatePicker(context, tournamentDetailModel);
                        }
                      },
                      child: Container(
                        width: 33.w,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                          border: Border.all(
                            color: CustomFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'DATA',
                                    style: CustomFlowTheme.of(context).titleMedium.override(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    DateFormat('dd/MM/yy').format(tournamentDate!),
                                    style: CustomFlowTheme.of(context).labelLarge.override(
                                      color: tournamentInteractPossible ? Colors.grey : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ////////////////
                    //SETTINGS AREA -- Capacity dropdown like
                    /////////////////
                    InkWell(
                      onTap: () {
                        if(tournamentDetailModel.tournamentInteractPossible) {
                          _showChangeTournamentCapacityDialog(context, tournamentDetailModel);
                        }
                      },
                      child: Container(
                        width: 33.w,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          color: tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                          border: Border.all(
                            color: CustomFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'CAPIENZA',
                                    style: CustomFlowTheme.of(context).titleMedium.override(color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    tournamentCapacity,
                                    style: CustomFlowTheme.of(context).labelLarge.override(
                                      color: tournamentInteractPossible ? Colors.grey : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black,
                              size: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ////////////////
                //SETTINGS AREA row 2
                /////////////////
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ////////////////
                    //SETTINGS AREA -- Enable pre iscrizioni
                    /////////////////
                    InkWell(
                      onTap: () {
                        if(tournamentDetailModel.tournamentInteractPossible) {
                          _showSwitchPreIscrizioniDialog(context, tournamentDetailModel);
                        }
                      },
                      child: Container(
                        width: 50.w,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                              tournamentPreRegistrationEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
                            ],
                          ),
                          color: CustomFlowTheme.of(context).info,
                          border: Border.all(
                            color: CustomFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'PRE ISCRIZIONI',
                                      style: CustomFlowTheme.of(context).titleSmall.override(color: Colors.black),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    tournamentPreRegistrationEn.toString(),
                                    style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey.shade900),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ////////////////
                    //SETTINGS AREA -- Enable waiting list
                    /////////////////
                    InkWell(
                      onTap: () {
                        if(tournamentDetailModel.tournamentWaitingListPossible) {
                          _showSwitchWaitingListDialog(context, tournamentDetailModel);
                        }
                      },
                      child: Container(
                        width: 50.w,
                        height: 30.sp,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              tournamentWaitingListPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                              tournamentWaitingListEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
                            ],
                          ),
                          color: CustomFlowTheme.of(context).info,
                          border: Border.all(
                            color: CustomFlowTheme.of(context).alternate,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'WAITING LIST',
                                      style: CustomFlowTheme.of(context).titleSmall.override(color: Colors.black),
                                      textAlign: TextAlign.center,
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    tournamentWaitingListEn.toString(),
                                    style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey.shade900),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                ////////////////
                //TOOLTIP AREA
                /////////////////
                Padding(
                  padding: const EdgeInsetsDirectional.all(20),
                  child: SimpleAccordion(
                    children: [
                      AccordionHeaderItem(
                        title: "Legenda degli stati",
                        children: [
                          AccordionItem(
                            title: "open: In questo stato il torneo non è visibile e non può essere trovato dagli altri utenti. In questa fase potrai finalizzare le configurazioni prima di farlo passare allo stato successivo.",
                          ),
                          AccordionItem(
                            title: "ready: In questo stato il torneo è visibile a tutti gli utenti che possono preiscriversi o se possibile o aggiungerlo ai tornei interessati.",
                          ),
                          AccordionItem(
                            title: "ongoing: In questo stato il torneo è in corso. Non sono possibili altre iscrizioni ma in questa fase si possono generare i vari turni e anche la top.",
                          ),
                          AccordionItem(
                            title: "close: In questo stato il torneo è chiuso. Non possono essere modificati parametri o generati nuovi round. La classifica finale decreta il vincitore.",
                          ),
                        ],
                      ),
                      AccordionHeaderItem(
                        title: "Pre-registrazione",
                        children: [
                          AccordionItem(
                            title: "Questa configurazione permette agli utenti di pre-registrarsi. Se tale configurazione è abilitata, nel momento in cui ci sarà l'iscrizione ufficiale l'app segnalerà ogni qual volta si sta registrando un giocatore al di fuori di questa lista e chiederà conferma per procedere.",
                          ),
                        ],
                      ),
                      AccordionHeaderItem(
                        title: "Waiting list",
                        children: [
                          AccordionItem(
                            title: "Questa configurazione può essere abilitata solo se è stata definita una capienza massima del torneo e se le preiscrizioni sono state abilitate. Nel momento in cui i preiscritti avranno raggiunto la capienza del torneo, gli altri saranno posizionati in coda in questa nuova lista. L'app segnalerà ogni volta si sta iscrivendo un giocatore all'interno di questa lista.",
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                ////////////////
                //other
                /////////////////
              ],
            ),
          ),
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
Future<void> _showChangeTournamentNameDialog(BuildContext context, TournamentDetailModel tournamentDetailModel) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (dialogContext) => ChangeNotifierProvider.value(
      value: Provider.of<TournamentDetailModel>(context, listen: false),
      child: AlertDialog(
        title: const Text('Modifica Nome Torneo'),
        content: Form(
          key: tournamentDetailModel.formKeyName,
          autovalidateMode: AutovalidateMode.disabled,
          child: TextFormField(
            controller: tournamentDetailModel.fieldControllerName,
            focusNode: tournamentDetailModel.tournamentNameFocusNode,
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
            validator: tournamentDetailModel.tournamentNameTextControllerValidator.asValidator(dialogContext),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle saving the new value
              String newTournamentName = tournamentDetailModel.fieldControllerName.text;
              logFirebaseEvent('Button_validate_form');
              if (tournamentDetailModel.formKeyName.currentState == null ||
                  !tournamentDetailModel.formKeyName.currentState!.validate()) {
                return;
              }
              tournamentDetailModel.setTournamentName(newTournamentName);
              Navigator.of(dialogContext).pop(); // Dismiss the dialog
            },
            child: const Text('Salva'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showChangeTournamentCapacityDialog(BuildContext context, TournamentDetailModel tournamentDetailModel) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Modifica Capienza Torneo'),
      content: Form(
        key: tournamentDetailModel.formKeyCapacity,
        autovalidateMode: AutovalidateMode.disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: tournamentDetailModel.fieldControllerCapacity,
              focusNode: tournamentDetailModel.tournamentCapacityFocusNode,
              autofocus: false,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
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
              style: CustomFlowTheme.of(context).bodyLarge.override(
                fontWeight: FontWeight.w500,
                lineHeight: 1,
              ),
              minLines: 1,
              cursorColor: CustomFlowTheme.of(context).primary,
              validator: tournamentDetailModel.tournamentCapacityTextControllerValidator.asValidator(dialogContext),
            ),
            const SizedBox(height: 20),
            Text(
              "Utilizza lo 0 se non vuoi impostare un limite alla capacità del torneo",
              style: CustomFlowTheme.of(context).labelMedium,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop(); // Dismiss the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle saving the new value
            String newTournamentCapacity = tournamentDetailModel.fieldControllerCapacity.text;
            logFirebaseEvent('Button_validate_form');
            if (tournamentDetailModel.formKeyCapacity.currentState == null ||
                !tournamentDetailModel.formKeyCapacity.currentState!.validate()) {
              return;
            }
            tournamentDetailModel.setTournamentCapacity(newTournamentCapacity);
            Navigator.of(dialogContext).pop(); // Dismiss the dialog
          },
          child: const Text('Salva'),
        ),
      ],
    ),
  );
}

Future<void> _showChangeTournamentDatePicker(BuildContext context, TournamentDetailModel tournamentDetailModel) async {
  // show the dialog
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: tournamentDetailModel.tournamentDate ?? DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if(pickedDate != null) {
    tournamentDetailModel.setTournamentData(pickedDate);
  }
}

Future<void> _showSwitchPreIscrizioniDialog(BuildContext context, TournamentDetailModel tournamentDetailModel) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<TournamentDetailModel>(context),
      child: AlertDialog(
        title: const Text('Switch Pre-Iscrizioni'),
        content: Text(
          "Confermando ${tournamentDetailModel.tournamentPreRegistrationEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di pre-iscriversi. ${tournamentDetailModel.tournamentPreRegistrationEn ? "Qualora ci fossero già giocatori pre-iscritti questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
          style: CustomFlowTheme.of(context).labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle saving the new value
              tournamentDetailModel.switchTournamentPreIscrizioniEn();
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Continua'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showSwitchWaitingListDialog(BuildContext context, TournamentDetailModel tournamentDetailModel) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<TournamentDetailModel>(context),
      child: AlertDialog(
        title: const Text('Switch Pre-Iscrizioni'),
        content: Text(
          "Confermando ${tournamentDetailModel.tournamentWaitingListEn ? "disabiliterai" : "abiliterai"} la possibilità ai giocatori di aggiungersi in waiting list una volta che la capacità del torneo è stata raggiunta. ${tournamentDetailModel.tournamentWaitingListEn ? "Qualora ci fossero già giocatori in waiting-list questi verranno eliminati e se in futuro deciderai di riabilitarla dovranno rieffettuare l'azione" : ""}",
          style: CustomFlowTheme.of(context).labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle saving the new value
              tournamentDetailModel.switchTournamentWaitingListEn();
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Continua'),
          ),
        ],
      ),
    ),
  );
}

Future<void> _showChangeTournamentStateDialog(BuildContext context, TournamentDetailModel tournamentDetailModel, String newState) async {
  // show the dialog
  await showDialog(
    context: context,
    builder: (_) => ChangeNotifierProvider.value(
      value: Provider.of<TournamentDetailModel>(context),
      child: AlertDialog(
        title: const Text('Cambia Stato del torneo'),
        content: Text(
          "Confermando cambierai lo stato del torneo. Alcune attività possono essere fatte solo in uno specifico stato per cui se hai dei dubbi leggi la legenda degli stati che è riportata di seguito.",
          style: CustomFlowTheme.of(context).labelMedium,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle saving the new value
              tournamentDetailModel.setTournamentState(newState);
              Navigator.of(context).pop(); // Dismiss the dialog
            },
            child: const Text('Continua'),
          ),
        ],
      ),
    ),
  );
}