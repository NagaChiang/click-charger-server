// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPurchase _$ProductPurchaseFromJson(Map<String, dynamic> json) {
  return ProductPurchase(
    kind: json['kind'] as String,
    purchaseTimeMillis: json['purchaseTimeMillis'] as String,
    purchaseState: json['purchaseState'] as int,
    consumptionState: json['consumptionState'] as int,
    developerPayload: json['developerPayload'] as String,
    orderId: json['orderId'] as String,
    purchaseType: json['purchaseType'] as int,
    acknowledgementState: json['acknowledgementState'] as int,
    purchaseToken: json['purchaseToken'] as String? ?? '',
    productId: json['productId'] as String? ?? '',
    quantity: json['quantity'] as int? ?? 0,
    obfuscatedExternalAccountId:
        json['obfuscatedExternalAccountId'] as String? ?? '',
    obfuscatedExternalProfileId:
        json['obfuscatedExternalProfileId'] as String? ?? '',
    regionCode: json['regionCode'] as String,
  );
}

Map<String, dynamic> _$ProductPurchaseToJson(ProductPurchase instance) =>
    <String, dynamic>{
      'kind': instance.kind,
      'purchaseTimeMillis': instance.purchaseTimeMillis,
      'purchaseState': instance.purchaseState,
      'consumptionState': instance.consumptionState,
      'developerPayload': instance.developerPayload,
      'orderId': instance.orderId,
      'purchaseType': instance.purchaseType,
      'acknowledgementState': instance.acknowledgementState,
      'purchaseToken': instance.purchaseToken,
      'productId': instance.productId,
      'quantity': instance.quantity,
      'obfuscatedExternalAccountId': instance.obfuscatedExternalAccountId,
      'obfuscatedExternalProfileId': instance.obfuscatedExternalProfileId,
      'regionCode': instance.regionCode,
    };
