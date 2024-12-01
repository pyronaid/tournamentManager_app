
import 'dart:io';

import 'package:algoliasearch/algoliasearch.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';
import 'package:tournamentmanager/app_flow/services/AlgoliaService.dart';
import 'package:tournamentmanager/backend/schema/users_algolia_record.dart';
import 'package:tournamentmanager/pages/nav_bar/tournament_model.dart';

class PeopleListModel extends ChangeNotifier {

  final TournamentModel tournamentModel;
  late TextEditingController _peopleNameTextController;
  late FocusNode _peopleNameFocusNode;

  late Future<AlgoliaService> algoliaService;
  bool algoliaServiceIsLoading = true;
  List<dynamic> usersList = [];
  int userNum = 0;


  PeopleListModel({required this.tournamentModel}){
    print("[CREATE] PeopleListModel");
    _peopleNameTextController = TextEditingController();
    _peopleNameFocusNode = FocusNode();

    algoliaService = GetIt.instance.getAsync<AlgoliaService>();
    algoliaService.whenComplete(() {
      algoliaServiceIsLoading = false;
      notifyListeners();
      /*
      algoliaService.then((loaded){

      });*/
    });
    _peopleNameTextController.addListener(() => updateQuery(_peopleNameTextController.text));
  }



  /////////////////////////////GETTER
  bool get isLoading => tournamentModel.isLoading && algoliaServiceIsLoading;
  TextEditingController get peopleNameTextController => _peopleNameTextController;
  FocusNode get peopleNameFocusNode => _peopleNameFocusNode;


  /////////////////////////////SETTER
  Future<void> updateQuery(String textToSearch) async {
    print("[ALGOLIA-API] CALL");
    try {
      var queryHits = SearchForHits(
        indexName: AlgoliaService.indexPeople,
        query: textToSearch,
        hitsPerPage: 5,
      );
      AlgoliaService algoliaServiceCompleted = await algoliaService;
      SearchResponse responseHits = await algoliaServiceCompleted.searchClient.searchIndex(request: queryHits);
      userNum = responseHits.nbHits!;
      usersList = responseHits.hits.map((e) =>
          UsersAlgoliaRecord(displayName: e['display_name'])).toList();
      notifyListeners();
    } on AlgoliaIOException catch (e) {
      print('Algolia Connection Error: ${e.toString()}');
    } on SocketException catch (e) {
      print('Socket Connection Error: ${e.toString()}');
    } catch (e) {
      print('Unexpected Error: ${e.toString()}');
    }
  }


  @override
  void dispose() {
    _peopleNameTextController.dispose();
    _peopleNameFocusNode.dispose();
    //searchClient.dispose();
    super.dispose();
  }

}