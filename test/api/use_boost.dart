import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/constants.dart';
import 'package:click_charger_server/models/firestore/users_collection.dart';

import '../configs.dart';
import '../enums.dart';

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

    group('Not Enough Boost', () {
      void testNotEnoughBoost({required bool hasField}) {
        test(hasField ? 'Has Count Field' : 'No Count Field', () async {
          const uid = 'UID';

          // Prepare
          expect(
            await usersCollection.create(
              uid,
              document: hasField
                  ? {
                      'fields': {
                        'boostCount': {'integerValue': '0'},
                      },
                    }
                  : null,
            ),
            isNotNull,
          );

          // Request
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
      }

      testNotEnoughBoost(hasField: false);
      testNotEnoughBoost(hasField: true);
    });

    group('Enough Boost', () {
      void testEnoughBoost(int useCount, TestTimeType currentEndTimeType) {
        test('$useCount, $currentEndTimeType', () async {
          const uid = 'UID';
          const endTimeShiftDuration = Duration(days: 1);
          final boostDuration = durationPerBoost * useCount;

          // Prepare
          DateTime? currentEndTime;
          var shouldEndTime = DateTime.now();
          switch (currentEndTimeType) {
            case TestTimeType.noField:
              shouldEndTime = DateTime.now().add(boostDuration);
              break;
            case TestTimeType.before:
              currentEndTime = DateTime.now().subtract(endTimeShiftDuration);
              shouldEndTime = DateTime.now().add(boostDuration);
              break;
            case TestTimeType.after:
              currentEndTime = DateTime.now().add(endTimeShiftDuration);
              shouldEndTime = currentEndTime.add(boostDuration);
              break;
          }

          var document = {
            'fields': {
              'boostCount': {'integerValue': useCount.toString()},
            },
          };

          if (currentEndTime != null) {
            document['fields']!['boostEndTime'] = {
              'timestampValue': currentEndTime.toUtc().toIso8601String(),
            };
          }

          expect(
            await usersCollection.create(uid, document: document),
            isNotNull,
          );

          // Request
          final response = await http.post(
            url,
            body: json.encode({
              'uid': uid,
              'count': useCount,
            }),
          );

          final newCount = await usersCollection.getBoostCount(uid);
          expect(newCount, isNotNull);

          final newEndTime = await usersCollection.getBoostEndTime(uid);
          expect(newEndTime, isNotNull);

          // Clean up
          expect(await usersCollection.delete(uid), isTrue);

          // Test
          expect(response.statusCode, HttpStatus.ok);
          expect(newCount, 0);
          expect(
            newEndTime!.difference(shouldEndTime).abs(),
            lessThan(Duration(seconds: 5)),
          );
        });
      }

      testEnoughBoost(1, TestTimeType.noField);
      testEnoughBoost(2, TestTimeType.before);
      testEnoughBoost(3, TestTimeType.after);
    });
  });
}
