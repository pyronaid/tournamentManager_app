import 'dart:convert';

import 'package:http/http.dart' as http;

class PocketbaseApiManagerService {

  static const String baseUrl = "http://195.201.90.14:8080";
  static const String registerTournamentEnrollmentAPI  = "/api/tournamentManager/enroll";
  static const String deleteTournamentEnrollmentAPI  = "/api/tournamentManager/delete";
  static const String gatherUserInfoForTournamentEnrollmentAPI  = "/api/tournamentManager/getUserInfo";
  static const String generateTournamentRoundAPI  = "/api/tournamentManager/generateRound";
  static const String deleteTournamentRoundAPI  = "/api/tournamentManager/deleteRound";
  static const String closeTournamentAPI  = "/api/tournamentManager/closeTournament";

  static const String foundKeyUserInfoResponseMap  = "found";
  static const String enrolledKeyUserInfoResponseMap  = "enrolled";
  static const String eligibleKeyUserInfoResponseMap  = "eligible";
  static const String nameKeyUserInfoResponseMap  = "name";
  static const String surnameKeyUserInfoResponseMap  = "surname";
  static const String usernameKeyUserInfoResponseMap  = "username";
  static const String listKindKeyUserInfoResponseMap  = "list_type";
  static const String notEligibilityReasonKeyUserInfoResponseMap  = "not_eligibility_reason";

  late final http.Client _client;
  static const Duration _timeout = Duration(seconds: 30);
  Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  PocketbaseApiManagerService(){
    _client = http.Client();
    print("[SERVICE CONSTRUCTOR] PocketbaseApiManagerService");
  }


  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = {..._defaultHeaders, ...?headers};

      print('GET Request: $uri');

      final response = await _client
          .get(uri, headers: requestHeaders)
          .timeout(_timeout);

      return _handleResponse(response);

    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final encodedBody = body != null ? jsonEncode(body) : null;

      print('POST Request: $uri');
      print('Body: $encodedBody');

      final response = await _client
          .post(uri, headers: requestHeaders, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = {..._defaultHeaders, ...?headers};
      final encodedBody = body != null ? jsonEncode(body) : null;

      print('PUT Request: $uri');

      final response = await _client
          .put(uri, headers: requestHeaders, body: encodedBody)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }


  Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final uri = _buildUri(endpoint, queryParameters);
      final requestHeaders = {..._defaultHeaders, ...?headers};

      print('DELETE Request: $uri');

      final response = await _client
          .delete(uri, headers: requestHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Uri _buildUri(String endpoint, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('$baseUrl$endpoint');

    if (queryParameters != null && queryParameters.isNotEmpty) {
      return uri.replace(queryParameters: queryParameters.map(
            (key, value) => MapEntry(key, value.toString()),
      ));
    }

    return uri;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }

      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw HttpException('Failed to parse response JSON: $e');
      }
    } else {
      String errorMessage = 'HTTP Error ${response.statusCode}';

      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['message'] ?? errorMessage;
      } catch (e) {
        errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }

      throw HttpException(errorMessage, statusCode: response.statusCode, title: response.reasonPhrase);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is HttpException) {
      return error;
    } else if (error is http.ClientException) {
      return HttpException('Network error: ${error.message}');
    } else {
      return HttpException('Unexpected error: $error');
    }
  }

  // Method to add authorization token
  void setAuthToken(String token) {
    _defaultHeaders['Authorization'] = 'Bearer $token';
  }

  // Method to remove authorization token
  void removeAuthToken() {
    _defaultHeaders.remove('Authorization');
  }
}


class HttpException implements Exception {
  final String message;
  final String? title;
  final int? statusCode;

  HttpException(this.message, {this.statusCode, this.title});

  @override
  String toString() => 'HttpException: $message - $title (Status: $statusCode)';
}