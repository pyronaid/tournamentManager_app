// tournament_people_card_widget.dart
class TournamentPeopleCardWidget extends StatelessWidget {
  const TournamentPeopleCardWidget({
    super.key,
    required this.enrollment,
    required this.index,
    required this.listType,
    required this.tournamentId,
    required this.editable,
    required this.promote,
    required this.onDelete,   // ← callbacks bubble intent up
    required this.onPromote,
  });

  final EnrollmentsRecord enrollment;
  final int index;
  final ListType listType;
  final String tournamentId;
  final bool editable;
  final bool promote;
  final VoidCallback onDelete;
  final VoidCallback onPromote;

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
        ),
      ),
    );
  }
}
