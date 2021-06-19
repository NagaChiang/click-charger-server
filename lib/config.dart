import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/constants.dart';

class Config {
  static String get firebaseProjectId => env['firebaseProjectId'] ?? '';

  static String? _accessToken;

  static Future<String> getAccessToken() async {
    if (_accessToken == null) {
      final jsonString = await File(serviceAccountFilePath).readAsString();
      final serviceAccountCredential =
          ServiceAccountCredentials.fromJson(json.decode(jsonString));
      final scopes = [
        'https://www.googleapis.com/auth/datastore',
        'https://www.googleapis.com/auth/androidpublisher',
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
