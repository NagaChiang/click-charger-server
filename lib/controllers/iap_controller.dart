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
      final message = 'Transaction "$purchaseToken" not found';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    if (transaction.consumedTime != null) {
      final message =
          'Transaction "$purchaseToken" has already been consumed at ${transaction.consumedTime!.toUtc().toIso8601String()}';
      print('[Verify] $message');

      return Response(HttpStatus.conflict, body: message);
    }

    final boostCount = await productData.getBoostCount(transaction.productId);
    final addResultValue = await usersCollection.addBoostCount(uid, boostCount);
    if (addResultValue == null) {
      final message = 'Failed to add boost count for user "$uid"';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    final removeAdResult = await usersCollection.removeAd(uid);
    if (!removeAdResult) {
      final message = 'Failed to remove ad for user "$uid"';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    return Response.ok(json.encode({'result': addResultValue}));
  }
}
