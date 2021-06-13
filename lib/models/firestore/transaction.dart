class Transaction {
  final String purchaseToken;
  final int timestampInMillis;
  final String productId;
  final DateTime? consumedTime;

  const Transaction({
    required this.purchaseToken,
    required this.timestampInMillis,
    required this.productId,
    this.consumedTime,
  });

  factory Transaction.fromDocument(dynamic document) {
    final purchaseToken = (document['name'] as String).split('/').last;
    final productId = document['fields']['productId']['stringValue'] as String;

    final timestamp = document['fields']['timestamp']['timestampValue'];
    final timestampInMillis = DateTime.parse(timestamp).millisecondsSinceEpoch;

    final consumedTimestamp =
        document['fields']['consumedTime']?['timestampValue'];
    final consumedTime =
        consumedTimestamp != null ? DateTime.parse(consumedTimestamp) : null;

    return Transaction(
      purchaseToken: purchaseToken,
      timestampInMillis: timestampInMillis,
      productId: productId,
      consumedTime: consumedTime,
    );
  }

  dynamic toDocument() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestampInMillis,
      isUtc: true,
    );

    var document = {
      'fields': {
        'timestamp': {'timestampValue': dateTime.toIso8601String()},
        'productId': {'stringValue': productId},
      },
    };

    if (consumedTime != null) {
      document['fields']!['consumedTime'] = {
        'timestampValue': consumedTime!.toUtc().toIso8601String(),
      };
    }

    return document;
  }

  @override
  String toString() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInMillis);
    return '${dateTime.toUtc()} $productId $purchaseToken';
  }
}
