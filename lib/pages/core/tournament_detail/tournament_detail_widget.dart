import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';

import '../../../app_flow/app_flow_theme.dart';
import '../../../app_flow/app_flow_util.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({
    super.key,
    this.tournamentsRef,
  });

  final TournamentsRecord? tournamentsRef;

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}


class _TournamentDetailWidgetState extends State<TournamentDetailWidget> with TickerProviderStateMixin {

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedValue = 'Option 1';


  @override
  void initState() {
    super.initState();

    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TournamentDetailModel(tournamentsRef: widget.tournamentsRef),
      builder: (context, child){
        return GestureDetector(
          onTap: () => context.read<TournamentDetailModel>().unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(context.read<TournamentDetailModel>().unfocusNode)
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
                  Container(
                    height: 35.h,
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/card_back/game_ygo_adv.jpg',
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
                                                context.watch<TournamentDetailModel>().getTournamentName(),
                                                style: CustomFlowTheme.of(context).titleLarge,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 20),
                                              child: InkWell(
                                                onTap: () {
                                                  // Add your image change logic here
                                                  print("ciao");
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
                                                  widget.tournamentsRef?.game?.name ?? "Unknown game",
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
                                        Text.rich(
                                          textAlign: TextAlign.right,
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: widget.tournamentsRef?.preRegisteredList.length.toString(),
                                                style: CustomFlowTheme.of(context).headlineSmall,
                                              ),
                                              TextSpan(
                                                text: ' Pre iscritti',
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
                                                text: widget.tournamentsRef?.waitingList.length.toString(),
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
                                                text: widget.tournamentsRef?.registeredList.length.toString(),
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
                        height: 32.sp,
                        decoration: BoxDecoration(
                          color: CustomFlowTheme.of(context).info, // Background color
                          border: Border.all(
                            color: CustomFlowTheme.of(context).alternate,
                            width: 1, // Border width
                          ),
                        ),
                        child: DropdownButton<String>(
                          alignment: Alignment.center,
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                          value: widget.tournamentsRef?.state?.name,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                          iconSize: 30,
                          onChanged: (String? newValue){
                            setState(() {
                              selectedValue = newValue!;
                            });
                          },
                          underline: const SizedBox(), // Remove the default underline
                          items: StateTournament.values.map((StateTournament state){
                            return DropdownMenuItem<String>(
                              value: state.name,
                              child: Text(
                                state.name,
                                style: TextStyle(
                                  color: CustomFlowTheme.of(context).info,
                                ),
                              ),
                            );
                          }).toList(),
                          selectedItemBuilder: (BuildContext context) {
                            return StateTournament.values.map<Widget>((StateTournament value) {
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
                                    value.name,
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
                          // Add your image change logic here
                          print("MAMMMMA");
                        },
                        child: Container(
                          width: 33.w,
                          height: 32.sp,
                          decoration: BoxDecoration(
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
                                      DateFormat('dd/MM/yy').format(widget.tournamentsRef!.date!),
                                      style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey),
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
                          // Add your image change logic here
                          print("MAMMMMATA");
                        },
                        child: Container(
                          width: 33.w,
                          height: 32.sp,
                          decoration: BoxDecoration(
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
                                      widget.tournamentsRef!.capacity.toString(),
                                      style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey),
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
                          // Add your image change logic here
                          print("ciaoUUUUU");
                        },
                        child: Container(
                          width: 50.w,
                          height: 32.sp,
                          decoration: BoxDecoration(
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
                                      widget.tournamentsRef!.preRegistrationEn.toString(),
                                      style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey),
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
                          // Add your image change logic here
                          print("ciaoUUUUUAAAA");
                        },
                        child: Container(
                          width: 50.w,
                          height: 32.sp,
                          decoration: BoxDecoration(
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
                                      widget.tournamentsRef!.waitingListEn.toString(),
                                      style: CustomFlowTheme.of(context).labelLarge.override(color: Colors.grey),
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
                  Container(
                    child: Padding(
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
    );
  }
}