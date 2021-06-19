import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:click_charger_server/config.dart';
import 'package:click_charger_server/models/android_publisher/product_purchase.dart';

final publisherApi = PublisherApi();

class PublisherApi {
  static const baseUrl =
      'https://androidpublisher.googleapis.com/androidpublisher/v3';

  Future<ProductPurchase?> get(
    String packageName,
    String productId,
    String token,
  ) async {
    final accessToken = await Config.getAccessToken();
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
