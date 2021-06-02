import 'dart:convert';
import 'dart:io';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/config.dart';

final firebaseApi = FirestoreApi();

class FirestoreApi {
  static const baseUrl = 'firestore.googleapis.com';
  static String get basePath =>
      'v1/projects/${Config.firebaseProjectId}/databases/(default)/documents';

  final String serviceAccountFilePath;

  String? _accessToken;

  FirestoreApi({this.serviceAccountFilePath = 'service-account.json'});

  Future<dynamic> create(
    String collectionId,
    String documentId,
    dynamic document,
  ) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https(
      '$baseUrl',
      '$basePath/$collectionId',
      {'documentId': documentId},
    );

    http.Response? response;
    try {
      response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
        body: json.encode(document),
      );
    } catch (error) {
      print(error);
    }

    print('Firestore API: POST $uri (${response?.statusCode})');

    return response != null ? json.decode(response.body) : null;
  }

  Future<dynamic> read(String collectionId, String documentId) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https('$baseUrl', '$basePath/$collectionId/$documentId');

    http.Response? response;
    try {
      response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      print(error);
    }

    print('Firestore API: GET $uri (${response?.statusCode})');

    return response != null ? json.decode(response.body) : null;
  }

  Future<dynamic> update(
    String collectionId,
    String documentId,
    Iterable<String> updateMask,
    dynamic document,
  ) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https('$baseUrl', '$basePath/$collectionId/$documentId', {
      'currentDocument.exists': 'true',
      'updateMask.fieldPaths': updateMask,
    });

    http.Response? response;
    try {
      response = await http.patch(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
        body: json.encode(document),
      );
    } catch (error) {
      print(error);
    }

    print('Firestore API: PATCH $uri (${response?.statusCode})');

    return response != null ? json.decode(response.body) : null;
  }

  Future<void> delete(String collectionId, String documentId) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https('$baseUrl', '$basePath/$collectionId/$documentId');

    http.Response? response;
    try {
      response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      print(error);
    }

    print('Firestore API: DELETE $uri (${response?.statusCode})');
  }

  Future<String> _getAccessToken() async {
    if (_accessToken == null) {
      final jsonString = await File(serviceAccountFilePath).readAsString();
      final serviceAccountCredential =
          ServiceAccountCredentials.fromJson(json.decode(jsonString));
      final scopes = [
        'https://www.googleapis.com/auth/datastore',
      ];

      print('Authenticating via service account...');
      final client = http.Client();
      final accessCredential = await obtainAccessCredentialsViaServiceAccount(
        serviceAccountCredential,
        scopes,
        client,
      );

      _accessToken = accessCredential.accessToken.data;
    }

    return _accessToken!;
  }
}
