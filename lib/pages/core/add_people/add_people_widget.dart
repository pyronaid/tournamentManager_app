import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/app_flow_widgets.dart';
import 'package:tournamentmanager/backend/firebase_analytics/analytics.dart';
import 'package:tournamentmanager/components/custom_appbar_widget.dart';
import 'package:tournamentmanager/components/standard_graphics/standard_graphics_widgets.dart';
import 'package:tournamentmanager/pages/core/add_people/add_people_model.dart';
import '../tournament_people/tournament_people_model.dart';



class AddPeopleWidget extends StatefulWidget {
  const AddPeopleWidget({super.key});

  @override
  State<AddPeopleWidget> createState() => _AddPeopleWidgetState();
}


class _AddPeopleWidgetState extends State<AddPeopleWidget> {

  late AddPeopleModel addPeopleModel;
  late ChangeNotifier tournamentPeopleModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _unfocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'CreateNews'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    addPeopleModel = context.read<AddPeopleModel>();
    addPeopleModel.initContextVars(context);
    tournamentPeopleModel = context.read<TournamentPeopleModel>();
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
      child: Consumer2<TournamentPeopleModel, AddPeopleModel>(builder: (context, providerPeople, providerAddPeople, _) {
        print("[BUILD IN CORSO] add_people_widget.dart");
        if (providerPeople.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scaffold(
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
                        model: providerAddPeople.customAppbarModel,
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
                          'Registra un giocatore',
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
                            // Input area
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
                                      'Id utente',
                                      style: CustomFlowTheme.of(context).bodyMedium,
                                    ),
                                  ),
                                  TextFormField(
                                    controller: providerAddPeople.fieldControllerIdUser,
                                    focusNode: providerAddPeople.idUserFocusNode,
                                    autofocus: false,
                                    autofillHints: const [AutofillHints.name],
                                    textCapitalization: TextCapitalization.none,
                                    textInputAction: TextInputAction.next,
                                    obscureText: false,
                                    decoration: standardInputDecoration(
                                      context,
                                      prefixIcon: Icon(
                                        Icons.badge,
                                        color: CustomFlowTheme.of(context).secondaryText,
                                        size: 18,
                                      ),
                                      suffixIcons: [
                                        IconButton(
                                          onPressed: () async {
                                            if(providerAddPeople.fieldControllerIdUser.text.isNotEmpty) {
                                              // Handle the scanned barcode value.
                                              Map<String, dynamic> respMap = await providerPeople.getUserInfoForEnrollment(providerAddPeople.fieldControllerIdUser.text, listType: providerPeople.listTypeReferral);
                                              addPeopleModel.composeOutputForRequest(respMap, listType: providerPeople.listTypeReferral);
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.refresh,
                                            size: 20,
                                          ),
                                          color: CustomFlowTheme.of(context).secondaryText,
                                        ),
                                        IconButton(
                                          onPressed: () async {
                                            final result = await context.pushNamedAuth(
                                              'ScannerCode', context.mounted,
                                              pathParameters: {
                                                'tournamentId': providerPeople.tournamentModel.tournamentId,
                                              }.withoutNulls,
                                            );

                                            if (result != null) {
                                              print('Scanned Barcode: $result');
                                              providerAddPeople.setFieldControllerIdUser(result);
                                              if(providerAddPeople.fieldControllerIdUser.text.isNotEmpty) {
                                                // Handle the scanned barcode value.
                                                Map<String, dynamic> respMap = await providerPeople.getUserInfoForEnrollment(providerAddPeople.fieldControllerIdUser.text, listType: providerPeople.listTypeReferral);
                                                addPeopleModel.composeOutputForRequest(respMap, listType: providerPeople.listTypeReferral);
                                              }

                                            }
                                          },
                                          icon: const Icon(
                                            Icons.qr_code,
                                            size: 20,
                                          ),
                                          color: CustomFlowTheme.of(context).secondaryText,
                                        )
                                      ],
                                    ),
                                    style: CustomFlowTheme.of(context).bodyLarge.override(
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 1,
                                    ),
                                    minLines: 1,
                                    cursorColor: CustomFlowTheme.of(context).primary,
                                    validator: providerAddPeople.idUserTextControllerValidator.asValidator(context),
                                  ),
                                ],
                              ),
                            ),
                            //////////////////////////////////////////
                            // Checks area
                            //////////////////////////////////////////
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 30),
                              child: Column(
                                children: [
                                  if(providerAddPeople.messageObjList.isNotEmpty)...[
                                    for (MessagePeople message in providerAddPeople.messageObjList)...[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: message.messageLevel.color, // Green background
                                                  shape: BoxShape.circle, // Makes the container circular
                                                ),
                                                width: 30, // Width of the circle
                                                height: 30, // Height of the circle
                                                child: Icon(
                                                  message.messageLevel.icon,
                                                  color: Colors.white, // Icon color
                                                  size: 20, // Icon size
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20,),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.message,
                                                    style: CustomFlowTheme.of(context).titleSmall,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      ////////////////
                      //VALIDATION BUTTON
                      /////////////////
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                        child: AFButtonWidget(
                          onPressed: (!providerAddPeople.checked) ? null : () async {
                            FocusScope.of(context).unfocus();
                            logFirebaseEvent('ONBOARDING_ADD_USER_ADD_USER');
                            logFirebaseEvent('Button_validate_form');
                            if (_formKey.currentState == null ||
                                !_formKey.currentState!.validate()) {
                              return;
                            }

                            bool flag = await providerPeople.promotePeople(providerAddPeople.fieldControllerIdUser.text, listType: providerPeople.listTypeReferral);
                            if (flag && mounted){
                              context.safePop();
                            }
                            logFirebaseEvent('Button_haptic_feedback');
                            HapticFeedback.lightImpact();
                          },
                          text: 'Aggiungi',
                          options: AFButtonOptions(
                            width: double.infinity,
                            height: 50,
                            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            color: CustomFlowTheme.of(context).primary,
                            disabledColor: CustomFlowTheme.of(context).disabled,
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
            ),
          ),
        );
      }),
    );
  }
}
