import 'package:json_annotation/json_annotation.dart';

part 'product_purchase.g.dart';

@JsonSerializable()
class ProductPurchase {
  final String kind;
  final String purchaseTimeMillis;
  final int purchaseState;
  final int consumptionState;
  final String developerPayload;
  final String orderId;
  final int purchaseType;
  final int acknowledgementState;
  final String purchaseToken;
  final String productId;
  final int quantity;
  final String obfuscatedExternalAccountId;
  final String obfuscatedExternalProfileId;
  final String regionCode;

  bool get isPurchased => purchaseState == 0;

  const ProductPurchase({
    required this.kind,
    required this.purchaseTimeMillis,
    required this.purchaseState,
    required this.consumptionState,
    required this.developerPayload,
    required this.orderId,
    required this.purchaseType,
    required this.acknowledgementState,
    required this.purchaseToken,
    required this.productId,
    required this.quantity,
    required this.obfuscatedExternalAccountId,
    required this.obfuscatedExternalProfileId,
    required this.regionCode,
  });

  factory ProductPurchase.fromJson(Map<String, dynamic> json) =>
      _$ProductPurchaseFromJson(json);
  Map<String, dynamic> toJson() => _$ProductPurchaseToJson(this);
}
