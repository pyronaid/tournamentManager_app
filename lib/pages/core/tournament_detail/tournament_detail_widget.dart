import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';


class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({super.key});

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}


class _TournamentDetailWidgetState extends State<TournamentDetailWidget> {

  late TournamentDetailModel tournamentDetailModel;
  late TournamentModel tournamentModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentModel = context.read<TournamentModel>();
    tournamentDetailModel = context.read<TournamentDetailModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => tournamentDetailModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(tournamentDetailModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child:  SingleChildScrollView(
            child: Consumer<TournamentModel>(
              builder: (context, providerTournament, _){
                print("[BUILD IN CORSO] tournament_detail_widget.dart");
                if(tournamentModel.isLoading){
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
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
                                providerTournament.tournamentGame.resource,
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
                                            child: CircleAvatar(
                                              radius: 61,
                                              backgroundImage: tournamentModel.tournamentImageUrl == null ? const AssetImage('assets/images/icons/default_tournament.png') : NetworkImage(providerTournament.tournamentImageUrl!),
                                            ),
                                          ),
                                          if(tournamentModel.tournamentInteractPossible)
                                            Positioned(
                                              bottom: 5,
                                              right: 0,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Add your image change logic here
                                                  tournamentModel.setTournamentImage();
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
                                          child: SizedBox(
                                            width: 75.w,
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      providerTournament.tournamentName,
                                                      style: CustomFlowTheme.of(context).titleLarge,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  if(tournamentModel.tournamentInteractPossible)
                                                    Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 20),
                                                      child: InkWell(
                                                        onTap: () {
                                                          tournamentDetailModel.showChangeTournamentNameDialog(tournamentModel);
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
                                                      providerTournament.tournamentGame.desc,
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
                                      const Text("quattro"),
                                      ////////////////
                                      //COUNTERS AREA -- DX
                                      /////////////////
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            if(tournamentModel.tournamentPreRegistrationEn)
                                              Text.rich(
                                                textAlign: TextAlign.right,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: providerTournament.tournamentPreRegisteredSize.toString(),
                                                        style: CustomFlowTheme.of(context).headlineSmall,
                                                      ),
                                                      TextSpan(
                                                        text: ' Pre iscritti',
                                                        style: CustomFlowTheme.of(context).bodySmall,
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            if(tournamentModel.tournamentWaitingListEn)
                                              Text.rich(
                                                textAlign: TextAlign.right,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: providerTournament.tournamentWaitingListSize.toString(),
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
                                                      text: providerTournament.tournamentRegisteredSize.toString(),
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
                            value: providerTournament.tournamentState.name,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            iconSize: 30,
                            onChanged: (String? newValue){
                              if (newValue != null) {
                                tournamentDetailModel.showChangeTournamentStateDialog(newValue, tournamentModel);
                              }
                            },
                            underline: const SizedBox(), // Remove the default underline
                            items: StateTournament.values
                                .where((StateTournament state){
                              if(state.indexState == 0 || state.indexState > (providerTournament.tournamentState.indexState+1) || state.indexState < (providerTournament.tournamentState.indexState-1)){
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
                                    color: state.indexState == tournamentModel.tournamentState.indexState ? CustomFlowTheme.of(context).primary : CustomFlowTheme.of(context).info,
                                  ),
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return StateTournament.values
                                  .where((StateTournament state){
                                if(state.indexState == 0 || state.indexState > (providerTournament.tournamentState.indexState+1) || state.indexState < (providerTournament.tournamentState.indexState-1)){
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
                            if(tournamentModel.tournamentInteractPossible) {
                              _showChangeTournamentDatePicker(context, tournamentModel);
                            }
                          },
                          child: Container(
                            width: 33.w,
                            height: 30.sp,
                            decoration: BoxDecoration(
                              color: tournamentModel.tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
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
                                        DateFormat('dd/MM/yy').format(providerTournament.tournamentDate!),
                                        style: CustomFlowTheme.of(context).labelLarge.override(
                                          color: tournamentModel.tournamentInteractPossible ? Colors.grey : Colors.black,
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
                            if(tournamentModel.tournamentInteractPossible) {
                              tournamentDetailModel.showChangeTournamentCapacityDialog(tournamentModel);
                            }
                          },
                          child: Container(
                            width: 33.w,
                            height: 30.sp,
                            decoration: BoxDecoration(
                              color: tournamentModel.tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
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
                                        providerTournament.tournamentCapacity,
                                        style: CustomFlowTheme.of(context).labelLarge.override(
                                          color: tournamentModel.tournamentInteractPossible ? Colors.grey : Colors.black,
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
                            if(tournamentModel.tournamentInteractPossible) {
                              tournamentDetailModel.showSwitchPreIscrizioniDialog(tournamentModel);
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
                                  tournamentModel.tournamentInteractPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                                  tournamentModel.tournamentPreRegistrationEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
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
                                        providerTournament.tournamentPreRegistrationEn.toString(),
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
                            if(tournamentModel.tournamentWaitingListPossible) {
                              tournamentDetailModel.showSwitchWaitingListDialog(tournamentModel);
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
                                  tournamentModel.tournamentWaitingListPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                                  tournamentModel.tournamentWaitingListEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
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
                                        providerTournament.tournamentWaitingListEn.toString(),
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
                );
              },
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
Future<void> _showChangeTournamentDatePicker(BuildContext context, TournamentModel tournamentModel) async {
  // show the dialog
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: tournamentModel.tournamentDate ?? DateTime.now(),
    firstDate: tournamentModel.tournamentDate ?? DateTime.now(),
    lastDate: DateTime(2101),
  );

  if(pickedDate != null) {
    tournamentModel.setTournamentData(pickedDate);
  }
}
