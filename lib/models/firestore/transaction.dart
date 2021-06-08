class Transaction {
  final String purchaseToken;
  final int timestampInMillis;
  final String productId;

  const Transaction({
    required this.purchaseToken,
    required this.timestampInMillis,
    required this.productId,
  });

  factory Transaction.fromDocument(dynamic document) {
    final purchaseToken = (document['name'] as String).split('/').last;
    final productId = document['fields']['productId']['stringValue'] as String;
    final timestamp = document['fields']['timestamp']['timestampValue'];
    final timestampInMillis = DateTime.parse(timestamp).millisecondsSinceEpoch;

    return Transaction(
      purchaseToken: purchaseToken,
      timestampInMillis: timestampInMillis,
      productId: productId,
    );
  }

  dynamic toDocument() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      timestampInMillis,
      isUtc: true,
    );

    return {
      'fields': {
        'timestamp': {'timestampValue': dateTime.toIso8601String()},
        'productId': {'stringValue': productId},
      },
    };
  }

  @override
  String toString() {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestampInMillis);
    return '${dateTime.toUtc()} $productId $purchaseToken';
  }
}
