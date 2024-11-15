import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:tournamentmanager/backend/schema/tournaments_with_creator_record.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/app_flow_util.dart';
import '../../../app_flow/services/DialogService.dart';
import '../../../app_flow/services/PlacesApiManagerService.dart';
import '../../../app_flow/services/supportClass/alert_classes.dart';
import '../../../backend/backend.dart';

class TournamentFinderModel extends ChangeNotifier {

  StreamSubscription<List<TournamentsWithCreatorRecord>>? _tournamentsSubscription;
  late List<TournamentsRecord> tournamentsListRefObj;
  late List<TournamentsRecord> tournamentsListRefObjToDetail;

  final _unfocusNode = FocusNode();
  late DialogService dialogService;
  bool isLoading = true;
  bool isLoadingFetch = false;
  Timer? _debounce;

  late Future<PlacesApiManagerService> placesApiManagerService;
  late String _sessionToken;
  var uuid =  const Uuid();
  List<dynamic> _placeList = [];

  //////////////////////////////MAP
  late MapController _mapController;
  late LatLng _firstLocation;
  //FILTER PARAMETERS
  late LatLng _lastLocation;
  final double minRadius = 5;
  final double maxRadius = 100;
  final int zoom_constant = 125; //1000
  final int zoom_exp = 1; //2
  final double zoom_max = 18;
  String? _selectedMarkerId;



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
  late List<Game> _games;
  //////////////////////////////DATARANGE DIALOG
  late DateTime _dateStart;
  late DateTime _dateEnd;
  //////////////////////////////PANEL AREA
  late PanelController _panelController;
  late ScrollController _scrollController;


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
    _games = Game.values;
    _mapController = MapController();
    tournamentsListRefObj = [];
    tournamentsListRefObjToDetail = [];

