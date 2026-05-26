import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class CardsApiManagerService {
  CardsApiManagerService(){
    assert(() {
      debugPrint("[SERVICE CONSTRUCTOR] Cardsapimanagerservice");
      return true;
    }());
  }

  Future<dynamic> getCardInfo(int idCard) async{
    dynamic cardInfo;
    try{
      String baseURL = 'https://db.ygoprodeck.com/api/v7/cardinfo.php';
      String request = '$baseURL?id=$idCard';
      var response = await http.get(Uri.parse(request));
      // ignore: unused_local_variable
      var data = json.decode(response.body);
      if (response.statusCode == 200) {
        cardInfo = json.decode(response.body)['data'];
      } else {
        throw Exception('Failed to load card info');
      }
    } catch(e){
      print(e);
      throw Exception('Failed to load card info');
    }
    return cardInfo;
  }
}