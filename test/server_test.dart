import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/click_charger_server.dart';
import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';
import 'package:click_charger_server/models/RTDN/test_notification.dart';
import 'package:click_charger_server/models/RTDN/one_time_product_notification.dart';

void main() {
  final internetAddress = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final baseUrl = 'http://127.0.0.1:$port';

  late ClickChargerServer server;

  setUp(() {
    server = ClickChargerServer();
    server.serve(internetAddress, port);
  });

  tearDown(() {
    server.close(force: true);
  });

  test('/iap: Bad Request', () async {
    final client = HttpClient();
    final url = Uri.parse('$baseUrl/iap');
    final request = await client.postUrl(url);
    final response = await request.close();

    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('/iap: Test Notification', () async {
    final url = Uri.parse('$baseUrl/iap');
    final notification = RealtimeDeveloperNotification(
      version: '1.0',
      packageName: 'com.timespawn.clickCharger',
      eventTimeMillis: DateTime.now().millisecondsSinceEpoch,
      testNotification: TestNotification(version: '1.0'),
    );
    final data = base64.encode(utf8.encode(json.encode(notification.toJson())));
    final body = '''{
      "message": {
        "attributes": {
          "key": "value"
        },
        "data": "$data",
        "messageId": "136969346945"
      },
      "subscription": "projects/myproject/subscriptions/mysubscription"
    }''';
    final response = await http.post(url, body: body);

    expect(response.statusCode, HttpStatus.ok);
  });

  test('/iap: One-time Product Notification', () async {
    final url = Uri.parse('$baseUrl/iap');
    final notification = RealtimeDeveloperNotification(
        version: '1.0',
        packageName: 'com.timespawn.clickCharger',
        eventTimeMillis: DateTime.now().millisecondsSinceEpoch,
        oneTimeProductNotification: OneTimeProductNotification(
          version: '1.0',
          notificationType: OneTimeNotificationType.purchased,
          purchaseToken: 'PURCHASE_TOKEN',
          sku: 'PRODUCT_ID',
        ));
    final data = base64.encode(utf8.encode(json.encode(notification.toJson())));
    final body = '''{
      "message": {
        "attributes": {
          "key": "value"
        },
        "data": "$data",
        "messageId": "136969346945"
      },
      "subscription": "projects/myproject/subscriptions/mysubscription"
    }''';
    final response = await http.post(url, body: body);

    expect(response.statusCode, HttpStatus.ok);
  });
}
