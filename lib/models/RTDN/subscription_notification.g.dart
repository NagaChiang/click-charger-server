// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionNotification _$SubscriptionNotificationFromJson(
    Map<String, dynamic> json) {
  return SubscriptionNotification(
    version: json['version'] as String,
    notificationType: json['notificationType'] as int,
    purchaseToken: json['purchaseToken'] as String,
    subscriptionId: json['subscriptionId'] as String,
  );
}

Map<String, dynamic> _$SubscriptionNotificationToJson(
        SubscriptionNotification instance) =>
    <String, dynamic>{
      'version': instance.version,
      'notificationType': instance.notificationType,
      'purchaseToken': instance.purchaseToken,
      'subscriptionId': instance.subscriptionId,
    };
