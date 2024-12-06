import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/fab_expandable/fab_expandable_model.dart';
import 'dart:math' as math;

import '../../app_flow/app_flow_theme.dart';

class FabExpandableWidget extends StatefulWidget {
  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  const FabExpandableWidget({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,

  });

  @override
  State<FabExpandableWidget> createState() => _FabExpandableWidgetState();
}

class _FabExpandableWidgetState extends State<FabExpandableWidget> with SingleTickerProviderStateMixin{
  late FabExpandableModel _model;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FabExpandableModel(this).setOnUpdate(
      updateOnChange: true,
      onUpdate: () {
        setState(() {});
      },
    ) as FabExpandableModel);

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();
    super.dispose();
  }

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
            onTap: _model.toggle,
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
    final children = <Widget>[];
    final count = widget.children.length;
    final step = 90.0 / (count - 1);
    for (var i = 0, angleInDegrees = 0.0, distance = 60.0;
            i < count;
            i++, angleInDegrees += step, distance += widget.distance) {
      children.add(
        _ExpandingActionButton(
          directionInDegrees: 90,
          maxDistance: distance,
          progress: _model.expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }
  Widget _buildTapToOpenFab() {
    final theme = CustomFlowTheme.of(context);
    return IgnorePointer(
      ignoring: _model.open,
      child: AnimatedContainer(
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _model.open ? 0.7 : 1.0,
          _model.open ? 0.7 : 1.0,
          1.0,
        ),
        duration: const Duration(milliseconds: 250),
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
        child: AnimatedOpacity(
          opacity: _model.open ? 0.0 : 1.0,
          curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton(
            backgroundColor: theme.primary,
            onPressed: _model.toggle,
            child: Icon(
              Icons.list,
              color: CustomFlowTheme.of(context).info,
            ),
          ),
        ),
      ),
    );
  }
}


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
          /*child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),*/
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

@immutable
class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
  });

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = CustomFlowTheme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.primary,
      elevation: 4,
      child: IconButton(
        onPressed: onPressed,
        icon: icon,
        color: theme.info,
      ),
    );
  }
}
