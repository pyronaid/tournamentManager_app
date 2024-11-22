import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

class ExternalAppManagerService {

  ExternalAppManagerService(){
    print("[SERVICE CONSTRUCTOR] ExternalAppManagerService");
  }

  //////////////////////////GETTER
  void launchMapApp(double lat, double long, String label) async {
    try{
      late final Uri url;
      //IOS
      final urlIos = Uri.parse('maps:$lat,$long?q=$lat,$long');
      //Android
      String markerLabel = label;
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