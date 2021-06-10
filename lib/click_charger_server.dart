import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

import 'package:click_charger_server/controllers/iap_controller.dart';

class ClickChargerServer {
  late final HttpServer _server;
  late final Router _router;
  late final Cascade _cascade;
  late final Handler _pipeline;

  ClickChargerServer() {
    dotenv.load();

    _router = Router()
      ..post('/rtdn', iapController.rtdn)
      ..post('/verify', iapController.verify);
    _cascade = Cascade().add(_router);
    _pipeline =
        Pipeline().addMiddleware(logRequests()).addHandler(_cascade.handler);
  }

  Future<void> serve(address, int port) async {
    _server = await shelf_io.serve(_pipeline, address, port);
  }

  Future<void> close({bool force = false}) async {
    await _server.close(force: force);
  }
}
