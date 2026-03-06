import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_accordion/simple_accordion.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_winner_card/tournament_winner_card_widget.dart';
import 'package:tournamentmanager/pages/core/tournament_detail/tournament_detail_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';
import 'package:tuple/tuple.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/pocketbase_auth/pocketbase_users_record.dart';
import '../../../backend/schema/enrollments_record.dart';


class TournamentDetailWidget extends StatefulWidget {
  const TournamentDetailWidget({super.key});

  @override
  State<TournamentDetailWidget> createState() => _TournamentDetailWidgetState();
}


class _TournamentDetailWidgetState extends State<TournamentDetailWidget> {

  late TournamentDetailModel tournamentDetailModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentDetailModel = context.read<TournamentDetailModel>();
  }

  @override
  void dispose() {
    _unfocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: CustomFlowTheme.of(context).primaryBackground,
        body: SafeArea(
          top: true,
          child:  SingleChildScrollView(
            child: Consumer<TournamentDetailModel>(
              builder: (context, providerTournamentDetail, _){
                debugPrint("[BUILD IN CORSO] tournament_detail_widget.dart");
                if(providerTournamentDetail.isLoading){
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
                                providerTournamentDetail.tournamentModel.tournamentGame.resource,
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Blurred Effect
                            Positioned.fill(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                child: Container(color: Colors.black.withValues(alpha: 0.1)), // Optional: Adds a color overlay
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
                                              backgroundImage: providerTournamentDetail.tournamentModel.tournamentImageUrl == null ? const AssetImage('assets/images/icons/default_tournament.png') : NetworkImage(providerTournamentDetail.tournamentModel.tournamentImageUrl!),
                                            ),
                                          ),
                                          if(providerTournamentDetail.isTournamentEditable)
                                            Positioned(
                                              bottom: 5,
                                              right: 0,
                                              child: InkWell(
                                                onTap: () async {
                                                  // Add your image change logic here
                                                  providerTournamentDetail.tournamentModel.setTournamentImage();
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
                                                      providerTournamentDetail.tournamentModel.tournamentName,
                                                      style: CustomFlowTheme.of(context).titleLarge,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  if(providerTournamentDetail.isTournamentEditable)
                                                    Padding(
                                                      padding: const EdgeInsetsDirectional.fromSTEB(5, 0, 0, 20),
                                                      child: InkWell(
                                                        onTap: () {
                                                          context.goNamed(
                                                            'DialogChangeTournamentName',
                                                            pathParameters: {
                                                              'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                                            }.withoutNulls,
                                                            extra: {
                                                              'req' : tournamentDetailModel.showChangeTournamentNameFormRequest(),
                                                            }
                                                          );
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
                                                      providerTournamentDetail.tournamentModel.tournamentGame.desc,
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
                                            if(providerTournamentDetail.tournamentModel.tournamentPreRegistrationEn)
                                              Text.rich(
                                                textAlign: TextAlign.right,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: providerTournamentDetail.tournamentModel.tournamentPreRegisteredSize.toString(),
                                                        style: CustomFlowTheme.of(context).headlineSmall,
                                                      ),
                                                      TextSpan(
                                                        text: ' Pre iscritti',
                                                        style: CustomFlowTheme.of(context).bodySmall,
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            if(providerTournamentDetail.tournamentModel.tournamentWaitingListEn)
                                              Text.rich(
                                                textAlign: TextAlign.right,
                                                TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: providerTournamentDetail.tournamentModel.tournamentWaitingSize.toString(),
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
                                                      text: providerTournamentDetail.tournamentModel.tournamentRegisteredSize.toString(),
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
                            value: providerTournamentDetail.tournamentModel.tournamentState.name,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                            iconSize: 30,
                            onChanged: providerTournamentDetail.canInteractOn ? (String? newValue){
                              if (newValue != null) {
                                context.goNamed(
                                  'DialogState',
                                  pathParameters: {
                                    'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                  }.withoutNulls,
                                  extra: {
                                    'req' : tournamentDetailModel.showChangeTournamentStateAlertRequest(newValue),
                                  }
                                );
                              }
                            } : null,
                            underline: const SizedBox(), // Remove the default underline
                            items: StateTournament.values
                                .where((StateTournament state){
                              if(state.indexState == 0 || state.indexState > (providerTournamentDetail.tournamentModel.tournamentState.indexState+1) || state.indexState < (providerTournamentDetail.tournamentModel.tournamentState.indexState-1)){
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
                                    color: state.indexState == providerTournamentDetail.tournamentModel.tournamentState.indexState ? CustomFlowTheme.of(context).primary : CustomFlowTheme.of(context).info,
                                  ),
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (BuildContext context) {
                              return StateTournament.values
                                  .where((StateTournament state){
                                if(state.indexState == 0 || state.indexState > (providerTournamentDetail.tournamentModel.tournamentState.indexState+1) || state.indexState < (providerTournamentDetail.tournamentModel.tournamentState.indexState-1)){
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
                            if(providerTournamentDetail.isTournamentEditable) {
                              _showChangeTournamentDatePicker(context, providerTournamentDetail.tournamentModel);
                            }
                          },
                          child: Container(
                            width: 33.w,
                            height: 30.sp,
                            decoration: BoxDecoration(
                              color: providerTournamentDetail.isTournamentEditable ? CustomFlowTheme.of(context).info : Colors.grey,
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
                                        DateFormat('dd/MM/yy').format(providerTournamentDetail.tournamentModel.tournamentDate!),
                                        style: CustomFlowTheme.of(context).labelLarge.override(
                                          color: providerTournamentDetail.isTournamentEditable ? Colors.grey : Colors.black,
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
                            if(providerTournamentDetail.isTournamentEditable) {
                              context.goNamed(
                                'DialogChangeCapacity',
                                pathParameters: {
                                  'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                }.withoutNulls,
                                extra: {
                                  'req' : tournamentDetailModel.showChangeTournamentCapacityAlertFormRequest(),
                                }
                              );
                            }
                          },
                          child: Container(
                            width: 33.w,
                            height: 30.sp,
                            decoration: BoxDecoration(
                              color: providerTournamentDetail.isTournamentEditable ? CustomFlowTheme.of(context).info : Colors.grey,
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
                                        providerTournamentDetail.tournamentModel.tournamentCapacity,
                                        style: CustomFlowTheme.of(context).labelLarge.override(
                                          color: providerTournamentDetail.isTournamentEditable ? Colors.grey : Colors.black,
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
                            if(providerTournamentDetail.isTournamentEditable) {
                              context.goNamed(
                                'DialogPreIscrizioni',
                                pathParameters: {
                                  'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                }.withoutNulls,
                                extra: {
                                  'req' : tournamentDetailModel.showSwitchPreIscrizioniAlertRequest(),
                                }
                              );
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
                                  providerTournamentDetail.isTournamentEditable ? CustomFlowTheme.of(context).info : Colors.grey,
                                  providerTournamentDetail.tournamentModel.tournamentPreRegistrationEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
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
                                        providerTournamentDetail.tournamentModel.tournamentPreRegistrationEn.toString(),
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
                            if(providerTournamentDetail.isTournamentEditable) {
                              context.goNamed(
                                  'DialogWaitingList',
                                  pathParameters: {
                                    'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                  }.withoutNulls,
                                  extra: {
                                    'req' : tournamentDetailModel.showSwitchWaitingListAlertRequest(),
                                  }
                              );
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
                                  providerTournamentDetail.tournamentModel.tournamentWaitingListPossible ? CustomFlowTheme.of(context).info : Colors.grey,
                                  providerTournamentDetail.tournamentModel.tournamentWaitingListEn ? CustomFlowTheme.of(context).success : CustomFlowTheme.of(context).warning,
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
                                        providerTournamentDetail.tournamentModel.tournamentWaitingListEn.toString(),
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
                    //WINNER AREA
                    /////////////////
                    if(providerTournamentDetail.tournamentModel.tournamentState == StateTournament.close && providerTournamentDetail.tournamentModel.hasWinner)...[
                      Padding(
                        padding: const EdgeInsetsDirectional.all(20),
                        child: Column(
                          children: List.generate(
                            providerTournamentDetail.tournamentModel.winner?.length ?? 0,
                            (index) {
                              final item = providerTournamentDetail.tournamentModel.winner?[index];
                              if(item[PocketbaseUser.idFieldName] != null) {
                                return TournamentWinnerCardWidget(
                                  name: item[PocketbaseUser.nameFieldName],
                                  surname: item[PocketbaseUser.surnameFieldName],
                                  username: item[PocketbaseUser.usernameFieldName],
                                  userId: item[PocketbaseUser.idFieldName],
                                );
                              } else {
                                return const SizedBox();
                              }
                            },
                          ),
                        )
                      )
                    ],
                    //REGISTER BUTTON AREA
                    ////////////////
                    /////////////////
                    if(providerTournamentDetail.tournamentModel.tournamentState == StateTournament.ready && !providerTournamentDetail.tournamentModel.hasWinner)...[
                      Padding(
                        padding: const EdgeInsetsDirectional.all(20),
                        child: FutureBuilder<Tuple2<int, List<EnrollmentsRecord>>>(
                          future: providerTournamentDetail.currentUserEnrolledCheck,
                          builder: (context, snapshot){
                            if (!snapshot.hasData) {
                              //loading
                            }
                            if (snapshot.data == null || snapshot.data?.item1 == 0) {
                              //bottone
                              //se preregistrazioni abilitate e < capacity allora mostra bottone
                              //se preregistrazioni abilitate e = capacity e waiting list abilitata allora mostra bottone 2
                              //se preregistrazioni abilitate e = capacity e waiting list non abilitata allora mostra messaggio custom
                              //se preregistrazioni non abilitate indicare messaggio custom
                              if (providerTournamentDetail.tournamentModel.tournamentPreRegistrationEn) {
                                if (providerTournamentDetail.tournamentModel.tournamentCapacityInt == 0 || providerTournamentDetail.tournamentModel.tournamentCurrentSize < providerTournamentDetail.tournamentModel.tournamentCapacityInt) {
                                  return AFButtonWidget(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      context.goNamed(
                                          'DialogPreRegisterPlayer',
                                          pathParameters: {
                                            'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                          }.withoutNulls,
                                          extra: {
                                            'req': tournamentDetailModel.showAddToPreRegisterListAlertRequest(),
                                          }
                                      );
                                    },
                                    text: 'Pre registrati!',
                                    options: AFButtonOptions(
                                      width: double.infinity,
                                      height: 50,
                                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                      color: CustomFlowTheme.of(context).secondary,
                                      textStyle: CustomFlowTheme.of(context).bodyMedium,
                                      elevation: 0,
                                      borderSide: BorderSide(
                                        color: CustomFlowTheme.of(context).primary,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                  );
                                } else {
                                  if (providerTournamentDetail.tournamentModel
                                      .tournamentWaitingListEn) {
                                    return AFButtonWidget(
                                      onPressed: () async {
                                        FocusScope.of(context).unfocus();
                                        context.goNamed(
                                            'DialogWaitingListPlayer',
                                            pathParameters: {
                                              'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                            }.withoutNulls,
                                            extra: {
                                              'req': tournamentDetailModel.showAddToWaitingListAlertRequest(),
                                            }
                                        );
                                      },
                                      text: 'Aggiungiti alla waiting list!',
                                      options: AFButtonOptions(
                                        width: double.infinity,
                                        height: 50,
                                        padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                        color: CustomFlowTheme.of(context).secondary,
                                        textStyle: CustomFlowTheme.of(context).bodyMedium,
                                        elevation: 0,
                                        borderSide: BorderSide(
                                          color: CustomFlowTheme.of(context).primary,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    );
                                  } else {
                                    return Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: CustomFlowTheme.of(context).secondaryBackground,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: CustomFlowTheme.of(context).alternate,
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
                                          child: Text(
                                            "Il torneo ha raggiunto il limite e non è stata abilitata una waiting list. Monitoralo per vedere se vengono aggiunti nuovi posti o se ne liberano alcuni.",
                                            style: CustomFlowTheme.of(context).labelLarge,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              } else {
                                return Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: CustomFlowTheme.of(context).secondaryBackground,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: CustomFlowTheme.of(context).alternate,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
                                      child: Text(
                                        "Non è possibile preregistrarsi. Recati il giorno stabilito presso la sede dell'evento o contatta l'organizzatore per avere le modalità di regìstrazione",
                                        style: CustomFlowTheme.of(context).labelLarge,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            } else {
                              return Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: CustomFlowTheme.of(context).secondaryBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: CustomFlowTheme.of(context).alternate,
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 12),
                                          child: Text(
                                            "Sei già censito per questo torneo!",
                                            style: CustomFlowTheme.of(context).labelLarge,
                                          ),
                                        ),
                                        AFButtonWidget(
                                          onPressed: () async {
                                            FocusScope.of(context).unfocus();
                                            context.goNamed(
                                                'DialogDeEnrollPlayer',
                                                pathParameters: {
                                                  'tournamentId': providerTournamentDetail.tournamentModel.tournamentId,
                                                }.withoutNulls,
                                                extra: {
                                                  'req': tournamentDetailModel.showDeEnrollPlayerAlertRequest(),
                                                }
                                            );
                                          },
                                          text: 'De-registrati',
                                          options: AFButtonOptions(
                                            width: double.infinity,
                                            height: 50,
                                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                            color: const Color(0xFFFFD4D4),
                                            textStyle: CustomFlowTheme.of(context).bodyMedium.override(color: const Color(0xFFB74D4D)),
                                            elevation: 0,
                                            borderSide: BorderSide(
                                              color: CustomFlowTheme.of(context).primary,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
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
    locale: const Locale('it'),
    context: context,
    initialDate: tournamentModel.tournamentDate ?? DateTime.now(),
    firstDate: DateTime.now().isBefore(tournamentModel.tournamentDate??DateTime.now()) ? DateTime.now() : tournamentModel.tournamentDate??DateTime.now(),
    lastDate: DateTime(2101),
  );

  if(pickedDate != null) {
    tournamentModel.setTournamentData(pickedDate);
  }
}
