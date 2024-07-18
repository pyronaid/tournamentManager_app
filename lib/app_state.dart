import 'package:flutter/material.dart';

class CustomAppState extends ChangeNotifier {
  static CustomAppState _instance = CustomAppState._internal();

  factory CustomAppState() {
    return _instance;
  }

  CustomAppState._internal();

  static void reset() {
    _instance = CustomAppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _userValueOne = '';
  String get userValueOne => _userValueOne;
  set userValueOne(String value) {
    _userValueOne = value;
  }

  List<String> _userArrayOne = [];
  List<String> get userArrayOne => _userArrayOne;
  set userArrayOne(List<String> value) {
    _userArrayOne = value;
  }

  void addToUserArrayOne(String value) {
    _userArrayOne.add(value);
  }

  void removeFromUserArrayOne(String value) {
    _userArrayOne.remove(value);
  }

  void removeAtIndexFromUserArrayOne(int index) {
    _userArrayOne.removeAt(index);
  }

  void updateUserArrayOneAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    _userArrayOne[index] = updateFn(_userArrayOne[index]);
  }

  void insertAtIndexInUserArrayOne(int index, String value) {
    _userArrayOne.insert(index, value);
  }


}
