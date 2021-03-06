import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/constants.dart';
import 'package:click_charger_server/models/data/product_data.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';
import 'package:click_charger_server/models/firestore/transactions_collection.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';

import '../configs.dart';

void verifyTest() {
  final url = Uri.parse('$baseUrl/$verifyApiName');

  group('/$verifyApiName', () {
    test('Bad Request', () async {
      final response = await http.post(url);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('Transaction Not Found', () async {
      const uid = 'UID';
      const productId = 'boost';
      const purchaseToken = 'PURCHASE_TOKEN_NOT_EXIST';

      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'productId': productId,
          'purchaseToken': purchaseToken,
        }),
      );

      expect(response.statusCode, HttpStatus.notFound);
    });

    test('Transaction Already Consumed', () async {
      const uid = 'UID';
      const productId = 'boost';
      const purchaseToken = 'PURCHASE_TOKEN';

      // Prepare
      final transaction = await transactionsCollection.create(
        Transaction(
          uid: uid,
          purchaseToken: purchaseToken,
          timestampInMillis: DateTime.now().millisecondsSinceEpoch,
          productId: productId,
          consumedTime: DateTime.now(),
        ),
      );

      expect(transaction, isNotNull);

      // Request
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'productId': productId,
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
      const productId = 'boost';
      const purchaseToken = 'PURCHASE_TOKEN';

      // Prepare
      final transaction = await transactionsCollection.create(
        Transaction(
          uid: null,
          purchaseToken: purchaseToken,
          timestampInMillis: DateTime.now().millisecondsSinceEpoch,
          productId: productId,
        ),
      );

      expect(transaction, isNotNull);

      // Request
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'productId': productId,
          'purchaseToken': purchaseToken,
        }),
      );

      // Clean up
      expect(await transactionsCollection.delete(purchaseToken), isTrue);

      // Test
      expect(response.statusCode, HttpStatus.notFound);
    });

    group('Ok', () {
      group('Product ID', () {
        void testProductId(
          String productId,
          String purchaseToken,
          bool transactionHasUid,
        ) {
          test('$productId, $purchaseToken', () async {
            const uid = 'UID';

            // Prepare
            final transaction = await transactionsCollection.create(
              Transaction(
                uid: transactionHasUid ? uid : null,
                purchaseToken: purchaseToken,
                timestampInMillis: DateTime.now().millisecondsSinceEpoch,
                productId: productId,
              ),
            );

            expect(transaction, isNotNull);
            expect(await usersCollection.create(uid), isNotNull);

            // Request
            final response = await http.post(
              url,
              body: json.encode({
                'uid': uid,
                'productId': productId,
                'purchaseToken': purchaseToken,
              }),
            );

            final updatedUser = await usersCollection.readRaw(uid);
            expect(updatedUser, isNotNull);

            final updatedTran =
                await transactionsCollection.read(purchaseToken);
            expect(updatedTran, isNotNull);

            // Clean up
            expect(await usersCollection.delete(uid), isTrue);
            expect(await transactionsCollection.delete(purchaseToken), isTrue);

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

            expect(updatedTran!.uid, uid);
            expect(updatedTran.consumedTime, isNotNull);
          });
        }

        testProductId(
          'boost',
          'kjncgbcjodopionbkompfeii.AO-J1OzgFRza65BESKM1Eu8Sy_V0nBBkZqVGjGyJcm3ccmhdnEObnDu2cfYfEifDBzMYnZkGKIRGiyH8zzzvDz7_V9TVwH4w9CI6mvVUDz0u5ej8BL2Vju0',
          false,
        );

        testProductId('boost_pack_3', 'PURCHASE_TOKEN', true);
      });
    });
  });
}
