import 'dart:convert';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PlacesApiManagerService {
  final HttpsCallable callablePlaceApiKey = FirebaseFunctions.instance.httpsCallable('getApiKeyFromSecret');
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
  String get placeApiKey => _placeApiKey;
  Future<List<dynamic>> getSuggestion(String input, String sessionToken) async {
    List<dynamic> placeList = [];
    try{
      String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request = '$baseURL?input=$input&key=$placeApiKey&language=it&sessiontoken=$sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        placeList = json.decode(response.body)['predictions'];
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch(e){
      print(e);
    }
    return placeList;
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
  void launchMap(double lat, double long) async {
    try{
      late final Uri url;
      //IOS
      final urlIos = Uri.parse('maps:$lat,$long?q=$lat,$long');
      //Android
      const String markerLabel = 'Here';
      final urlAndroid = Uri.parse('geo:$lat,$long?q=$lat,$long($markerLabel)');
      //WEB
      final urlWeb = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$long');
      //check SO and define url
      if (Platform.isIOS) {
        url = urlIos;
      } else if (Platform.isAndroid) {
        url = urlAndroid;
      } else {
        url = urlWeb;
      }
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (error) {
      print("App for map not available");
    }
  }

}