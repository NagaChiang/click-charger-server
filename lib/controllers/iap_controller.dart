import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import 'package:click_charger_server/constants.dart';
import 'package:click_charger_server/config.dart';
import 'package:click_charger_server/models/android_publisher/publisher_api.dart';
import 'package:click_charger_server/models/data/product_data.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';
import 'package:click_charger_server/models/firestore/transactions_collection.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';
import 'package:click_charger_server/models/firestore/boost_log.dart';
import 'package:click_charger_server/models/firestore/boost_logs_collection.dart';
import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';

final iapController = IapController();

class IapController {
  Future<Response> rtdn(Request request) async {
    RealtimeDeveloperNotification notification;
    try {
      final bodyJson = json.decode(await request.readAsString());
      final data = bodyJson['message']['data'];
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
    String productId;
    String purchaseToken;
    try {
      final bodyJson = json.decode(await request.readAsString());
      uid = bodyJson['uid'];
      productId = bodyJson['productId'];
      purchaseToken = bodyJson['purchaseToken'];
    } catch (error) {
      print('$error');
      return Response(HttpStatus.badRequest);
    }

    print('[Verify] uid = $uid, purchaseToken = $purchaseToken');

    // Verify transaction via Google API
    final purchase = await publisherApi.get(
      packageName,
      productId,
      purchaseToken,
    );

    print(purchase?.toJson());

    // Check purchase state
    if (purchase != null && !purchase.isPurchased) {
      final message =
          'Transaction "$purchaseToken" has not been purchased (purchaseState = ${purchase.purchaseState})';
      print('[Verify] $message');

      return Response(HttpStatus.conflict, body: message);
    }

    // Get transaction from database
    final transaction = await transactionsCollection.read(purchaseToken);

    // Not found in neither source
    if (purchase == null && transaction == null) {
      final message = 'Transaction "$purchaseToken" not found';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    // Check transaction consumed or not
    if (transaction != null && transaction.consumedTime != null) {
      final message =
          'Transaction "$purchaseToken" has already been consumed at ${transaction.consumedTime!.toUtc().toIso8601String()}';
      print('[Verify] $message');

      return Response(HttpStatus.conflict, body: message);
    }

    // Add boost count for user
    final boostCount = await productData.getBoostCount(productId);
    final addResultValue = await usersCollection.addBoostCount(uid, boostCount);
    if (addResultValue == null) {
      final message = 'Failed to add boost count for user "$uid"';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    // Remove ads for user
    final removeAdResult = await usersCollection.removeAd(uid);
    if (!removeAdResult) {
      final message = 'Failed to remove ad for user "$uid"';
      print('[Verify] $message');

      return Response.notFound(message);
    }

    // Log
    if (transaction == null) {
      // Create transaction
      final doc = await transactionsCollection.create(Transaction(
        purchaseToken: purchaseToken,
        timestampInMillis: int.parse(purchase!.purchaseTimeMillis),
        productId: productId,
        consumedTime: DateTime.now(),
      ));
      if (doc == null) {
        print(
          '[Verify] Failed to create log for transaction "$purchaseToken"',
        );
      }
    } else {
      // Update transaction
      final result = await transactionsCollection.markAsConsumed(purchaseToken);
      if (!result) {
        print(
          '[Verify] Failed to mark transaction "$purchaseToken" as consumed',
        );
      }
    }

    return Response.ok(json.encode({'result': addResultValue}));
  }

  Future<Response> useBoost(Request request) async {
    String uid;
    int useCount;
    try {
      final bodyJson = json.decode(await request.readAsString());
      uid = bodyJson['uid'] as String;
      useCount = bodyJson['count'] as int;
    } catch (error) {
      print('$error');
      return Response(HttpStatus.badRequest);
    }

    print('[UseBoost] User "$uid" uses $useCount boost(s)');

    // Use count should be > 0
    if (useCount <= 0) {
      final message = 'User "$uid": use amount ($useCount) should not be <= 0';
      print('[UseBoost] $message');
      return Response(HttpStatus.badRequest, body: message);
    }

    // Get current count
    final currentCount = await usersCollection.getBoostCount(uid);
    if (currentCount == null) {
      final message = 'User "$uid" not found';
      print('[UseBoost] $message');
      return Response(HttpStatus.notFound, body: message);
    }

    // Check enough boost
    if (useCount > currentCount) {
      final message =
          'User "$uid" does not have enough boost (use: $useCount, own: $currentCount)';
      print('[UseBoost] $message');
      return Response(HttpStatus.conflict, body: message);
    }

    // Reduce boost count
    final newCount = await usersCollection.addBoostCount(uid, -useCount);
    if (newCount == null) {
      final message =
          'User "$uid" failed to use boost (use: $useCount, own: $currentCount)';
      print('[UseBoost] $message');
      return Response(HttpStatus.internalServerError, body: message);
    }

    // Update end time
    final currentEndTime =
        await usersCollection.getBoostEndTime(uid) ?? DateTime.now();
    var startTime = DateTime.now();
    if (currentEndTime.isAfter(DateTime.now())) {
      startTime = currentEndTime;
    }

    final newEndTime = startTime.add(durationPerBoost * useCount);
    final updateTimeResult =
        await usersCollection.updateBoostEndTime(uid, newEndTime);
    if (!updateTimeResult) {
      final message =
          'User "$uid" failed to update boost end time (new: $newEndTime, current: $currentEndTime)';
      print('[UseBoost] $message');

      // Recover boost count
      print('[UseBoost] Recovering boost count ($useCount)...');
      await usersCollection.addBoostCount(uid, useCount);

      return Response(HttpStatus.internalServerError, body: message);
    }

    // Log
    final boostLog = BoostLog(
      uid: uid,
      oldCount: currentCount,
      newCount: newCount,
      oldEndTime: currentEndTime,
      newEndTime: newEndTime,
    );

    final logResult = await boostLogsCollection.create(boostLog);
    if (!logResult) {
      print('[UseBoost] Failed to log for using boost');
    }

    return Response.ok(json.encode({
      'count': newCount,
      'endTime': newEndTime.toUtc().toIso8601String(),
    }));
  }
}
