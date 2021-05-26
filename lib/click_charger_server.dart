import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

class ClickChargerServer {
  late final Router _router;
  late final Cascade _cascade;
  late final Handler _pipeline;

  ClickChargerServer() {
    _router = Router()..post('/iap', _iapHandler);
    _cascade = Cascade().add(_router);
    _pipeline =
        Pipeline().addMiddleware(logRequests()).addHandler(_cascade.handler);
  }

  Future<void> serve(address, int port) async {
    await shelf_io.serve(_pipeline, address, port);
  }

  Future<Response> _iapHandler(Request request) async {
    final body = await request.readAsString();
    print(body);

    return Response.ok(DateTime.now().toUtc().toIso8601String());
  }
}
