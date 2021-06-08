import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:click_charger_server/models/data/product_data.dart';
import 'package:click_charger_server/models/databases/transaction.dart';
import 'package:click_charger_server/models/databases/transactions_collection.dart';
import 'package:click_charger_server/models/databases/users_collection.dart';
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

      print('[One-time product notification] ${transaction.toString()}');

      await transactionsCollection.create(transaction);
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

    final transaction = await transactionsCollection.read(purchaseToken);
    if (transaction == null) {
      return Response.notFound('Transaction not found.');
    }

    final boostCount = await productData.getBoostCount(transaction.productId);
    final addResult = await usersCollection.addBoostCount(uid, boostCount);
    if (!addResult) {
      return Response.notFound('User not found.');
    }

    return Response.ok(null);
  }
}
