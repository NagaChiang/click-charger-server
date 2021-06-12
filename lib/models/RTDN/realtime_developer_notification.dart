import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:click_charger_server/models/RTDN/one_time_product_notification.dart';
import 'package:click_charger_server/models/RTDN/subscription_notification.dart';
import 'package:click_charger_server/models/RTDN/test_notification.dart';

part 'realtime_developer_notification.g.dart';

@JsonSerializable()
class RealtimeDeveloperNotification {
  late final String version;
  late final String packageName;

  @JsonKey(fromJson: timeFromJson, toJson: timeToJson)
  late final int eventTimeMillis;

  late final OneTimeProductNotification? oneTimeProductNotification;
  late final SubscriptionNotification? subscriptionNotification;
  late final TestNotification? testNotification;

  static int timeFromJson(String value) => int.parse(value);
  static String timeToJson(int value) => value.toString();

  RealtimeDeveloperNotification({
    required this.version,
    required this.packageName,
    required this.eventTimeMillis,
    this.oneTimeProductNotification,
    this.subscriptionNotification,
    this.testNotification,
  });

  factory RealtimeDeveloperNotification.base64(String data) {
    final jsonString = utf8.decode(base64.decode(data));
    return RealtimeDeveloperNotification.fromJson(json.decode(jsonString));
  }

  factory RealtimeDeveloperNotification.fromJson(Map<String, dynamic> json) =>
      _$RealtimeDeveloperNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$RealtimeDeveloperNotificationToJson(this);
}
