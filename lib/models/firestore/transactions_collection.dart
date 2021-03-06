import 'package:click_charger_server/models/firestore/firestore_api.dart';
import 'package:click_charger_server/models/firestore/transaction.dart';

final transactionsCollection = TransactionsCollection();

class TransactionsCollection {
  static const _collectionId = 'transactions';

  Future<Transaction?> create(Transaction transaction) async {
    final document = await firestoreApi.create(
      _collectionId,
      transaction.purchaseToken,
      transaction.toDocument(),
    );

    return document != null ? Transaction.fromDocument(document) : null;
  }

  Future<Transaction?> read(String purchaseToken) async {
    final document = await firestoreApi.read(_collectionId, purchaseToken);
    return document != null ? Transaction.fromDocument(document) : null;
  }

  Future<bool> delete(String purchaseToken) async {
    return await firestoreApi.delete(_collectionId, purchaseToken);
  }

  Future<bool> consumePendingTransaction(
    String uid,
    String purchaseToken,
  ) async {
    final timestamp = DateTime.now().toUtc().toIso8601String();
    final document = await firestoreApi.update(
      _collectionId,
      purchaseToken,
      [
        'uid',
        'consumedTime',
      ],
      {
        'fields': {
          'uid': {'stringValue': uid},
          'consumedTime': {'timestampValue': timestamp}
        },
      },
    );

    return document != null;
  }
}
