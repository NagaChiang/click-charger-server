import 'package:click_charger_server/models/firestore/boost_log.dart';
import 'package:click_charger_server/models/firestore/firestore_api.dart';

final boostLogsCollection = BoostLogsCollection();

class BoostLogsCollection {
  static const _collectionId = 'boostLogs';

  Future<bool> create(BoostLog log) async {
    final doc = await firestoreApi.create(
      _collectionId,
      null,
      log.toDocument(),
    );

    return doc != null;
  }
}
