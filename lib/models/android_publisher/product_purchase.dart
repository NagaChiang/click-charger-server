import 'package:json_annotation/json_annotation.dart';

part 'product_purchase.g.dart';

@JsonSerializable()
class ProductPurchase {
  @JsonKey(defaultValue: '')
  final String kind;

  @JsonKey(defaultValue: '')
  final String purchaseTimeMillis;

  @JsonKey(defaultValue: 2)
  final int purchaseState;

  @JsonKey(defaultValue: 1)
  final int consumptionState;

  @JsonKey(defaultValue: '')
  final String developerPayload;

  @JsonKey(defaultValue: '')
  final String orderId;

  @JsonKey(defaultValue: 0)
  final int purchaseType;

  @JsonKey(defaultValue: 0)
  final int acknowledgementState;

  @JsonKey(defaultValue: '')
  final String purchaseToken;

  @JsonKey(defaultValue: '')
  final String productId;

  @JsonKey(defaultValue: 0)
  final int quantity;

  @JsonKey(defaultValue: '')
  final String obfuscatedExternalAccountId;

  @JsonKey(defaultValue: '')
  final String obfuscatedExternalProfileId;

  @JsonKey(defaultValue: '')
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
