import 'package:click_charger_server/models/databases/firestore_api.dart';
import 'package:click_charger_server/models/databases/transaction.dart';

final transactionsCollection = TransactionsCollection();

class TransactionsCollection {
  static const collectionId = 'transactions';

  Future<void> create(Transaction transaction) async {
    await firebaseApi.create(
      collectionId,
      transaction.purchaseToken,
      transaction.toDocument(),
    );
  }

  Future<Transaction> read(String purchaseToken) async {
    final document = await firebaseApi.read(collectionId, purchaseToken);
    return Transaction.fromDocument(document);
  }

  Future<void> delete(String purchaseToken) async {
    await firebaseApi.delete(collectionId, purchaseToken);
  }
}
