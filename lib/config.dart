import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class Config {
  static String get firebaseProjectId => env['firebaseProjectId'] ?? '';

  static Future<String> getAccessToken(
    String serviceAccountPath,
    List<String> scopes,
  ) async {
    final jsonString = await File(serviceAccountPath).readAsString();
    final serviceAccountCredential = ServiceAccountCredentials.fromJson(
      json.decode(jsonString),
    );

    print('Authenticating via service account "$serviceAccountPath"...');
    final client = http.Client();
    final accessCredential = await obtainAccessCredentialsViaServiceAccount(
      serviceAccountCredential,
      scopes,
      client,
    );

    return accessCredential.accessToken.data!;
  }
}
