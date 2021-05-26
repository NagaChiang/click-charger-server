import 'dart:io';

import 'package:click_charger_server/click_charger_server.dart';

Future main(List<String> arguments) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  print('Server started: ${InternetAddress.anyIPv4}:$port');

  final server = ClickChargerServer();
  await server.serve(InternetAddress.anyIPv4, port);
}
