import 'package:flutter/cupertino.dart';

class TournamentRoundsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();


  /////////////////////////////CONSTRUCTOR
  TournamentRoundsModel();

  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }

  /////////////////////////////SETTER


  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

}