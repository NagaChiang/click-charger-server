import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:click_charger_server/config.dart';

final firestoreApi = FirestoreApi();

class FirestoreApi {
  static const serviceAccountPath = 'firebase-service-account.json';
  static const scopes = ['https://www.googleapis.com/auth/datastore'];
  static const baseUrl = 'firestore.googleapis.com';

  static String get uriBasePath =>
      'v1/projects/${Config.firebaseProjectId}/databases/(default)/documents';
  static String get documentBasePath =>
      'projects/${Config.firebaseProjectId}/databases/(default)/documents';

  static String? _accessToken;

  static Future<String> _getAccessToken() async {
    _accessToken ??= await Config.getAccessToken(serviceAccountPath, scopes);

    return _accessToken!;
  }

  Future<dynamic> create(
    String collectionId,
    String? documentId,
    dynamic document,
  ) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https(
      '$baseUrl',
      '$uriBasePath/$collectionId',
      documentId != null ? {'documentId': documentId} : null,
    );

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
        body: json.encode(document ?? {}),
      );
    } catch (error) {
      print(error);
      return null;
    }

    print('Firestore API: POST $uri (${response.statusCode})');

    if (response.statusCode != HttpStatus.ok) {
      print(response.body);
      return null;
    }

    return json.decode(response.body);
  }

  Future<dynamic> read(String collectionId, String documentId) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https('$baseUrl', '$uriBasePath/$collectionId/$documentId');

    http.Response response;
    try {
      response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      print(error);
      return null;
    }

    print('Firestore API: GET $uri (${response.statusCode})');

    if (response.statusCode != HttpStatus.ok) {
      print(response.body);
      return null;
    }

    return json.decode(response.body);
  }

  Future<dynamic> update(
    String collectionId,
    String documentId,
    Iterable<String> updateMask,
    dynamic document,
  ) async {
    final accessToken = await _getAccessToken();
    final uri =
        Uri.https('$baseUrl', '$uriBasePath/$collectionId/$documentId', {
      'currentDocument.exists': 'true',
      'updateMask.fieldPaths': updateMask,
    });

    http.Response response;
    try {
      response = await http.patch(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
        body: json.encode(document),
      );
    } catch (error) {
      print(error);
      return null;
    }

    print('Firestore API: PATCH $uri (${response.statusCode})');

    if (response.statusCode != HttpStatus.ok) {
      print(response.body);
      return null;
    }

    return json.decode(response.body);
  }

  Future<bool> delete(String collectionId, String documentId) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.https('$baseUrl', '$uriBasePath/$collectionId/$documentId');

    http.Response response;
    try {
      response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      print(error);
      return false;
    }

    print('Firestore API: DELETE $uri (${response.statusCode})');

    if (response.statusCode != HttpStatus.ok) {
      print(response.body);
      return false;
    }

    return true;
  }

  Future<int?> add(
    String collectionId,
    String documentId,
    String fieldPath,
    int amount,
  ) async {
    final accessToken = await _getAccessToken();

    Uri uri;
    http.Response response;
    try {
      // Begin transaction
      uri = Uri.https('$baseUrl', '$uriBasePath:beginTransaction');
      response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      print('Firestore API: POST $uri (${response.statusCode})');
      if (response.statusCode != HttpStatus.ok) {
        print(response.body);
        return null;
      }

      final transactionId = json.decode(response.body)['transaction'];

      // Commit
      uri = Uri.https('$baseUrl', '$uriBasePath:commit');
      response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
        body: json.encode({
          'transaction': transactionId,
          'writes': [
            {
              'currentDocument': {'exists': true},
              'transform': {
                'document': '$documentBasePath/$collectionId/$documentId',
                'fieldTransforms': [
                  {
                    'fieldPath': fieldPath,
                    'increment': {'integerValue': amount.toString()}
                  }
                ],
              },
            }
          ],
        }),
      );

      print('Firestore API: POST $uri (${response.statusCode})');
      if (response.statusCode != HttpStatus.ok) {
        print(response.body);
        return null;
      }

      final resultValue = int.parse(json.decode(response.body)['writeResults']
          [0]['transformResults'][0]['integerValue']);
      return resultValue;
    } catch (error) {
      print(error);
      return null;
    }
  }
}