    _panelController = PanelController();
    _scrollController = ScrollController();

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
  String? get selectedMarkerId{
    return _selectedMarkerId;
  }
  PanelController get panelController{
    return _panelController;
  }
  ScrollController get scrollController{
    return _scrollController;
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
  double computeZoomByRadius(double radius, double latitude, double longitude){
    const double earthCircumferenceKm = 40075.0;
    final double latitudeCorrection = cos(latitude * pi / 180);
    final double viewportWidthPixels = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final double pixelsPerKm = viewportWidthPixels / (2 * radius);

    final double zoom_level = log(earthCircumferenceKm * latitudeCorrection * pixelsPerKm / 110)/log(2);
    print("zoom_level $zoom_level pre clamp");
    return zoom_level.clamp(1.0, 18.0); // FlutterMap zoom range is 1-18
  }
  void refreshSearchByTap(MapCamera position) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final LatLng center = position.center;
      final double zoom = position.zoom;
      //final double radius = (position.visibleBounds.north - center.latitude) * 111.32 < minRadius ? minRadius : (position.visibleBounds.north - center.latitude) * 111.32;
      final double radius = const Distance().as(LengthUnit.Kilometer, center, position.visibleBounds.northEast);
      print("RELAZIONE MAPPA RAGGIO: $radius ZOOM: $zoom ");
      _radiusInKm = radius.clamp(minRadius, maxRadius);
      if(position.visibleBounds.north > (_lastLocation.latitude + (_radiusInKm / 111.32)) ||
          position.visibleBounds.south < (_lastLocation.latitude - (_radiusInKm / 111.32)) ||
          position.visibleBounds.east > (_lastLocation.longitude + (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180)))) ||
          position.visibleBounds.west < (_lastLocation.longitude - (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180))))){

        print('REFRESH START BY TAP');
        _lastLocation = position.center;
        await _tournamentsSubscription?.cancel();
        var query = getQuery(tournamentNameFilter: null);
        _tournamentsSubscription = TournamentsWithCreatorRecord.getDocuments(query).listen((tournamentsWithCreatorsList) {
          tournamentsListRefObj = tournamentsWithCreatorsList.map((twc) {
            TournamentsRecord t = twc.tournament;
            t.setCreatorUid(twc.creatorName);
            return t;
          }).toList();
          tournamentsListRefObjToDetail = updateObjsToDetail();
          notifyListeners();
          print('REFRESH END BY TAP');
        });
      } else {
        tournamentsListRefObjToDetail = updateObjsToDetail();
        notifyListeners();
      }
    });
  }
  Future<void> refreshSearchByFilter(String? nameToFilter, String? placeIdToFilter, double? sliderToFilter, List<Game>? gamesToFilter, List<DateTime>? dataRangeToFilter) async {
    if((nameToFilter == null || nameToFilter.isEmpty) &&
        (placeIdToFilter == null || placeIdToFilter.isEmpty) &&
        (sliderToFilter == null || sliderToFilter == _radiusInKm) &&
        (gamesToFilter == null || gamesToFilter == _games) &&
        (dataRangeToFilter == null || (dataRangeToFilter[0] == _dateStart && dataRangeToFilter[1] == _dateEnd))){
      return;
    }

    print('REFRESH START BY FILTER');
    //show loading start
    if(dataRangeToFilter != null){
      _dateStart =  dataRangeToFilter[0];
      _dateEnd =  dataRangeToFilter[1];
    }
    if(gamesToFilter != null){
      _games = gamesToFilter;
    }
    if(sliderToFilter != null){
      _radiusInKm = sliderToFilter;
    }
    if(placeIdToFilter != null){
      try {
        PlacesApiManagerService placesApiManagerServiceCompleted = await placesApiManagerService;
        Map<String,dynamic>? placeDetail = await placesApiManagerServiceCompleted.getPlaceDetail(placeIdToFilter);
        if(placeDetail != null) {
          LatLng selectedPos = LatLng(placeDetail['lat'], placeDetail['lng'],);
          double zoom_level = computeZoomByRadius(_radiusInKm, placeDetail['lat'], placeDetail['lng']);
          mapController.move(selectedPos, zoom_level);
          mapController.rotate(0);
        }
      } catch (e){
      }
    } else {
      double zoom_level = computeZoomByRadius(_radiusInKm, _mapController.camera.center.latitude,_mapController.camera.center.longitude);
      mapController.move(_mapController.camera.center, zoom_level);
      mapController.rotate(0);
    }
    await _tournamentsSubscription?.cancel();
    var query = getQuery(tournamentNameFilter: nameToFilter);
    _tournamentsSubscription = TournamentsWithCreatorRecord.getDocuments(query).listen((tournamentsWithCreatorsList) {
      tournamentsListRefObj = tournamentsWithCreatorsList.map((twc) {
        TournamentsRecord t = twc.tournament;
        t.setCreatorUid(twc.creatorName);
        return t;
      }).toList();
      tournamentsListRefObjToDetail = updateObjsToDetail();
      print('REFRESH END BY FILTER');
      notifyListeners();
    });
    // show loading end
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
          min: minRadius,
          max: maxRadius,
          divisions: 150,
          valueLabel: (value) => value.toStringAsFixed(0),
          key: GlobalKey<SliderFormElementState>(),
        ),
        DropdownFormElement<Game>(
          label: "Giochi di interesse",
          value: null,
          items: Game.values.where((game) => game.desc.isNotEmpty).toList(),
          selectedItems: _games,
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
    if(resp.confirmed){
      String? nameToFilter = (resp.formValues![0] as String);
      String? placeIdToFilter = (resp.formValues![1] as String?);
      double? sliderToFilter = (resp.formValues![2] as double);
      List<Game>? gamesToFilter = (resp.formValues![3]! as List<Game>);
      List<DateTime>? dataRangeToFilter = (resp.formValues![4]!.whereType<DateTime>().toList() as List<DateTime>);
      await refreshSearchByFilter(nameToFilter, placeIdToFilter, sliderToFilter, gamesToFilter, dataRangeToFilter);
    }
  }
  void onMarkerTap(String markerId){
    _selectedMarkerId = markerId;
    if (!_panelController.isPanelOpen) {
      _panelController.open();
    }
    final index = tournamentsListRefObj.indexWhere((m) => m.uid == markerId);
    if (index != -1) {
      // Calculate the offset for the selected item
      const itemHeight = 88.0; // Approximate height of each list item
      final targetOffset = index * itemHeight;

      // Scroll to the item with animation
      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }
  void populateListToDet() {
    tournamentsListRefObjToDetail = updateObjsToDetail();
    notifyListeners();
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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> fetchObjects() async {
    await setLocation();
    var query = getQuery(tournamentNameFilter: null, useFirst: true);
    _tournamentsSubscription = TournamentsWithCreatorRecord.getDocuments(query).listen((tournamentsWithCreatorsList) {
      tournamentsListRefObj = tournamentsWithCreatorsList.map((twc) {
        TournamentsRecord t = twc.tournament;
        t.setCreatorUid(twc.creatorName);
        return t;
      }).toList();
      //tournamentsListRefObjToDetail = updateObjsToDetail();
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

  Query<Object?> getQuery({String? tournamentNameFilter, bool useFirst = false}) {
    print("[LOAD FROM FIREBASE IN CORSO] tournament_finder_model.dart");
    double currentLat;
    double currentLong;
    if(useFirst){
      currentLat = _firstLocation.latitude;
      currentLong = _firstLocation.longitude;
    } else {
      currentLat = mapController.camera.center.latitude;
      currentLong = mapController.camera.center.longitude;
    }
    Query<Object?> query = TournamentsRecord.collection
        .where('state', isEqualTo: StateTournament.ready.name)
        .where('date', isLessThanOrEqualTo: _dateEnd) //date
        .where('date', isGreaterThanOrEqualTo: _dateStart) //date
        .where('game', whereIn: _games.map((g) => g.name).toList()) //games
        .where('latitude', isGreaterThanOrEqualTo: currentLat - (_radiusInKm / 111.32)) //south
        .where('latitude', isLessThanOrEqualTo: currentLat + (_radiusInKm / 111.32)) //north
        .where('longitude', isGreaterThanOrEqualTo: currentLong - (_radiusInKm / (111.32 * cos(currentLat * pi / 180)))) //west
        .where('longitude', isLessThanOrEqualTo: currentLong + (_radiusInKm / (111.32 * cos(currentLat * pi / 180)))); //east
    if(tournamentNameFilter != null){
      //query.where('name', contains: tournamentNameFilter);
    }
    return query;
  }

  List<TournamentsRecord> updateObjsToDetail(){
    return tournamentsListRefObj.where((tournament) {
      // Check if the latitude and longitude are within the specified ranges
      return tournament.latitude >= mapController.camera.visibleBounds.south &&
          tournament.latitude <= mapController.camera.visibleBounds.north &&
          tournament.longitude >= mapController.camera.visibleBounds.west &&
          tournament.longitude <= mapController.camera.visibleBounds.east;
    }).toList();
  }

}