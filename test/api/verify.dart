import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/models/data/product_data.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';
import 'package:click_charger_server/models/firestore/transactions_collection.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';

import '../test_config.dart';

void verifyTest() {
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

    group('Success', () {
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

            final productBoostCount =
                await productData.getBoostCount(productId);
            final resultBoostCount = json.decode(response.body)['result'];
            expect(resultBoostCount, productBoostCount);
            expect(
              updatedUser['fields']['boostCount']['integerValue'],
              productBoostCount.toString(),
            );
            expect(
              updatedUser['fields']['isRemoveAd']['booleanValue'],
              true,
            );
          });
        }

        testProductId('boost_pack_1');
        testProductId('boost_pack_3');
      });
    });
  });
}
