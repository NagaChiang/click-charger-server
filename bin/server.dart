import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

import 'package:click_charger_server/click_charger_server.dart';

Future main(List<String> arguments) async {
  final pubspecFile = File('pubspec.yaml');
  final pubspec = Pubspec.parse(await pubspecFile.readAsString());
  final version = pubspec.version.toString();

  print('Click Charger Server v$version');

  final internetAddress = InternetAddress.anyIPv4;
  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  print('Server started: ${internetAddress.address}:$port');

  final server = ClickChargerServer();
  await server.serve(internetAddress, port);
}
