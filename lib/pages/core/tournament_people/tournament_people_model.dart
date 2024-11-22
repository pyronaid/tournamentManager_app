import 'package:flutter/cupertino.dart';

class TournamentPeopleModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();


  /////////////////////////////CONSTRUCTOR
  TournamentPeopleModel();

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