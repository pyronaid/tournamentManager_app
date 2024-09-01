import 'package:flutter/cupertino.dart';

import '../../../backend/schema/news_record.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentNewsModel extends ChangeNotifier {

  final TournamentsRecord? tournamentsRef;

  final unfocusNode = FocusNode();


  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel({required this.tournamentsRef}){
  }

  /////////////////////////////GETTER
  List<NewsRecord> get tournamentNews{
    return tournamentsRef != null ? tournamentsRef!.newsList : [];
  }

  /////////////////////////////SETTER


  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

}