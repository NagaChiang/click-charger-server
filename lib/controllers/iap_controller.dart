import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:click_charger_server/models/data/product_data.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';
import 'package:click_charger_server/models/firestore/transactions_collection.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';
import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';

final iapController = IapController();

class IapController {
  Future<Response> rtdn(Request request) async {
    RealtimeDeveloperNotification notification;
    try {
      final bodyJson = json.decode(await request.readAsString());
      final data = bodyJson['message']['data'] as String;
      notification = RealtimeDeveloperNotification.base64(data);
    } catch (error) {
      print('$error');
      return Response(HttpStatus.badRequest);
    }

    if (notification.oneTimeProductNotification != null) {
      final transaction = Transaction(
        purchaseToken: notification.oneTimeProductNotification!.purchaseToken,
        timestampInMillis: notification.eventTimeMillis,
        productId: notification.oneTimeProductNotification!.sku,
      );

      print('[One-time Product Notification] ${transaction.toString()}');

      await transactionsCollection.create(transaction);
    }

    if (notification.testNotification != null) {
      print('[Test Notification]');
    }

    return Response.ok(null);
  }

  Future<Response> verify(Request request) async {
    String uid;
    String purchaseToken;
    try {
      final bodyJson = json.decode(await request.readAsString());
      uid = bodyJson['uid'] as String;
      purchaseToken = bodyJson['purchaseToken'] as String;
    } catch (error) {
      print('$error');
      return Response(HttpStatus.badRequest);
    }

    print('[Verify] uid = $uid, purchaseToken = $purchaseToken');

    final transaction = await transactionsCollection.read(purchaseToken);
    if (transaction == null) {
      print('[Verify] Transaction not found');
      return Response.notFound('Transaction not found.');
    }

    final boostCount = await productData.getBoostCount(transaction.productId);
    final addResultValue = await usersCollection.addBoostCount(uid, boostCount);
    if (addResultValue == null) {
      print('[Verify] User not found');
      return Response.notFound('User not found.');
    }

    return Response.ok(json.encode({'result': addResultValue}));
  }
}
