import 'package:flutter/material.dart';
import 'package:tournamentmanager/app_flow/app_flow_model.dart';
import 'package:tournamentmanager/components/fab_expandable/fab_expandable_widget.dart';


class FabExpandableModel extends CustomFlowModel<FabExpandableWidget> {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  final TickerProvider tickerProvider;
  bool _open = false;

  FabExpandableModel(this.tickerProvider);

  @override
  void initState(BuildContext context) {
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: tickerProvider,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );

  }

  @override
  void dispose() {
    _controller.dispose();
  }

  ///////////////////////////// GETTER
  Animation<double> get expandAnimation => _expandAnimation;
  bool get open => _open;

  ///////////////////////////// SETTER
  void toggle() {
    updatePage(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }





}
