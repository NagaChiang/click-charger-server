import 'package:test/test.dart';

import 'package:click_charger_server/click_charger_server.dart';

import 'api/rtdn.dart';
import 'api/verify.dart';
import 'test_config.dart';

void main() {
  late ClickChargerServer server;

  setUp(() {
    server = ClickChargerServer();
    server.serve(internetAddress, port);
  });

  tearDown(() {
    server.close(force: true);
  });

  rtdnTest();
  verifyTest();
}
