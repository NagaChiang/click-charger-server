import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/click_charger_server.dart';
import 'package:click_charger_server/models/databases/transactions_collection.dart';
import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';
import 'package:click_charger_server/models/RTDN/test_notification.dart';
import 'package:click_charger_server/models/RTDN/one_time_product_notification.dart';

void main() {
  const rtdnApiName = 'rtdn';

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

  test('/$rtdnApiName: Bad Request', () async {
    final client = HttpClient();
    final url = Uri.parse('$baseUrl/$rtdnApiName');
    final request = await client.postUrl(url);
    final response = await request.close();

    expect(response.statusCode, HttpStatus.badRequest);
  });

  test('/$rtdnApiName: Test Notification', () async {
    final url = Uri.parse('$baseUrl/$rtdnApiName');
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

  test('/$rtdnApiName: One-time Product Notification', () async {
    const purchaseToken = 'PURCHASE_TOKEN';
    final timestampInMillis = DateTime.now().toUtc().millisecondsSinceEpoch;
    const productId = 'PRODUCT_ID';

    final url = Uri.parse('$baseUrl/$rtdnApiName');
    final notification = RealtimeDeveloperNotification(
        version: '1.0',
        packageName: 'com.timespawn.clickCharger',
        eventTimeMillis: timestampInMillis,
        oneTimeProductNotification: OneTimeProductNotification(
          version: '1.0',
          notificationType: OneTimeNotificationType.purchased,
          purchaseToken: purchaseToken,
          sku: productId,
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

    final transaction = await transactionsCollection.read(purchaseToken);
    await transactionsCollection.delete(purchaseToken);

    expect(transaction.purchaseToken, purchaseToken);
    expect(transaction.timestampInMillis, timestampInMillis);
    expect(transaction.productId, productId);
  });
}
