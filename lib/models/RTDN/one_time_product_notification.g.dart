// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'one_time_product_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OneTimeProductNotification _$OneTimeProductNotificationFromJson(
    Map<String, dynamic> json) {
  return OneTimeProductNotification(
    version: json['version'] as String,
    notificationType: _$enumDecode(
        _$OneTimeNotificationTypeEnumMap, json['notificationType']),
    purchaseToken: json['purchaseToken'] as String,
    sku: json['sku'] as String,
  );
}

Map<String, dynamic> _$OneTimeProductNotificationToJson(
        OneTimeProductNotification instance) =>
    <String, dynamic>{
      'version': instance.version,
      'notificationType':
          _$OneTimeNotificationTypeEnumMap[instance.notificationType],
      'purchaseToken': instance.purchaseToken,
      'sku': instance.sku,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$OneTimeNotificationTypeEnumMap = {
  OneTimeNotificationType.invalid: 'invalid',
  OneTimeNotificationType.purchased: 'purchased',
  OneTimeNotificationType.canceled: 'canceled',
};
