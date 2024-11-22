import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/pages/core/tournament_people/tournament_people_model.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class TournamentPeopleWidget extends StatefulWidget {
  const TournamentPeopleWidget({super.key});

  @override
  State<TournamentPeopleWidget> createState() => _TournamentPeopleWidgetState();
}


class _TournamentPeopleWidgetState extends State<TournamentPeopleWidget> {

  late TournamentPeopleModel tournamentPeopleModel;
  late TournamentModel tournamentModel;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    //logFirebaseEvent('screen_view', parameters: {'screen_name': 'TournamentDetail'});
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));

    tournamentPeopleModel = context.read<TournamentPeopleModel>();
    tournamentModel = context.read<TournamentModel>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => tournamentPeopleModel.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(tournamentPeopleModel.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Consumer<TournamentModel>(
          builder: (context, providerTournament, _) {
            print("[BUILD IN CORSO] tournament_news_widget.dart");
            if (tournamentModel.isLoading) {
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
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Ciao"),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}