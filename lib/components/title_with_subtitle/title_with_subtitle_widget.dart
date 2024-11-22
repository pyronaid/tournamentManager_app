import 'package:flutter/cupertino.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/components/title_with_subtitle/title_with_subtitle_model.dart';


class TitleWithSubtitleWidget extends StatefulWidget {
  const TitleWithSubtitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String? title;
  final String? subtitle;

  @override
  State<TitleWithSubtitleWidget> createState() => _TitleWithSubtitleWidgetState();
}

class _TitleWithSubtitleWidgetState extends State<TitleWithSubtitleWidget> {
  late TitleWithSubtitleModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TitleWithSubtitleModel());

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
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 4.0),
          child: Text(
            valueOrDefault<String>(
              widget.title,
              'Test title',
            ),
            style: CustomFlowTheme.of(context).bodyMedium.override(fontSize: 16.0),
          ),
        ),
        Text(
          valueOrDefault<String>(
            widget.subtitle,
            'Test subtitle',
          ),
          style: CustomFlowTheme.of(context).labelMedium,
        ),
      ].divide(const SizedBox(height: 4.0)),
    );
  }
}
