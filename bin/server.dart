import 'dart:io';

import 'package:click_charger_server/click_charger_server.dart';

Future main(List<String> arguments) async {
  final internetAddress = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  print('Server started: ${internetAddress.address}:$port');

  final server = ClickChargerServer();
  await server.serve(internetAddress, port);
}
