import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/pages/core/tournament_people/sub_page_preregistered_people/tournament_preregistered_people_model.dart';

import '../../../../app_flow/app_flow_theme.dart';
import '../../../../app_flow/app_flow_widgets.dart';
import '../../../../backend/firebase_analytics/analytics.dart';
import '../../../../components/standard_graphics/standard_graphics_widgets.dart';
import '../../../../components/tournament_people_card/tournament_people_card_widget.dart';

class TournamentPreregisteredPeopleWidget extends StatefulWidget {
  const TournamentPreregisteredPeopleWidget({super.key});

  @override
  State<TournamentPreregisteredPeopleWidget> createState() => _TournamentPreregisteredPeopleWidgetState();
}


class _TournamentPreregisteredPeopleWidgetState extends State<TournamentPreregisteredPeopleWidget> {

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentPeoplePreregistered'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentPreregisteredPeopleModel>(builder: (context, providerPreregisteredPeople, _) {
        print("[BUILD IN CORSO] tournament_preregistered_people_widget.dart");
        if (providerPreregisteredPeople.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: CustomFlowTheme.of(context).primaryBackground,
          body: SafeArea(
            top: true,
            child: SingleChildScrollView(
              child: SizedBox(
                width: 100.w,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //////////////////////////////////
                    ///////////  TEXT INPUT AND ADD BUTTON
                    //////////////////////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.symmetric(horizontal: 15, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 65.w,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: TextField(
                                controller: providerPreregisteredPeople.preregisteredPeopleNameTextController,
                                focusNode: providerPreregisteredPeople.preregisteredPeopleNameFocusNode,
                                autofocus: false,
                                obscureText: false,
                                decoration: standardInputDecoration(
                                  context,
                                  prefixIcon: Icon(
                                    Icons.person,
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
                              ),
                            ),
                          ),
                          Center(
                            child: AFButtonWidget(
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                logFirebaseEvent('Button_load_pic');
                                print("button_pressed");
                                logFirebaseEvent('Button_haptic_feedback');
                                HapticFeedback.lightImpact();
                              },
                              text: '',
                              icon: const Icon(Icons.add_circle,),
                              options: AFButtonOptions(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                                iconColor: Colors.white,
                                iconSize: 14,
                                color:  CustomFlowTheme.of(context).primary,
                                textStyle: CustomFlowTheme.of(context).labelLarge.override(
                                  color: CustomFlowTheme.of(context).info,
                                  fontSize: 0,
                                ),
                                elevation: 0,
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    //////////////////////////////////
                    ///////////  INFINITE LIST COUNTER
                    //////////////////////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
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
                          padding: const EdgeInsetsDirectional.all(10),
                          child: Text(
                            'Pre-Registrati: ${providerPreregisteredPeople.userNum}',
                            style: CustomFlowTheme.of(context).labelLarge,
                          ),
                        ),
                      ),
                    ),
                    //////////////////////////////////
                    ///////////  INFINITE LIST DETAIL
                    //////////////////////////////////
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 10, 24, 10),
                      child: Column(
                        children: List.generate(providerPreregisteredPeople.usersList.length, (index) {
                          final user = providerPreregisteredPeople.usersList[index];
                          return TournamentPeopleCardWidget(
                            key: Key('Keykia_user.uid.toadd_position_${index}_of_${providerPreregisteredPeople.usersList.length}'),
                            userRef: user,
                            indexo: index,
                            listType: ListType.preregistered,
                            peopleModel: providerPreregisteredPeople,
                          );
                        },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}