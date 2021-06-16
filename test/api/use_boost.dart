import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/constants.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';

import '../test_config.dart';

void useBoostTest() {
  final url = Uri.parse('$baseUrl/$useBoostApiName');

  group('/$useBoostApiName', () {
    test('Bad Request', () async {
      final response = await http.post(url);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('User Not Found', () async {
      const uid = 'UID_NOT_EXIST';

      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'count': 1,
        }),
      );

      expect(response.statusCode, HttpStatus.notFound);
    });

    test('Not Enough Boost', () async {
      const uid = 'UID';

      // Prepare
      expect(
        await usersCollection.create(uid, document: {
          'fields': {
            'boostCount': {'integerValue': '0'},
          },
        }),
        isNotNull,
      );

      // Test
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'count': 1,
        }),
      );

      // Clean up
      expect(await usersCollection.delete(uid), isTrue);

      // Test
      expect(response.statusCode, HttpStatus.conflict);
    });

    test('Not Enough Boost (No Field)', () async {
      const uid = 'UID';

      // Prepare
      expect(await usersCollection.create(uid), isNotNull);

      // Test
      final response = await http.post(
        url,
        body: json.encode({
          'uid': uid,
          'count': 1,
        }),
      );

      // Clean up
      expect(await usersCollection.delete(uid), isTrue);

      // Test
      expect(response.statusCode, HttpStatus.conflict);
    });

    group('Enough Boost', () {
      void testEnoughBoost(int useCount) {
        test('$useCount', () async {
          const uid = 'UID';

          // Prepare
          expect(
            await usersCollection.create(uid, document: {
              'fields': {
                'boostCount': {'integerValue': useCount.toString()},
              },
            }),
            isNotNull,
          );

          // Test
          final response = await http.post(
            url,
            body: json.encode({
              'uid': uid,
              'count': useCount,
            }),
          );

          final newCount = await usersCollection.getBoostCount(uid);
          expect(newCount, isNotNull);

          // Clean up
          expect(await usersCollection.delete(uid), isTrue);

          // Test
          expect(response.statusCode, HttpStatus.ok);
          expect(newCount, 0);
        });
      }

      testEnoughBoost(1);
      testEnoughBoost(5);
    });
  });
}
