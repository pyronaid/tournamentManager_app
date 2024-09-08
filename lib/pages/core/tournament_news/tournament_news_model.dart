import 'package:flutter/cupertino.dart';

import '../../../backend/schema/news_record.dart';
import '../../../backend/schema/tournaments_record.dart';

class TournamentNewsModel extends ChangeNotifier {

  final String? tournamentsRef;
  late final TournamentsRecord? tournamentsRefObj;

  final unfocusNode = FocusNode();


  /////////////////////////////CONSTRUCTOR
  TournamentNewsModel({required this.tournamentsRef}){
  }

  /////////////////////////////GETTER
  List<NewsRecord> get tournamentNews{
    return tournamentsRef != null ? tournamentsRefObj!.newsList : [];
  }
  String? get tournamentId{
    return tournamentsRefObj?.uid;
  }

  /////////////////////////////SETTER


  @override
  void dispose() {
    unfocusNode.dispose();
    super.dispose();
  }

}