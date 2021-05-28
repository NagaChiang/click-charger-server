import 'package:json_annotation/json_annotation.dart';

part 'one_time_product_notification.g.dart';

@JsonSerializable()
class OneTimeProductNotification {
  late final String version;
  late final OneTimeNotificationType notificationType;
  late final String purchaseToken;
  late final String sku;

  OneTimeProductNotification({
    required this.version,
    required this.notificationType,
    required this.purchaseToken,
    required this.sku,
  });

  factory OneTimeProductNotification.fromJson(Map<String, dynamic> json) =>
      _$OneTimeProductNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$OneTimeProductNotificationToJson(this);
}

enum OneTimeNotificationType {
  invalid,
  purchased,
  canceled,
}
