import 'package:flutter/cupertino.dart';

import '../../../backend/schema/tournaments_record.dart';

class TournamentDetailModel extends ChangeNotifier {

  final TournamentsRecord? tournamentsRef;

  TournamentDetailModel({required this.tournamentsRef});

  final unfocusNode = FocusNode();
  String getTournamentName(){
    return tournamentsRef != null ? tournamentsRef!.name : "UNKNOWN NAME";
  }

}