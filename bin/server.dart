import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

final _router = Router()..get('/iap', _iapHandler);

Future main(List<String> arguments) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final cascade = Cascade().add(_router);
  final pipeline =
      Pipeline().addMiddleware(logRequests()).addHandler(cascade.handler);
  final server = await serve(
    pipeline,
    InternetAddress.anyIPv4,
    port,
  );
}

Response _iapHandler(Request request) {
  return Response.ok('hello!');
}
