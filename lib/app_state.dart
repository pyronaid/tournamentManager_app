import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tournamentmanager/auth/pocketbase_auth/pocketbase_auth_util.dart';
import 'package:tournamentmanager/backend/schema/enrollments_record.dart';

class CustomAppState extends ChangeNotifier {
  static CustomAppState _instance = CustomAppState._internal();

  StreamSubscription<List<EnrollmentsRecord>>? _enrollmentListSubscription;

  late List<String>? tournamentsListRefObj;

  bool _isLoading = true;

  factory CustomAppState() {
    return _instance;
  }

  CustomAppState._internal(){
    debugPrint("[CREATE] CustomAppState");
  }

  static void reset() {
    _instance = CustomAppState._internal();
  }

  /////////////////////////////GETTER
  bool get isLoading => _isLoading;

  @override
  void dispose() {
    debugPrint("[DISPOSE] CustomAppState");
    _enrollmentListSubscription?.cancel(); // Cancel the tournament subscription
    super.dispose();
  }


  void fetchObjectUsingId() {
    if(currentUserEmail.isNotEmpty){
      debugPrint("[LOAD FROM POCKETBASE IN CORSO] app_state.dart");
      _enrollmentListSubscription = EnrollmentsRecord.getDocuments(pb, false, "${EnrollmentsRecord.idUserFieldName} = $currentUserUid").listen((snapshot) async {
        try {
          tournamentsListRefObj = (await EnrollmentsRecord.getDocumentsOnce(pb, false, "${EnrollmentsRecord.idUserFieldName} = $currentUserUid")).item2.map((elem) => elem.userId).toList();
          _isLoading = false;
        } catch (e){
          debugPrint("Errore nella subscription dello Stream Tournament");
        }
      });
    } else{
      tournamentsListRefObj = null;
      _isLoading = false;
    }
  }

}
