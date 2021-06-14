// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_time_product_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OneTimeProductNotification _$OneTimeProductNotificationFromJson(
    Map<String, dynamic> json) {
  return OneTimeProductNotification(
    version: json['version'] as String,
    notificationType: OneTimeProductNotification.typeFromJson(
        json['notificationType'] as int),
    purchaseToken: json['purchaseToken'] as String,
    sku: json['sku'] as String,
  );
}

Map<String, dynamic> _$OneTimeProductNotificationToJson(
        OneTimeProductNotification instance) =>
    <String, dynamic>{
      'version': instance.version,
      'notificationType':
          OneTimeProductNotification.typeToJson(instance.notificationType),
      'purchaseToken': instance.purchaseToken,
      'sku': instance.sku,
    };
