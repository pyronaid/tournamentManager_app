import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get_it/get_it.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tournamentmanager/app_flow/app_flow_util.dart';
import 'package:tournamentmanager/app_flow/services/PlacesApiManagerService.dart';
import 'package:tournamentmanager/app_flow/services/supportClass/alert_classes.dart';
import 'package:tournamentmanager/backend/schema/tournaments_record.dart';
import 'package:uuid/uuid.dart';

import '../../../app_flow/app_flow_widgets.dart';
import '../../../auth/pocketbase_auth/pocketbase_auth_util.dart';

class ClusterGradientData {
  const ClusterGradientData({
    required this.colors,
    required this.stops,
  }) : assert(
  colors.length == stops.length,
  'colors and stops must have the same length',
  );

  final List<Color> colors;
  final List<double> stops;
}


class TournamentFinderModel extends ChangeNotifier {

  StreamSubscription<List<TournamentsRecord>>? _tournamentsSubscription;
  late List<TournamentsRecord> tournamentsListRefObj;
  late List<TournamentsRecord> tournamentsListRefObjToDetail;

  bool isLoading = true;
  Timer? _debounce;

  late Future<PlacesApiManagerService> placesApiManagerService;
  late String _sessionToken;
  var uuid =  const Uuid();
  List<dynamic> _placeList = [];

  //////////////////////////////MAP
  late MapController _mapController;
  LatLng _firstLocation = const LatLng(45.464664, 9.188540);
  LatLng _lastLocation = const LatLng(45.464664, 9.188540);
  final double minRadius = 5;
  final double maxRadius = 100;
  String? _selectedMarkerId;



  //////////////////////////////NAME DIALOG
  late String? Function(BuildContext, String?, String?)? tournamentNameTextControllerValidator;
  String? _tournamentNameTextControllerValidator(BuildContext context, String? val, String? oldVal) {
    return null;
  }
  //////////////////////////////CENTER PLACE DIALOG
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
  late String? Function(BuildContext, String?, String?)? tournamentDateRangeTextControllerValidator;
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
  //////////////////////////////NAME DIALOG
  late String _name;
  //////////////////////////////PLACE DIALOG
  late Map<String,String> _place;
  //////////////////////////////SLIDER KM DIALOG
  late double _radiusInKm;
  //////////////////////////////DROPDOWN GAMES DIALOG
  late List<Game> _games;
  //////////////////////////////ONLINE FLAG DIALOG
  late bool _addOnlineToo;
  //////////////////////////////DATARANGE DIALOG
  late DateTime _dateStart;
  late DateTime _dateEnd;
  //////////////////////////////PANEL AREA
  late PanelController _panelController;
  late ScrollController _scrollController;
  late bool _mapInteractive;


  /////////////////////////////CONSTRUCTOR
  TournamentFinderModel(){
    assert(() {
      debugPrint('[CREATE] TournamentFinderModel');
      return true;
    }());
    tournamentNameTextControllerValidator = _tournamentNameTextControllerValidator;
    tournamentDateRangeTextControllerValidator = _tournamentDateRangeTextControllerValidator;

    placesApiManagerService = GetIt.instance.getAsync<PlacesApiManagerService>();
    _sessionToken = uuid.v4();

    _radiusInKm = 10;
    _name='';
    _place= {};
    _dateStart = DateTime.now();
    _dateEnd = _dateStart.add(const Duration(days: 7));
    _games = List.of(Game.values);
    _addOnlineToo = false;
    _mapController = MapController();
    tournamentsListRefObj = [];
    tournamentsListRefObjToDetail = [];

    _panelController = PanelController();
    _scrollController = ScrollController();
    _mapInteractive = true;

    fetchObjects();
  }

  /////////////////////////////GETTER
  MapController get mapController => _mapController;
  LatLng get initialLocation => _firstLocation;
  String? get selectedMarkerId => _selectedMarkerId;
  PanelController get panelController => _panelController;
  ScrollController get scrollController => _scrollController;
  bool get isMapInteractive => _mapInteractive;


