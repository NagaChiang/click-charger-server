class BoostLog {
  final String uid;
  final int oldCount;
  final int newCount;
  final DateTime oldEndTime;
  final DateTime newEndTime;

  const BoostLog({
    required this.uid,
    required this.oldCount,
    required this.newCount,
    required this.oldEndTime,
    required this.newEndTime,
  });

  dynamic toDocument() {
    final oldTimestamp = oldEndTime.toUtc().toIso8601String();
    final newTimestamp = newEndTime.toUtc().toIso8601String();

    return {
      'fields': {
        'uid': {'stringValue': uid},
        'oldCount': {'integerValue': oldCount.toString()},
        'newCount': {'integerValue': newCount.toString()},
        'oldEndTime': {'timestampValue': oldTimestamp},
        'newEndTime': {'timestampValue': newTimestamp},
      },
    };
  }
}
