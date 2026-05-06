// components/custom_expansion_panel_widget.dart

import 'package:flutter/material.dart';

/// A wrapper that optionally makes its [child] expandable.
/// When [isExpandable] is false the child is returned unwrapped —
/// zero overhead, no animations, no gesture detection.
class CustomExpansionPanelWidget extends StatefulWidget {
  const CustomExpansionPanelWidget({
    super.key,
    required this.child,
    this.expandedContentBuilder,
    this.isExpandable = false,
  });

  final Widget child;
  final Widget Function(BuildContext context)? expandedContentBuilder;
  final bool isExpandable;

  @override
  State<CustomExpansionPanelWidget> createState() =>
      _CustomExpansionPanelWidgetState();
}

class _CustomExpansionPanelWidgetState
    extends State<CustomExpansionPanelWidget> {

  // ── Local UI state (was CustomExpansionPanelModel._isExpanded) ────────────
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Fast path — no StatefulWidget overhead wasted on non-expandable usage.
    if (!widget.isExpandable) return widget.child;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: widget.child,
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild:
          widget.expandedContentBuilder?.call(context) ??
              const SizedBox.shrink(),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}