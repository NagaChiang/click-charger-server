import 'package:json_annotation/json_annotation.dart';

part 'test_notification.g.dart';

@JsonSerializable()
class TestNotification {
  late final String version;

  TestNotification({required this.version});

  factory TestNotification.fromJson(Map<String, dynamic> json) =>
      _$TestNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$TestNotificationToJson(this);
}
