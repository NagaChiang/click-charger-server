import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

Future main(List<String> arguments) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final router = Router()..post('/iap', _iapHandler);
  final cascade = Cascade().add(router);
  final pipeline =
      Pipeline().addMiddleware(logRequests()).addHandler(cascade.handler);
  final server = await serve(
    pipeline,
    InternetAddress.anyIPv4,
    port,
  );
}

Future<Response> _iapHandler(Request request) async {
  final body = await request.readAsString();
  print(body);

  return Response.ok(DateTime.now().toUtc().toIso8601String());
}
