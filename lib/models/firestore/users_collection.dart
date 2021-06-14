import 'package:click_charger_server/models/firestore/firestore_api.dart';

final usersCollection = UsersCollection();

class UsersCollection {
  static const _collectionId = 'users';
  static const _boostCountFieldPath = 'boostCount';
  static const _boostEndTimeFieldPath = 'boostEndTime';

  Future<int?> addBoostCount(String uid, int count) async {
    return await firestoreApi.add(
      _collectionId,
      uid,
      _boostCountFieldPath,
      count,
    );
  }

  Future<bool> delete(String uid) async {
    return await firestoreApi.delete(_collectionId, uid);
  }

  Future<dynamic> readRaw(String uid) async {
    return await firestoreApi.read(_collectionId, uid);
  }

  Future<dynamic> createDummyUser(String uid) async {
    return await firestoreApi.create(_collectionId, uid, {});
  }
}
