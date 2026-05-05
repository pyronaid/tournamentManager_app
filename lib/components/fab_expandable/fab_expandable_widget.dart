// components/fab_expandable/fab_expandable_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_theme.dart';

// ---------------------------------------------------------------------------
// PUBLIC API SURFACE
// FabExpandableWidget + ActionButton are the only public symbols.
// Everything else is private to this file.
// ---------------------------------------------------------------------------

class FabExpandableWidget extends StatefulWidget {
  const FabExpandableWidget({
    super.key,
    this.initialOpen = false,
    required this.distance,
    required this.children,
  });

  final bool initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<FabExpandableWidget> createState() => _FabExpandableWidgetState();
}

class _FabExpandableWidgetState extends State<FabExpandableWidget>
    with SingleTickerProviderStateMixin {

  // ── Animation state (was FabExpandableModel) ────────────────────────────
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();

    _open = widget.initialOpen;

    // `this` satisfies TickerProvider via SingleTickerProviderStateMixin —
    // no need to pass the vsync externally through a model.
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // always dispose controllers
    super.dispose();
  }

  // ── toggle (was FabExpandableModel.toggle) ───────────────────────────────
  void _toggle() {
    setState(() {
      _open = !_open;
      _open ? _controller.forward() : _controller.reverse();
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        alignment: Alignment.bottomRight,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return SizedBox(
      width: 56,
      height: 56,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.close,
                color: CustomFlowTheme.of(context).info,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final result = <Widget>[];
    final count = widget.children.length;

    // Guard: a single child would cause division by zero in step calculation.
    if (count == 0) return result;

    final step = count > 1 ? 90.0 / (count - 1) : 0.0;

    for (var i = 0; i < count; i++) {
      result.add(
        _ExpandingActionButton(
          directionInDegrees: 90,
          maxDistance: 60.0 + i * widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return result;
  }

  Widget _buildTapToOpenFab() {
    final theme = CustomFlowTheme.of(context);
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.7 : 1.0,
          _open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            heroTag: 'expandable_fab',
            backgroundColor: theme.primary,
            onPressed: _toggle,
            child: Icon(Icons.list, color: theme.info),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE — EXPANDING BUTTON POSITIONER
// Reads the animation value to offset its child radially.
// ---------------------------------------------------------------------------
@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (math.pi / 180.0),
          progress.value * maxDistance,
        );
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: child!,
        );
      },
      child: FadeTransition(opacity: progress, child: child),
    );
  }
}

// ---------------------------------------------------------------------------
// PUBLIC — ACTION BUTTON
// Reusable FAB child: icon + optional label pill.
// ---------------------------------------------------------------------------
@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.title,
  });

  final GestureTapCallback? onPressed;
  final IconData icon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    return InkWell(
      onTap: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: theme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title!,
                style: theme.titleMedium.override(color: theme.info),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            color: theme.primary,
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Icon(icon, color: theme.info, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}
