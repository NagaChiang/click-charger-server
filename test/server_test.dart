import 'dart:convert';
import 'dart:io';

import 'package:click_charger_server/models/data/product_data.dart';
import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/click_charger_server.dart';
import 'package:click_charger_server/models/firestore/transactions_collection.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';
import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';
import 'package:click_charger_server/models/RTDN/test_notification.dart';
import 'package:click_charger_server/models/RTDN/one_time_product_notification.dart';

void main() {
  const rtdnApiName = 'rtdn';
  const verifyApiName = 'verify';

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

  group('/$rtdnApiName', () {
    test('Bad Request', () async {
      final url = Uri.parse('$baseUrl/$rtdnApiName');
      final response = await http.post(url);

      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('Test Notification', () async {
      final url = Uri.parse('$baseUrl/$rtdnApiName');
      final notification = RealtimeDeveloperNotification(
        version: '1.0',
        packageName: 'com.timespawn.clickCharger',
        eventTimeMillis: DateTime.now().millisecondsSinceEpoch,
        testNotification: TestNotification(version: '1.0'),
      );
      final data =
          base64.encode(utf8.encode(json.encode(notification.toJson())));
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

    test('One-time Product Notification', () async {
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
      final data =
          base64.encode(utf8.encode(json.encode(notification.toJson())));
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
      expect(transaction, isNotNull);

      // Clean up
      expect(await transactionsCollection.delete(purchaseToken), isTrue);

      // Test
      expect(transaction!.purchaseToken, purchaseToken);
      expect(transaction.timestampInMillis, timestampInMillis);
      expect(transaction.productId, productId);
      expect(transaction.consumedTime, isNull);
    });
  });

  group('/$verifyApiName', () {
    test('Bad Request', () async {
      final url = Uri.parse('$baseUrl/$verifyApiName');
      final response = await http.post(url);

      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('Transaction Not Found', () async {
      const uid = 'UID';
      const purchaseToken = 'PURCHASE_TOKEN_NOT_EXIST';

      final url = Uri.parse('$baseUrl/$verifyApiName');
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'purchaseToken': purchaseToken,
        }),
      );

      expect(response.statusCode, HttpStatus.notFound);
    });

    test('Transaction Already Consumed', () async {
      const uid = 'UID';
      const purchaseToken = 'PURCHASE_TOKEN';

      // Prepare
      final transaction = await transactionsCollection.create(
        Transaction(
          purchaseToken: purchaseToken,
          timestampInMillis: DateTime.now().millisecondsSinceEpoch,
          productId: 'PRODUCT_ID',
          consumedTime: DateTime.now(),
        ),
      );

      expect(transaction, isNotNull);

      // Test
      final url = Uri.parse('$baseUrl/$verifyApiName');
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'purchaseToken': purchaseToken,
        }),
      );

      // Clean up
      expect(await transactionsCollection.delete(purchaseToken), isTrue);

      // Test
      expect(response.statusCode, HttpStatus.conflict);
    });

    test('User Not Found', () async {
      const uid = 'UID_NOT_EXIST';
      const purchaseToken = 'PURCHASE_TOKEN';

      // Prepare
      final transaction = await transactionsCollection.create(
        Transaction(
          purchaseToken: purchaseToken,
          timestampInMillis: DateTime.now().millisecondsSinceEpoch,
          productId: 'PRODUCT_ID',
        ),
      );

      expect(transaction, isNotNull);

      // Test
      final url = Uri.parse('$baseUrl/$verifyApiName');
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'purchaseToken': purchaseToken,
        }),
      );

      // Clean up
      expect(await transactionsCollection.delete(purchaseToken), isTrue);

      // Test
      expect(response.statusCode, HttpStatus.notFound);
    });

    group('Product ID', () {
      void testProductId(String productId) {
        test(productId, () async {
          const uid = 'UID';
          const purchaseToken = 'PURCHASE_TOKEN';

          // Prepare
          final transaction = await transactionsCollection.create(
            Transaction(
              purchaseToken: purchaseToken,
              timestampInMillis: DateTime.now().millisecondsSinceEpoch,
              productId: productId,
            ),
          );

          expect(transaction, isNotNull);
          expect(usersCollection.createDummyUser(uid), isNotNull);

          // Test
          final url = Uri.parse('$baseUrl/$verifyApiName');
          final response = await http.post(
            url,
            body: json.encode({
              'uid': uid,
              'purchaseToken': purchaseToken,
            }),
          );

          final updatedUser = await usersCollection.readRaw(uid);
          expect(updatedUser, isNotNull);

          // Clean up
          expect(await transactionsCollection.delete(purchaseToken), isTrue);
          expect(await usersCollection.delete(uid), isTrue);

          // Test
          expect(response.statusCode, HttpStatus.ok);

          final productBoostCount = await productData.getBoostCount(productId);
          final resultBoostCount = json.decode(response.body)['result'];
          expect(resultBoostCount, productBoostCount);
          expect(
            updatedUser['fields']['boostCount']['integerValue'],
            productBoostCount.toString(),
          );
        });
      }

      testProductId('boost_pack_1');
      testProductId('boost_pack_3');
    });
  });
}
