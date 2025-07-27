import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/tournament_people_card/tournament_people_card_model.dart';

import '../../backend/schema/enrollments_record.dart';

class TournamentPeopleCardWidget extends StatefulWidget {

  const TournamentPeopleCardWidget({
    super.key,
    required this.userRef,
    required this.indexo,
    required this.listType,
    required this.peopleModel,
    required this.promote,
    required this.tournamentRef,
  });


  final EnrollmentsRecord userRef;
  final int indexo;
  final ListType listType;
  final ChangeNotifier peopleModel;
  final bool promote;
  final String tournamentRef;

  @override
  State<TournamentPeopleCardWidget> createState() => _TournamentPeopleCardWidgetState();
}

class _TournamentPeopleCardWidgetState extends State<TournamentPeopleCardWidget> {
  late TournamentPeopleCardModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TournamentPeopleCardModel(widget.peopleModel, widget.listType));

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
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Slidable(
        // Specify a key if the Slidable is dismissible.
        key: ValueKey(widget.indexo),
        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (widget.promote) ...[
              SlidableAction(
                onPressed: (context){
                  context.goNamed(
                      'DialogPromotePerson',
                      pathParameters: {
                        'tournamentId': widget.tournamentRef,
                      }.withoutNulls,
                      extra: {
                        'req' : _model.showPromotePeopleAlertRequest(widget.userRef),
                      }
                  );
                },
                backgroundColor: CustomFlowTheme.of(context).accent1,
                foregroundColor: CustomFlowTheme.of(context).info,
                icon: Icons.file_upload,
                label: 'Promote',
              ),
            ],
            SlidableAction(
              onPressed: (context){
                context.goNamed(
                    'DialogDeletePerson',
                    pathParameters: {
                      'tournamentId': widget.tournamentRef,
                    }.withoutNulls,
                    extra: {
                      'req' : _model.showDeletePeopleAlertRequest(widget.userRef),
                    }
                );
              },
              backgroundColor: CustomFlowTheme.of(context).error,
              foregroundColor: CustomFlowTheme.of(context).info,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Container(
          width: 1000,
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).tertiary,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userRef.username,
                  style: CustomFlowTheme.of(context).titleLarge.override(color: CustomFlowTheme.of(context).cardMain),
                ),
                Text(
                  '${widget.userRef.name} ${widget.userRef.surname}',
                  style: CustomFlowTheme.of(context).titleMedium.override(color: CustomFlowTheme.of(context).cardSecond),
                ),
                Text(
                  widget.userRef.userId,
                  style: CustomFlowTheme.of(context).bodySmall.override(color: CustomFlowTheme.of(context).cardMain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}