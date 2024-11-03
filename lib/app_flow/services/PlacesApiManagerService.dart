import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

class PlacesApiManagerService {
  final HttpsCallable callablePlaceApiKey = FirebaseFunctions.instance.httpsCallable('getSecretApiKey');
  late final String _placeApiKey;

  PlacesApiManagerService(){
    print("[SERVICE CONSTRUCTOR] SecretManagerService");
  }

  Future<void> initialize() async {
    try {
      final result = await callablePlaceApiKey();
      _placeApiKey = result.data['apiKey'];
    } catch (e) {
      print('Error retrieving secret: $e');
      throw Exception('Failed to get API key');
    }
  }


  //////////////////////////GETTER
  String get placeApiKey{
    return _placeApiKey;
  }
  Future<List<dynamic>> getSuggestion(String input, String sessionToken) async {
    List<dynamic> _placeList = [];
    try{
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$placeApiKey&language=it&sessiontoken=$sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        _placeList = json.decode(response.body)['predictions'];
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch(e){
      print(e);
    }
    return _placeList;
  }
  Future<Map<String, dynamic>?> getPlaceDetail(String placeId) async {
    dynamic formattedAddress;
    try {
      String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
      String request = '$baseURL?place_id=$placeId&key=$placeApiKey&language=it';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        formattedAddress = data['result']['geometry']['location'];
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch(e){
      print(e);
    }
    return formattedAddress;
  }
}