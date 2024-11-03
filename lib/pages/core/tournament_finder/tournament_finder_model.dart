import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';




class TournamentFinderModel extends ChangeNotifier {

  StreamSubscription<List<TournamentsRecord>>? _tournamentsSubscription;
  late List<TournamentsRecord> tournamentsListRefObj;

  final _unfocusNode = FocusNode();
  bool isLoading = true;
  Timer? _debounce;


  //////////////////////////////MAP
  late MapController _mapController;
  late LatLng _firstLocation;
  //FILTER PARAMETERS
  late DateTime _dateStart;
  late DateTime _dateEnd;
  late LatLng _lastLocation;
  late double _radiusInKm;



  /////////////////////////////CONSTRUCTOR
  TournamentFinderModel(){
    print("[CREATE] TournamentFinderModel");
    _radiusInKm = 50;
    _dateStart = DateTime.now();
    _dateEnd = _dateStart.add(const Duration(days: 7));
    _mapController = MapController();
    tournamentsListRefObj = [];
    fetchObjects();
  }

  /////////////////////////////GETTER
  FocusNode get unfocusNode{
    return _unfocusNode;
  }
  MapController get mapController{
    return _mapController;
  }
  LatLng get initialLocation{
    return _firstLocation;
  }

  /////////////////////////////SETTER
  Future<void> setLocation() async {
    _firstLocation = const LatLng(45.464664, 9.188540);
    final location = Location();
    final hasPermission = await location.requestPermission() == PermissionStatus.granted;
    if (hasPermission) {
      final currentLocation = await location.getLocation();
      _firstLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
      _lastLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    }
  }
  void refreshSearch(MapCamera position) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final LatLng center = position.center;
      final double zoom = position.zoom;
      final double radius = (position.visibleBounds.north - center.latitude) * 111.32 < 50 ? 50 : (position.visibleBounds.north - center.latitude) * 111.32;
      //print('Debounced Center: $center, Zoom: $zoom, bounds ${position.visibleBounds}');
      //print('current bounds north ${_location.latitude + latDelta} south ${_location.latitude - latDelta} east ${_location.longitude + lonDelta} west ${_location.longitude - lonDelta}');
      if(position.visibleBounds.north > (_lastLocation.latitude + (_radiusInKm / 111.32)) ||
          position.visibleBounds.south < (_lastLocation.latitude - (_radiusInKm / 111.32)) ||
          position.visibleBounds.east > (_lastLocation.longitude + (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180)))) ||
          position.visibleBounds.west < (_lastLocation.longitude - (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180))))){

        print('REFRESH START');
        await _tournamentsSubscription?.cancel();
        var query = TournamentsRecord.collection
            .where('latitude', isGreaterThanOrEqualTo: position.visibleBounds.south) //south
            .where('latitude', isLessThanOrEqualTo: position.visibleBounds.north) //north
            .where('longitude', isGreaterThanOrEqualTo: position.visibleBounds.west) //west
            .where('longitude', isLessThanOrEqualTo: position.visibleBounds.east); //east
        _tournamentsSubscription = TournamentsRecord.getDocuments(query).listen((tournamentsList) {
          tournamentsListRefObj = tournamentsList;
          _lastLocation = position.center;
          _radiusInKm = radius;
          print('REFRESH END');
          notifyListeners();
        });
      }
    });
  }





  @override
  void dispose() {
    unfocusNode.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> fetchObjects() async {
    print("[LOAD FROM FIREBASE IN CORSO] tournament_finder_model.dart");
    await setLocation();
    var query = TournamentsRecord.collection
        .where('latitude', isGreaterThanOrEqualTo: _firstLocation.latitude - (_radiusInKm / 111.32)) //south
        .where('latitude', isLessThanOrEqualTo: _firstLocation.latitude + (_radiusInKm / 111.32)) //north
        .where('longitude', isGreaterThanOrEqualTo: _firstLocation.longitude - (_radiusInKm / (111.32 * cos(_firstLocation.latitude * pi / 180)))) //west
        .where('longitude', isLessThanOrEqualTo: _firstLocation.longitude + (_radiusInKm / (111.32 * cos(_firstLocation.latitude * pi / 180)))); //east
    _tournamentsSubscription = TournamentsRecord.getDocuments(query).listen((tournamentsList) {
      tournamentsListRefObj = tournamentsList;
      isLoading = false;
      notifyListeners();
    });
  }

}