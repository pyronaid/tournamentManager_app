import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/components/tournament_pick_card/tournament_pick_card_model.dart';


class TournamentPickCardWidget extends StatefulWidget {
  const TournamentPickCardWidget({
    super.key,
    this.tournamentRef,
  });

  final TournamentsRecord? tournamentRef;

  @override
  State<TournamentPickCardWidget> createState() => _TournamentPickCardWidgetState();
}

class _TournamentPickCardWidgetState extends State<TournamentPickCardWidget> {
  late TournamentPickCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentPickCardModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsetsDirectional.all(10),
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).primary,
            borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(5),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ////////////////
                //DATE
                /////////////////
                SizedBox(
                  width: 15.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('dd').format(widget.tournamentRef!.date!),
                        style: CustomFlowTheme.of(context).titleLarge,
                      ),
                      Text(
                        DateFormat('MM').format(widget.tournamentRef!.date!),
                        style: CustomFlowTheme.of(context).bodyMedium,
                      ),
                      Text(
                        DateFormat('yyyy').format(widget.tournamentRef!.date!),
                        style: CustomFlowTheme.of(context).bodyMedium,
                      ),
                    ],
                  ),
                ),
                ////////////////
                //NAME & ADDRESS & Organizer
                /////////////////
                SizedBox(
                  width: 50.w,
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.tournamentRef!.name,
                          style: CustomFlowTheme.of(context).bodyMedium,
                        ),
                        Divider(
                          thickness: 1,
                          color: CustomFlowTheme.of(context).primaryText,
                          height: 10, // Space around the divider
                        ),
                        RichText(
                          text: TextSpan(
                            style: CustomFlowTheme.of(context).labelMedium.override(color: CustomFlowTheme.of(context).primaryText),
                            children: [
                              TextSpan(text: widget.tournamentRef!.address,),
                              const TextSpan(text: '  '),
                              WidgetSpan(
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Icon(
                                    Icons.open_in_new,
                                    color: CustomFlowTheme.of(context).primaryText,
                                    size: 18,
                                  ),
                                  onPressed: () async {
                                    _model.showMapApp(widget.tournamentRef!.latitude, widget.tournamentRef!.longitude, widget.tournamentRef!.name);
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          color: CustomFlowTheme.of(context).primaryText,
                          height: 10, // Space around the divider
                        ),
                        Text(
                          widget.tournamentRef!.creatorUid,
                          style: CustomFlowTheme.of(context).labelMedium.override(color: CustomFlowTheme.of(context).primaryText),
                        ),
                      ],
                    ),
                  ),
                ),
                ////////////////
                //LOGO GAME
                /////////////////
                if(widget.tournamentRef!.game!.iconResource != null)...[
                  SizedBox(
                    width: 25.w,
                    child: Image.asset(
                      widget.tournamentRef!.game!.iconResource!,
                      width: 70,
                      height: 70,
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ],
    );
  }
}