import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/components/tournament_pairing_card_expand/tournament_pairing_card_expand_model.dart';

import '../../app_flow/app_flow_model.dart';
import '../../app_flow/app_flow_theme.dart';
import '../../app_flow/app_flow_widgets.dart';
import '../../backend/schema/pairings_record.dart';

class TournamentPairingCardExpandWidget extends StatefulWidget {

  const TournamentPairingCardExpandWidget({
    super.key,
    required this.pairingRef
  });

  final PairingsRecord? pairingRef;

  @override
  State<TournamentPairingCardExpandWidget> createState() => _TournamentPairingCardExpandWidgetState();
}

class _TournamentPairingCardExpandWidgetState extends State<TournamentPairingCardExpandWidget> {
  late TournamentPairingCardExpandModel _model;

  final _formKey = GlobalKey<FormState>();

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentPairingCardExpandModel(
      dropPlayerA: widget.pairingRef!.dropPlayerA,
      dropPlayerB: widget.pairingRef!.dropPlayerB,
      noShow: widget.pairingRef!.noShow,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomRight: Radius.circular(10.0),
          bottomLeft: Radius.circular(10.0),
        ),
        child: Container(
          width: 1000,
          color: CustomFlowTheme.of(context).tertiaryDark,
          child: Container(
            constraints: const BoxConstraints(
              minHeight: 100,
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsetsDirectional.all(10),
                child: Form(
                  key: _formKey,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1), // 50% of available space
                      1: FlexColumnWidth(1), // 50% of available space
                    },
                    children: [
                      TableRow(
                        children: [
                          TableCell(
                            child: Text(
                              'WINNER',
                              style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                              softWrap: true,
                            ),
                          ),
                          TableCell(
                            child: Text(
                              '',
                              style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: ListTile(
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pairingRef!.namePlayerA,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                  Text(
                                    widget.pairingRef!.surnamePlayerA,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                  Text(
                                    widget.pairingRef!.usernamePlayerA,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              leading: Radio<String>(
                                value: widget.pairingRef!.playerA,
                                groupValue: _model.selectedWinner,
                                onChanged: (value) {
                                  setState(() {
                                    _model.radioChanged(value);
                                  });
                                },
                              ),
                            ),
                          ),
                          TableCell(
                            child: SwitchListTile(
                              value: _model.dropPlayerA,
                              onChanged: (value) {
                                setState(() {
                                  _model.switchDropPlayerA(value);
                                });
                              },
                              title: Text(
                                "Drop Torneo",
                                style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: ListTile(
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.pairingRef!.namePlayerB,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                  Text(
                                    widget.pairingRef!.surnamePlayerB,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                  Text(
                                    widget.pairingRef!.usernamePlayerB,
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              leading: Radio<String>(
                                value: widget.pairingRef!.playerB,
                                groupValue: _model.selectedWinner,
                                onChanged: (value) {
                                  setState(() {
                                    _model.radioChanged(value);
                                  });
                                },
                              ),
                            ),
                          ),
                          TableCell(
                            child: SwitchListTile(
                              value: _model.dropPlayerB,
                              onChanged: (value) {
                                setState(() {
                                  _model.switchDropPlayerB(value);
                                });
                              },
                              title: Text(
                                "Drop Torneo",
                                style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: ListTile(
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'doubleLoss',
                                    style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                ],
                              ),
                              leading: Radio<String>(
                                value: TournamentPairingCardExpandModel.doubleLoss,
                                groupValue: _model.selectedWinner,
                                onChanged: (value) {
                                  setState(() {
                                    _model.radioChanged(value);
                                  });
                                },
                              ),
                            ),
                          ),
                          TableCell(
                            child: SwitchListTile(
                              value: _model.noShow,
                              onChanged: (value) {
                                setState(() {
                                  _model.switchNoShow(value);
                                });
                              },
                              title: Text(
                                "No Show Win",
                                style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          TableCell(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _model.validationMessageError.map((elem) {
                                return Text(
                                  elem,
                                  style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).error),
                                  softWrap: true,
                                );
                              }).toList(),
                            ),
                          ),
                          TableCell(
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '',
                                    style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardMain),
                                    softWrap: true,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: AFButtonWidget(
                                    onPressed: () async {
                                      FocusScope.of(context).unfocus();
                                      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
                                        return;
                                      }

                                      HapticFeedback.lightImpact();
                                    },
                                    text: 'Salva',
                                    options: AFButtonOptions(
                                      height: 40,
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}