  /////////////////////////////SETTER
  void setMapInteractive(bool value) {
    if (_mapInteractive == value) return; // avoid unnecessary notifyListeners
    _mapInteractive = value;
    notifyListeners();
  }
  Future<void> setLocation() async {
    final location = Location();
    final hasPermission = await location.requestPermission() == PermissionStatus.granted;
    if (hasPermission) {
      final currentLocation = await location.getLocation();
      _firstLocation = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    }
    _lastLocation = _firstLocation;
  }
  double computeZoomByRadius(double radius, double latitude, double longitude){
    const double earthCircumferenceKm = 40075.0;
    final double latitudeCorrection = cos(latitude * pi / 180);
    final double viewportWidthPixels = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width / WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    final double pixelsPerKm = viewportWidthPixels / (2 * radius);

    final double zoomLevel = log(earthCircumferenceKm * latitudeCorrection * pixelsPerKm / 110)/log(2);
    debugPrint("zoom_level $zoomLevel pre clamp");
    return zoomLevel.clamp(1.0, 18.0); // FlutterMap zoom range is 1-18
  }
  void refreshSearchByTap(MapCamera position) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final LatLng center = position.center;
      final double zoom = position.zoom;
      //final double radius = (position.visibleBounds.north - center.latitude) * 111.32 < minRadius ? minRadius : (position.visibleBounds.north - center.latitude) * 111.32;
      final double radius = const Distance().as(LengthUnit.Kilometer, center, position.visibleBounds.northEast);
      debugPrint("RELAZIONE MAPPA RAGGIO: $radius ZOOM: $zoom ");
      _radiusInKm = radius.clamp(minRadius, maxRadius);
      if(position.visibleBounds.north > (_lastLocation.latitude + (_radiusInKm / 111.32)) ||
          position.visibleBounds.south < (_lastLocation.latitude - (_radiusInKm / 111.32)) ||
          position.visibleBounds.east > (_lastLocation.longitude + (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180)))) ||
          position.visibleBounds.west < (_lastLocation.longitude - (_radiusInKm / (111.32 * cos(_lastLocation.latitude * pi / 180))))){

        debugPrint('REFRESH START BY TAP');
        _lastLocation = position.center;
        await _tournamentsSubscription?.cancel();
        String query = getQuery();
        _tournamentsSubscription = TournamentsRecord.getDocuments(pb, false, query).listen((tournamentsWithCreatorsList) {
          tournamentsListRefObj = tournamentsWithCreatorsList;
          tournamentsListRefObjToDetail = updateObjsToDetail();
          notifyListeners();
          debugPrint('REFRESH END BY TAP');
        });
      } else {
        tournamentsListRefObjToDetail = updateObjsToDetail();
        notifyListeners();
      }
    });
  }
  Future<void> refreshSearchByFilter(String? nameToFilter, Map<String, String?>? placeIdToFilter, double? sliderToFilter, List<Game>? gamesToFilter, List<DateTime>? dataRangeToFilter, bool addOnlineToo) async {
    if((nameToFilter == null || nameToFilter.isEmpty || nameToFilter == _name) &&
        (placeIdToFilter == null || placeIdToFilter["placeId"] == null || placeIdToFilter["lastSelected"] == null || placeIdToFilter["lastSelected"] == _place["lastSelected"]) &&
        (sliderToFilter == null || sliderToFilter == _radiusInKm) &&
        (gamesToFilter == null || containsSameGames(gamesToFilter,_games)) &&
        (addOnlineToo == _addOnlineToo) &&
        (dataRangeToFilter == null || (dataRangeToFilter[0] == _dateStart && dataRangeToFilter[1] == _dateEnd))){
      return;
    }

    debugPrint('REFRESH START BY FILTER');
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
    if(nameToFilter != null){
      _name = nameToFilter;
    }
    _addOnlineToo = addOnlineToo;
    
    if(placeIdToFilter != null && placeIdToFilter["placeId"] != null){
      try {
        if(placeIdToFilter["lastSelected"] != null){
          _place["placeId"] = placeIdToFilter["placeId"]!;
          _place["lastSelected"] = placeIdToFilter["lastSelected"]!;
        }
        PlacesApiManagerService placesApiManagerServiceCompleted = await placesApiManagerService;
        Map<String,dynamic>? placeDetail = await placesApiManagerServiceCompleted.getPlaceDetail(placeIdToFilter["placeId"]!);
        if(placeDetail != null) {
          LatLng selectedPos = LatLng(placeDetail['lat'], placeDetail['lng'],);
          double zoomLevel = computeZoomByRadius(_radiusInKm, placeDetail['lat'], placeDetail['lng']);
          mapController.move(selectedPos, zoomLevel);
          mapController.rotate(0);
        }
      } catch (e){
        debugPrint('[TournamentFinderModel] Error in refreshSearchByFilter: $e');
      }
    } else {
      double zoomLevel = computeZoomByRadius(_radiusInKm, _mapController.camera.center.latitude,_mapController.camera.center.longitude);
      mapController.move(_mapController.camera.center, zoomLevel);
      mapController.rotate(0);
    }
    await _tournamentsSubscription?.cancel();
    var query = getQuery();
    _tournamentsSubscription = TournamentsRecord.getDocuments(pb, false, query).listen((tournamentsWithCreatorsList) {
      tournamentsListRefObj = tournamentsWithCreatorsList;
      tournamentsListRefObjToDetail = updateObjsToDetail();
      debugPrint('REFRESH END BY FILTER');
      notifyListeners();
    });
    // show loading end
  }
  AlertFormRequest showChangeTournamentFinderSettingsAlertRequest() {
    AlertFormRequest req = AlertFormRequest(
      title: 'Filtra la ricerca del Torneo',
      description: "Modifica i parametri per affinare la ricerca del tuo torneo.",
      buttonTitleCancelled: "Annulla",
      buttonTitleConfirmed: "Filtra",
      formInfo: [
        () async => TextFormElement(
          controllerInitValue: _name,
          iconPrefix: Icons.style,
          validatorFunction: tournamentNameTextControllerValidator,
          validatorParameter: null,
          label: "Nome Torneo",
          key: GlobalKey<TextFormElementState>(),
        ),
        () async => TextAheadAddressFormElement(
          controllerInitValue: _place,
          iconPrefix: Icons.place,
          validatorFunction: _tournamentCenterPlaceTextControllerValidator,
          label: "Area di ricerca",
          callHintFunc: (String? text) => callAddressHint(text),
          key: GlobalKey<TextAheadAddressFormElementState>(),
        ),
        () async => SliderFormElement(
          label: "Raggio (in km) di ricerca",
          sliderValue: _radiusInKm,
          min: minRadius,
          max: maxRadius,
          divisions: 150,
          valueLabel: (value) => value.toStringAsFixed(0),
          key: GlobalKey<SliderFormElementState>(),
        ),
        () async => DropdownFormElement<Game>(
          label: "Formati di interesse",
          value: null,
          items: Game.values.where((game) => game.desc.isNotEmpty).toList(),
          selectedItems: _games,
          nameExtractor: (Game item) => item.desc,
          key: GlobalKey<DropdownFormElementState>(),
        ),
        () async => CalendarPickerFormElement(
          from: _dateStart,
          to: _dateEnd,
          label: "Date di ricerca",
          key: GlobalKey<CalendarPickerFormElementState>(),
        ),
        () async => SwitchFormElement(
          label: "Includi tornei online",
          value: _addOnlineToo,
          key: GlobalKey<SwitchFormElementState>(),
        ),
      ],
      functionConfirmed: (List<dynamic>? formValues) async {
        try {
          String? nameToFilter = (formValues![0] as String);
          Map<String, String?>? placeIdToFilter = (formValues[1] as Map<String, String?>);
          double? sliderToFilter = (formValues[2] as double);
          List<Game>? gamesToFilter = (formValues[3]! as List<Game>);
          List<DateTime>? dataRangeToFilter = (formValues[4]!.whereType<DateTime>().toList() as List<DateTime>);
          bool addOnlineToo = (formValues[5] as bool?) ?? false;
          await refreshSearchByFilter(nameToFilter, placeIdToFilter, sliderToFilter, gamesToFilter, dataRangeToFilter, addOnlineToo);
        } catch (e){
          debugPrint('[TournamentFinderModel] Error in showChangeTournamentFinderSettingsAlertRequest: $e');
        }
      },
    );
    return req;
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
  ClusterGradientData buildClusterGradient(List<Marker> markers) {
    final Map<Game, double> percentageMap = markers.map((m) => (m as CustomMarker).game).fold(
      {},
      (map, game) => map..update(
        game,
        (count) => count + 1,
        ifAbsent: () => 1,
      ),
    );
    final List<Color> colors = [];
    final List<double> stops = [];
    double cursor = 0.0;
    final int total = markers.length;
    final entries = percentageMap.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      final Game game = entries[i].key;
      final double sliceSize = entries[i].value / total;
      final bool isLast = i == entries.length - 1;

      // Start of this colour band
      colors.add(game.color);
      stops.add(cursor);
      // End of this colour band
      final double end = isLast ? 1.0 : cursor + sliceSize;
      colors.add(game.color);
      stops.add(end);
      cursor = end;
    }

    assert(
      colors.length == stops.length,
      'buildClusterGradient: length mismatch — '
      'colors=${colors.length}, stops=${stops.length}',
    );

    return ClusterGradientData(colors: colors, stops: stops);
  }


  @override
  void dispose() {
    _tournamentsSubscription?.cancel();
    _mapController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> fetchObjects() async {
    await setLocation();
    var query = getQuery(useFirst: true);
    _tournamentsSubscription = TournamentsRecord.getDocuments(pb, false, query).listen((tournamentsWithCreatorsList) {
      tournamentsListRefObj = tournamentsWithCreatorsList;
      //tournamentsListRefObjToDetail = updateObjsToDetail();
      isLoading = false;
      notifyListeners();
    });
  }

  Future<List> callAddressHint(String? text) async {
    if(text != null && text.isNotEmpty) {
      debugPrint("[PLACES-API] CALL");
      PlacesApiManagerService placesApiManagerServiceCompleted = await placesApiManagerService;
      _placeList = await placesApiManagerServiceCompleted.getSuggestion(text, _sessionToken);
    }
    return _placeList;
  }

  String getQuery({bool useFirst = false}) {
    debugPrint("[LOAD FROM FIREBASE IN CORSO] tournament_finder_model.dart");
    double currentLat;
    double currentLong;
    if(useFirst){
      currentLat = _firstLocation.latitude;
      currentLong = _firstLocation.longitude;
    } else {
      currentLat = mapController.camera.center.latitude;
      currentLong = mapController.camera.center.longitude;
    }
    // 1. Build the base query
    String query = 'state = "${StateTournament.ready.name}" && '
      'date <= "$_dateEnd" && date >= "$_dateStart" && '
      '(${_games.map((g) => g.name).map((el) => "game = \'$el\'").join(" || ")})';

    // 2. Append optional name filter
    if (_name.isNotEmpty) {
      query = '$query && name ~ "$_name"';
    }

    // 3. Build location filter once (reused in both branches)
    final double latDelta = _radiusInKm / 111.32;
    final double lonDelta = _radiusInKm / (111.32 * cos(currentLat * pi / 180));

    final String locationFilter =
        '(isOnline = false && '
        'latitude >= "${currentLat - latDelta}" && '
        'latitude <= "${currentLat + latDelta}" && '
        'longitude >= "${currentLong - lonDelta}" && '
        'longitude <= "${currentLong + lonDelta}")';

    // 4. Append online/location filter
    final String onlineFilter = _addOnlineToo
        ? '(isOnline = true || $locationFilter)'
        : locationFilter;

    query = '$query && $onlineFilter';
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
