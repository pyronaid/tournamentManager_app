import 'package:flutter/cupertino.dart';

import '../../app_flow/app_flow_model.dart';
import 'custom_expansion_panel_model.dart';

class CustomExpansionPanelWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context)? expandedContentBuilder;
  final bool isExpandable;

  const CustomExpansionPanelWidget({
    super.key,
    required this.child,
    this.expandedContentBuilder,
    this.isExpandable = false,
  });

  @override
  State<CustomExpansionPanelWidget> createState() => _CustomExpansionPanelWidgetState();
}

class _CustomExpansionPanelWidgetState extends State<CustomExpansionPanelWidget> {
  late CustomExpansionPanelModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CustomExpansionPanelModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isExpandable) {
      // If not expandable, just return the child with no wrapper
      return widget.child;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _model.flipExpanded();
            });
          },
          child: widget.child,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: EdgeInsets.zero,
            child: widget.expandedContentBuilder?.call(context) ?? const SizedBox.shrink(),
          ),
          crossFadeState: _model.isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}