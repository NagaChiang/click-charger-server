// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_developer_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RealtimeDeveloperNotification _$RealtimeDeveloperNotificationFromJson(
    Map<String, dynamic> json) {
  return RealtimeDeveloperNotification(
    version: json['version'] as String,
    packageName: json['packageName'] as String,
    eventTimeMillis: json['eventTimeMillis'] as int,
    oneTimeProductNotification: json['oneTimeProductNotification'] == null
        ? null
        : OneTimeProductNotification.fromJson(
            json['oneTimeProductNotification'] as Map<String, dynamic>),
    subscriptionNotification: json['subscriptionNotification'] == null
        ? null
        : SubscriptionNotification.fromJson(
            json['subscriptionNotification'] as Map<String, dynamic>),
    testNotification: json['testNotification'] == null
        ? null
        : TestNotification.fromJson(
            json['testNotification'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$RealtimeDeveloperNotificationToJson(
        RealtimeDeveloperNotification instance) =>
    <String, dynamic>{
      'version': instance.version,
      'packageName': instance.packageName,
      'eventTimeMillis': instance.eventTimeMillis,
      'oneTimeProductNotification': instance.oneTimeProductNotification,
      'subscriptionNotification': instance.subscriptionNotification,
      'testNotification': instance.testNotification,
    };
