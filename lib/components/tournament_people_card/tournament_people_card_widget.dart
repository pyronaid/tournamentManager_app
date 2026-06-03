import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../app_flow/app_flow_theme.dart';
import '../../backend/schema/enrollments_record.dart';

class TournamentPeopleCardWidget extends StatelessWidget {
  const TournamentPeopleCardWidget({
    super.key,
    required this.enrollment,
    required this.index,
    required this.listType,
    required this.tournamentId,
    required this.editable,
    required this.inpectable,
    required this.promote,
    required this.onDelete,   // ← callbacks bubble intent up
    required this.onPromote,
  });

  final EnrollmentsRecord enrollment;
  final int index;
  final ListType listType;
  final String tournamentId;
  final bool editable;
  final bool inpectable;
  final bool promote;
  final VoidCallback onDelete;
  final VoidCallback onPromote;
  
  void _goToDecklist() {
   /*ROUTING TO DECKLIST PAGE OF SPECIFIC USER*/
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 15, 10, 0),
      child: Slidable(
        key: ValueKey('people$index'),
        endActionPane: editable
            ? ActionPane(
                motion: const ScrollMotion(),
                children: [
                  if (promote)
                    SlidableAction(
                      onPressed: (_) => onPromote(),
                      backgroundColor: CustomFlowTheme.of(context).accent1,
                      foregroundColor: CustomFlowTheme.of(context).info,
                      icon: Icons.file_upload,
                      label: 'Promote',
                    ),
                  SlidableAction(
                    onPressed: (_) => onDelete(),
                    backgroundColor: CustomFlowTheme.of(context).error,
                    foregroundColor: CustomFlowTheme.of(context).info,
                    icon: Icons.delete,
                    label: 'Delete',
                  ),
                ],
              )
            : null,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: CustomFlowTheme.of(context).tertiary,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 8,
                  fit: FlexFit.loose,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(enrollment.username,
                          style: CustomFlowTheme.of(context).titleLarge),
                      Text('${enrollment.name} ${enrollment.surname}',
                          style: CustomFlowTheme.of(context).titleMedium),
                      Text(enrollment.userId,
                          style: CustomFlowTheme.of(context).bodySmall),
                    ],
                  ),
                ),
                if (inpectable) ...[
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: enrollment.decklist != null ?
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.open_in_new,
                          color: theme.primaryText,
                          size: 18.0,
                          onPressed: _goToDecklist,
                        )
                      ): IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          Icons.x,
                          color: theme.error,
                          size: 18.0,
                        ),
                      ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
