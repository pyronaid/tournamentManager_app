import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/DialogService.dart';
import '../../../app_flow/services/PlacesApiManagerService.dart';
import '../../../app_flow/services/supportClass/alert_classes.dart';
import '../../../backend/backend.dart';

class TournamentFinderModel extends ChangeNotifier {

  StreamSubscription<List<TournamentsRecord>>? _tournamentsSubscription;
  late List<TournamentsRecord> tournamentsListRefObj;

  final _unfocusNode = FocusNode();
  late DialogService dialogService;
  bool isLoading = true;
  bool isLoadingFetch = false;
  Timer? _debounce;

  late Future<PlacesApiManagerService> placesApiManagerService;
  late String _sessionToken;
  var uuid =  const Uuid();
  List<dynamic> _placeList = [];
  dynamic _selectedPlace;

  //////////////////////////////MAP
  late MapController _mapController;
  late LatLng _firstLocation;
  //FILTER PARAMETERS
  late LatLng _lastLocation;
  final double minRadius = 50;
  final int zoom_constant = 125; //1000
  final int zoom_exp = 1; //2
  final int zoom_max = 18;



  //////////////////////////////NAME DIALOG
  late TextEditingController _fieldControllerName;
  late String? Function(BuildContext, String?, String?)? tournamentNameTextControllerValidator;
  late FocusNode? _tournamentNameFocusNode;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    return null;
  }
  //////////////////////////////CENTER PLACE DIALOG
  late TextEditingController _fieldControllerCenterPlace;
  late FocusNode? _tournamentCenterPlaceFocusNode;
  String? _tournamentCenterPlaceTextControllerValidator(BuildContext context, String? val, String? placeId, String? lastSelected) {
    if(lastSelected != null && lastSelected != val){
      return "Non hai inserito un indirizzo valido";
    }

    if(lastSelected != null && placeId == null){
      return "Non hai inserito un indirizzo valido";
    }
    return null;
  }
  //////////////////////////////DATERANGE DIALOG
  late TextEditingController _fieldControllerDateRange;
  late String? Function(BuildContext, String?, String?)? tournamentDateRangeTextControllerValidator;
  late FocusNode? _tournamentDateRangeFocusNode;
  String? _tournamentDateRangeTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    if(val != null && val.isNotEmpty){
      if (!RegExp(kTextValidatorDateRangeRegex).hasMatch(val)) {
        return 'Il range inserito non ha un formato valido';
      }
      DateTime parsedDateStart = DateFormat('dd/MM/yyyy').parse(val.split('-')[0].trim());
      DateTime parsedDateEnd = DateFormat('dd/MM/yyyy').parse(val.split('-')[1].trim());
      DateTime now = DateTime.now();
      if (parsedDateStart.isBefore(now) || parsedDateEnd.isBefore(now) || parsedDateEnd.isBefore(parsedDateStart)) {
        return 'Le date inserite non possono essere nel passato e devono essere consecutive';
      }
    }
    return null;
  }
  //////////////////////////////SLIDER KM DIALOG
  late double _radiusInKm;
  //////////////////////////////DROPDOWN GAMES DIALOG
  late List<String> _games;
  //////////////////////////////DATARANGE DIALOG
  late DateTime _dateStart;
  late DateTime _dateEnd;


  /////////////////////////////CONSTRUCTOR
  TournamentFinderModel(){
    print("[CREATE] TournamentFinderModel");
    dialogService = GetIt.instance<DialogService>();
    _fieldControllerName = TextEditingController();
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    _tournamentNameFocusNode = FocusNode();
    _fieldControllerCenterPlace = TextEditingController();
    _tournamentCenterPlaceFocusNode = FocusNode();
    _fieldControllerDateRange = TextEditingController();
    tournamentDateRangeTextControllerValidator = _tournamentDateRangeTextControllerValidator;
    _tournamentDateRangeFocusNode = FocusNode();

    placesApiManagerService = GetIt.instance.getAsync<PlacesApiManagerService>();
    _sessionToken = uuid.v4();

    _radiusInKm = 50;
    _dateStart = DateTime.now();
    _dateEnd = _dateStart.add(const Duration(days: 7));
    _games = Game.values.map((g) => g.name).toList();
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
  TextEditingController get tournamentNameTextController{
    return _fieldControllerName;
  }
  FocusNode get tournamentNameFocusNode{
    return _tournamentNameFocusNode!;
  }
  TextEditingController get tournamentDateRangeTextController{
    return _fieldControllerDateRange;
  }
  FocusNode get tournamentDateRangeFocusNode{
    return _tournamentDateRangeFocusNode!;
  }
  TextEditingController get tournamentCenterPlaceTextController{
    return _fieldControllerCenterPlace;
  }
  FocusNode get tournamentCenterPlaceFocusNode{
    return _tournamentCenterPlaceFocusNode!;
  }

  /////////////////////////////SETTER
  void setRadiusInKm(double value) {
    _radiusInKm = value;
    notifyListeners();
  }
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
  int computeZoomByRadius(double radius, double latitude, double longitude){
    int zoom_level = round((log(radius/zoom_constant)/log(2))*zoom_exp) as int;
    return zoom_level > zoom_max ? zoom_max : zoom_level;
  }
  void refreshSearchByTap(MapCamera position) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final LatLng center = position.center;
      final double zoom = position.zoom;
      final double radius = (position.visibleBounds.north - center.latitude) * 111.32 < minRadius ? minRadius : (position.visibleBounds.north - center.latitude) * 111.32;
      //print('Debounced Center: $center, Zoom: $zoom, bounds ${position.visibleBounds}');
      //print('current bounds north ${_location.latitude + latDelta} south ${_location.latitude - latDelta} east ${_location.longitude + lonDelta} west ${_location.longitude - lonDelta}');
      if(position.visibleBounds.north > (_lastLocation.latitude + (_radiusInKm / 111.32)) ||
          position.visibleBounds.south < (_lastLocation.latitude - (_radiusInKm / 111.32)) ||
          position.visibleBounds.east > (_lastLocation.longitude + (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180)))) ||
          position.visibleBounds.west < (_lastLocation.longitude - (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180))))){

        print('REFRESH START');
        await _tournamentsSubscription?.cancel();
        var query = TournamentsRecord.collection
            .where('state', isEqualTo: StateTournament.ready.name)
            .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_dateEnd)) //date
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_dateStart)) //date
            .where('game', whereIn: _games) //games
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
  void refreshSearchByFilter() {
    /*
    _radiusInKm = radius;
    int zoom_level = computeZoomByRadius(radius, latitude, longitude);
    notifyListeners();*/
  }
  void showChangeTournamentCapacityDialog() async {
    AlertResponse resp = await dialogService.showDialogForm(
      title: 'Filtra la ricerca del Torneo',
      description: "Modifica i parametri per affinare la ricerca del tuo torneo.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Filtra",
      formInfo: [
        TextFormElement(
          controller: tournamentNameTextController,
          focusNode: tournamentNameFocusNode,
          iconPrefix: Icons.style,
          validatorFunction: tournamentNameTextControllerValidator,
          validatorParameter: null,
          label: "Nome Torneo",
        ),
        TextAheadAddressFormElement(
          controller: tournamentCenterPlaceTextController,
          focusNode: tournamentCenterPlaceFocusNode,
          iconPrefix: Icons.place,
          validatorFunction: _tournamentCenterPlaceTextControllerValidator,
          label: "Area di ricerca",
          callHintFunc: callAddressHint,
          key: GlobalKey<TextAheadAddressFormElementState>(),
        ),
        SliderFormElement(
          label: "Raggio (in km) di ricerca",
          sliderValue: _radiusInKm,
          min: 50,
          max: 200,
          divisions: 150,
          valueLabel: (value) => value.toStringAsFixed(0),
          key: GlobalKey<SliderFormElementState>(),
        ),
        DropdownFormElement<Game>(
          label: "Giochi di interesse",
          value: null,
          items: Game.values.where((game) => game.desc.isNotEmpty).toList(),
          nameExtractor: (Game item) => item.desc,
          key: GlobalKey<DropdownFormElementState>(),
        ),
        CalendarPickerFormElement(
          from: _dateStart,
          to: _dateEnd,
          label: "Date di ricerca",
          key: GlobalKey<CalendarPickerFormElementState>(),
        ),
      ],
    );
  }





  @override
  void dispose() {
    _tournamentsSubscription?.cancel();
    unfocusNode.dispose();
    _fieldControllerName.dispose();
    _fieldControllerCenterPlace.dispose();
    _fieldControllerDateRange.dispose();
    _tournamentNameFocusNode?.dispose();
    _tournamentCenterPlaceFocusNode?.dispose();
    _tournamentDateRangeFocusNode?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> fetchObjects() async {
    print("[LOAD FROM FIREBASE IN CORSO] tournament_finder_model.dart");
    await setLocation();
    var query = TournamentsRecord.collection
        .where('state', isEqualTo: StateTournament.ready.name)
        .where('date', isLessThanOrEqualTo: _dateEnd) //date
        .where('date', isGreaterThanOrEqualTo: _dateStart) //date
        .where('game', whereIn: _games) //games
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



  Future<List> callAddressHint() async {
    if(_fieldControllerCenterPlace.text.isNotEmpty) {
      print("[PLACES-API] CALL");
      PlacesApiManagerService placesApiManagerServiceCompleted = await placesApiManagerService;
      _placeList = await placesApiManagerServiceCompleted.getSuggestion(_fieldControllerCenterPlace.text, _sessionToken);
    }
    return _placeList;
  }

}