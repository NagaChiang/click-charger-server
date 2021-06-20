import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:click_charger_server/config.dart';
import 'package:click_charger_server/models/android_publisher/product_purchase.dart';

final publisherApi = PublisherApi();

class PublisherApi {
  static const serviceAccountPath =
      'google-play-developer-service-account.json';
  static const scopes = ['https://www.googleapis.com/auth/androidpublisher'];
  static const baseUrl =
      'https://androidpublisher.googleapis.com/androidpublisher/v3';

  static String? _accessToken;

  static Future<String> _getAccessToken() async {
    _accessToken ??= await Config.getAccessToken(serviceAccountPath, scopes);

    return _accessToken!;
  }

  Future<ProductPurchase?> get(
    String packageName,
    String productId,
    String token,
  ) async {
    final accessToken = await _getAccessToken();
    final uri = Uri.parse(
      '$baseUrl/applications/$packageName/purchases/products/$productId/tokens/$token',
    );

    http.Response response;
    try {
      response = await http.post(
        uri,
        headers: {'Authorization': 'Bearer $accessToken'},
      );
    } catch (error) {
      print(error);
      return null;
    }

    print('Android Publisher API: GET $uri (${response.statusCode})');

    if (response.statusCode != HttpStatus.ok) {
      print(response.body);
      return null;
    }

    return ProductPurchase.fromJson(json.decode(response.body));
  }
}
