InputDecoration standardInputDecoration(BuildContext context) {
  return InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).alternate,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).primary,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: CustomFlowTheme.of(context).error,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
    filled: true,
    fillColor: CustomFlowTheme.of(context).secondaryBackground,
    errorMaxLines: 2,
  );
}
