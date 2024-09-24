import 'package:flutter/cupertino.dart';

class TournamentNewsModel extends ChangeNotifier {

  final _unfocusNode = FocusNode();


  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel(){
  }

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