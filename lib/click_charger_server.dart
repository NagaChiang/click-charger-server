import 'dart:convert';
import 'dart:io';

import 'package:click_charger_server/models/databases/transactions_collection.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:dotenv/dotenv.dart' as dotenv;

import 'package:click_charger_server/models/RTDN/realtime_developer_notification.dart';
import 'package:click_charger_server/models/databases/transaction.dart';

class ClickChargerServer {
  late final HttpServer _server;
  late final Router _router;
  late final Cascade _cascade;
  late final Handler _pipeline;

  ClickChargerServer() {
    dotenv.load();

    _router = Router()..post('/iap', _iapHandler);
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

  Future<Response> _iapHandler(Request request) async {
    final bodyString = await request.readAsString();

    var data = '';
    try {
      final bodyJson = json.decode(bodyString);
      data = bodyJson['message']['data'] as String;
    } catch (error) {
      return Response(HttpStatus.badRequest);
    }

    final notification = RealtimeDeveloperNotification.base64(data);
    if (notification.oneTimeProductNotification != null) {}

    return Response.ok(null);
  }
}
