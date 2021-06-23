import 'package:test/test.dart';

import 'package:click_charger_server/click_charger_server.dart';

import 'api/rewarded_ad.dart';
import 'api/rtdn.dart';
import 'api/use_boost.dart';
import 'api/verify.dart';
import 'configs.dart';

void main() {
  late ClickChargerServer server;

  setUp(() {
    server = ClickChargerServer();
    server.serve(internetAddress, port);
  });

  tearDown(() async {
    return await server.close(force: true);
  });

  rtdnTest();
  verifyTest();
  useBoostTest();
  rewardedAdTest();
}
