import 'package:algoliasearch/algoliasearch.dart';
import 'package:cloud_functions/cloud_functions.dart';

class AlgoliaService {
  final HttpsCallable callableAlgoliaApiKey = FirebaseFunctions.instance.httpsCallable('getAlgoliaApiKeyFromSecret');
  static const String indexPeople = "users_index";
  static const List<String> indexResearchableAttributes = ['display_name'];
  late final String _algoliaApiKey;
  late final SearchClient searchClient;

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
    } catch (e) {
      print('Error retrieving secret: $e');
      throw Exception('Failed to get Algolia API key');
    }
  }

  //////////////////////////GETTER
  String get algoliaApiKey => _algoliaApiKey;
  Future<SearchResponse?> searchPeople({
    required String query,
    int hitsPerPage = 10,
    int page = 0,
    String filters = '',
  }) async {
    try {
      var searchRequest = SearchForHits(
        indexName: AlgoliaService.indexPeople,
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

}