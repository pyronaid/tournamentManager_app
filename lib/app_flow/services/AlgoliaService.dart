import 'package:algoliasearch/algoliasearch.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../backend/schema/tournaments_record.dart';

class AlgoliaService {
  final HttpsCallable callableAlgoliaApiKey = FirebaseFunctions.instance.httpsCallable('getAlgoliaApiKeyFromSecret');
  final HttpsCallable callableAlgoliaApiWKey = FirebaseFunctions.instance.httpsCallable('getAlgoliaApiWKeyFromSecret');
  static const String indexPeople = "users_index";
  static const String indexRegisteredPeople = "registered_list_info_index";
  static const String indexPreregisteredPeople = "preregistered_list_info_index";
  static const String indexWaitingPeople = "waiting_list_info_index";
  static const List<String> indexResearchableAttributes = ['display_name'];
  late final String _algoliaApiKey;
  late final SearchClient searchClient;
  late final SearchClient writeClient;

  AlgoliaService(){
    print("[SERVICE CONSTRUCTOR] AlgoliaService");
  }

  Future<void> initialize() async {
    try {
      final result = await callableAlgoliaApiKey();
      _algoliaApiKey = result.data['apiKey'];
      searchClient = SearchClient(
        appId: '5A6XSKACXW',
        apiKey: _algoliaApiKey,
      );
      final resultW = await callableAlgoliaApiWKey();
      writeClient = SearchClient(
        appId: '5A6XSKACXW',
        apiKey: resultW.data['apiKey'],
      );
    } catch (e) {
      print('Error retrieving secret: $e');
      throw Exception('Failed to get Algolia API key');
    }
  }

  //////////////////////////GETTER
  Future<SearchResponse?> searchPeople({
    required String query,
    required ListType listType,
    int hitsPerPage = 10,
    int page = 0,
    String filters = '',
  }) async {
    try {
      String indexName = indexRegisteredPeople;

      switch(listType){
        case ListType.registered:
          indexName = indexRegisteredPeople;
          break;
        case ListType.preregistered:
          indexName = indexPreregisteredPeople;
          break;
        case ListType.waiting:
          indexName = indexWaitingPeople;
          break;
      }

      var searchRequest = SearchForHits(
        indexName: indexName,
        query: query,
        hitsPerPage: hitsPerPage,
        page: page,
        restrictSearchableAttributes: indexResearchableAttributes,
        filters: filters,
      );
      return await searchClient.searchIndex(request: searchRequest);
    } catch (e) {
      print('Algolia Search Error: $e');
    }
    return null;
  }

  Future<UpdatedAtWithObjectIdResponse?> saveOrUpdatePersonToIndex({
    required String objectID,
    required Map<String, dynamic> data,
    required ListType listType
  }) async {
    try {
      String indexName = indexRegisteredPeople;

      switch (listType) {
        case ListType.registered:
          indexName = indexRegisteredPeople;
          break;
        case ListType.preregistered:
          indexName = indexPreregisteredPeople;
          break;
        case ListType.waiting:
          indexName = indexWaitingPeople;
          break;
      }
      UpdatedAtWithObjectIdResponse resp = await writeClient.addOrUpdateObject(indexName: indexName, objectID: objectID, body: data);
      return resp;
    } catch (e) {
      print('Algolia Save Error: $e');
      return null;
    }
  }
  Future<DeletedAtResponse?> deletePersonToIndex({
    required String objectID,
    required ListType listType
  }) async {
    try {
      String indexName = indexRegisteredPeople;

      switch (listType) {
        case ListType.registered:
          indexName = indexRegisteredPeople;
          break;
        case ListType.preregistered:
          indexName = indexPreregisteredPeople;
          break;
        case ListType.waiting:
          indexName = indexWaitingPeople;
          break;
      }
      DeletedAtResponse resp = await writeClient.deleteObject(indexName: indexName, objectID: objectID);
      return resp;
    } catch (e) {
      print('Algolia Save Error: $e');
      return null;
    }
  }
}