import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:http/http.dart' as http;

import 'package:click_charger_server/models/firestore/users_collection.dart';
import 'package:click_charger_server/constants.dart';

import '../configs.dart';
import '../enums.dart';

void rewardedAdTest() {
  final url = Uri.parse('$baseUrl/$rewardedAdApiName');

  group('/$rewardedAdApiName', () {
    test('Bad Request', () async {
      final response = await http.post(url);
      expect(response.statusCode, HttpStatus.badRequest);
    });

    group('NextRewardedAdTime', () {
      void testOk(TestTimeType nextAdTimeType) {
        test(nextAdTimeType, () async {
          const uid = 'UID';
          const adTimeShiftDuration = Duration(hours: 1);
          final shouldBoostEndTime = DateTime.now().add(durationPerBoost);

          // Prepare
          DateTime? nextAdTime;
          DateTime shouldNextAdTime;
          switch (nextAdTimeType) {
            case TestTimeType.noField:
              shouldNextAdTime = DateTime.now().add(rewardedAdCooldown);
              break;
            case TestTimeType.before:
              nextAdTime = DateTime.now().subtract(adTimeShiftDuration);
              shouldNextAdTime = DateTime.now().add(rewardedAdCooldown);
              break;
            case TestTimeType.after:
              nextAdTime = DateTime.now().add(adTimeShiftDuration);
              shouldNextAdTime = nextAdTime;
              break;
          }

          Map<String, dynamic>? doc;
          if (nextAdTime != null) {
            final timestamp = nextAdTime.toUtc().toIso8601String();
            doc = {
              'fields': {
                'nextRewardedAdTime': {'timestampValue': timestamp}
              },
            };
          }

          expect(
            await usersCollection.create(uid, document: doc),
            isNotNull,
          );

          // Request
          final response = await http.post(
            url,
            body: json.encode({
              'uid': uid,
            }),
          );

          final newNextAdTime =
              await usersCollection.getNextRewardedAdTime(uid);
          expect(newNextAdTime, isNotNull);

          final newBoostEndTime = await usersCollection.getBoostEndTime(uid);
          expect(newBoostEndTime, isNotNull);

          // Clean up
          expect(await usersCollection.delete(uid), isTrue);

          // Test
          if (nextAdTimeType == TestTimeType.after) {
            expect(response.statusCode, HttpStatus.conflict);
          } else {
            expect(response.statusCode, HttpStatus.ok);

            expect(
              newNextAdTime!.difference(shouldNextAdTime).abs(),
              lessThan(Duration(seconds: 5)),
            );
            expect(
              newBoostEndTime!.difference(shouldBoostEndTime).abs(),
              lessThan(Duration(seconds: 5)),
            );

            final bodyJson = json.decode(response.body);
            final resNextRewardedAdTime =
                DateTime.parse(bodyJson['nextRewardedAdTime']);
            final resBoostEndTime = DateTime.parse(bodyJson['boostEndTime']);
            expect(
              resNextRewardedAdTime.difference(shouldNextAdTime).abs(),
              lessThan(Duration(seconds: 5)),
            );
            expect(
              resBoostEndTime.difference(shouldBoostEndTime).abs(),
              lessThan(Duration(seconds: 5)),
            );
          }
        });
      }

      testOk(TestTimeType.noField);
      testOk(TestTimeType.before);
      testOk(TestTimeType.after);
    });
  });
}
