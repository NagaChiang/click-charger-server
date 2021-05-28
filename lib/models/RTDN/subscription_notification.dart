import 'package:json_annotation/json_annotation.dart';

part 'subscription_notification.g.dart';

@JsonSerializable()
class SubscriptionNotification {
  late final String version;
  late final int notificationType;
  late final String purchaseToken;
  late final String subscriptionId;

  SubscriptionNotification({
    required this.version,
    required this.notificationType,
    required this.purchaseToken,
    required this.subscriptionId,
  });

  factory SubscriptionNotification.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionNotificationToJson(this);
}
