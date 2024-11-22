import 'package:cloud_functions/cloud_functions.dart';

class AlgoliaService {
  final HttpsCallable callableAlgoliaApiKey = FirebaseFunctions.instance.httpsCallable('getSecretApiKey');
  late final String _algoliaApiKey;

  AlgoliaService(){
    print("[SERVICE CONSTRUCTOR] AlgoliaService");
  }

  Future<void> initialize() async {
    try {

    } catch (e) {
      print('Error retrieving secret: $e');
      throw Exception('Failed to get API key');
    }
  }

  //////////////////////////GETTER

}