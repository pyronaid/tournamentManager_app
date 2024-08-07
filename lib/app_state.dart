import 'package:flutter/material.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';

class CustomAppState extends ChangeNotifier {
  static CustomAppState _instance = CustomAppState._internal();

  factory CustomAppState() {
    return _instance;
  }

  CustomAppState._internal();

  static void reset() {
    _instance = CustomAppState._internal();
  }

  Future initializePersistedState() async {
    //retrieve the tournament joined by the user

    //retrieve the tournament owned by the user
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _userValueOne = '';
  String get userValueOne => _userValueOne;
  set userValueOne(String value) {
    _userValueOne = value;
  }



  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////
  ////////// TournamentsOwned
  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////

  List<TournamentsRecord> _tournamentsOwned = [];
  List<TournamentsRecord> get tournamentsOwned => _tournamentsOwned;
  set tournamentsOwned(List<TournamentsRecord> value) {
    _tournamentsOwned = value;
  }

  void addToTournamentsOwned(TournamentsRecord value) {
    _tournamentsOwned.add(value);
  }

  void removeFromTournamentsOwned(TournamentsRecord value) {
    _tournamentsOwned.remove(value);
  }

  void removeAtIndexFromTournamentsOwned(int index) {
    _tournamentsOwned.removeAt(index);
  }

  void updateTournamentsOwnedAtIndex(int index, TournamentsRecord Function(TournamentsRecord) updateFn,) {
    _tournamentsOwned[index] = updateFn(_tournamentsOwned[index]);
  }

  void insertAtIndexInTournamentsOwned(int index, TournamentsRecord value) {
    _tournamentsOwned.insert(index, value);
  }


  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////
  ////////// TournamentsJoined
  /////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////

  List<TournamentsRecord> _tournamentsJoined = [];
  List<TournamentsRecord> get tournamentsJoined => _tournamentsJoined;
  set tournamentsJoined(List<TournamentsRecord> value) {
    _tournamentsJoined = value;
  }

  void addToTournamentsJoined(TournamentsRecord value) {
    _tournamentsJoined.add(value);
  }

  void removeFromTournamentsJoined(TournamentsRecord value) {
    _tournamentsJoined.remove(value);
  }

  void removeAtIndexFromTournamentsJoined(int index) {
    _tournamentsJoined.removeAt(index);
  }

  void updateTournamentsJoinedAtIndex(int index, TournamentsRecord Function(TournamentsRecord) updateFn,) {
    _tournamentsJoined[index] = updateFn(_tournamentsJoined[index]);
  }

  void insertAtIndexInTournamentsJoined(int index, TournamentsRecord value) {
    _tournamentsJoined.insert(index, value);
  }


}
