import 'package:click_charger_server/models/firestore/firestore_api.dart';

final usersCollection = UsersCollection();

class UsersCollection {
  static const _collectionId = 'users';
  static const _boostCountFieldPath = 'boostCount';
  static const _boostEndTimeFieldPath = 'boostEndTime';
  static const _isRemoveAdFieldPath = 'isRemoveAd';

  Future<int?> addBoostCount(String uid, int count) async {
    return await firestoreApi.add(
      _collectionId,
      uid,
      _boostCountFieldPath,
      count,
    );
  }

  Future<int?> getBoostCount(String uid) async {
    final data = await firestoreApi.read(_collectionId, uid);
    if (data == null) {
      return null;
    }

    final intString = data['fields']?[_boostCountFieldPath]?['integerValue'];
    return intString != null ? int.tryParse(intString) : 0;
  }

  Future<DateTime?> getBoostEndTime(String uid) async {
    final data = await firestoreApi.read(_collectionId, uid);
    if (data == null) {
      return null;
    }

    final timestamp =
        data['fields']?[_boostEndTimeFieldPath]?['timestampValue'];
    return timestamp != null ? DateTime.tryParse(timestamp) : DateTime.now();
  }

  Future<bool> updateBoostEndTime(String uid, DateTime newEndTime) async {
    final timestamp = newEndTime.toUtc().toIso8601String();
    final result = await firestoreApi.update(
      _collectionId,
      uid,
      [_boostEndTimeFieldPath],
      {
        'fields': {
          _boostEndTimeFieldPath: {'timestampValue': timestamp},
        }
      },
    );

    return result != null;
  }

  Future<bool> removeAd(String uid) async {
    final result = await firestoreApi.update(
      _collectionId,
      uid,
      [_isRemoveAdFieldPath],
      {
        'fields': {
          _isRemoveAdFieldPath: {'booleanValue': true},
        }
      },
    );

    return result != null;
  }

  Future<bool> delete(String uid) async {
    return await firestoreApi.delete(_collectionId, uid);
  }

  Future<dynamic> readRaw(String uid) async {
    return await firestoreApi.read(_collectionId, uid);
  }

  Future<dynamic> create(
    String uid, {
    Map<String, dynamic>? document,
  }) async {
    return await firestoreApi.create(_collectionId, uid, document);
  }
}
