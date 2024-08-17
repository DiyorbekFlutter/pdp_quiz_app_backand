import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_cors_headers/shelf_cors_headers.dart';

import 'services/router_service.dart';
import 'setup.dart';

import 'web_socked/web_socked_handler.dart';


Future<void> main() async {
  await SetUp().init();

  /// HttpServer
  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(RouterService().router);

  final HttpServer server = await shelf_io.serve(handler, "0.0.0.0", 8080);
  print("Server running on localhost: ${server.port}");
  

  /// WebSocked
  final serverWebSocked = HttpServer.bind(InternetAddress.anyIPv4, 4040);
  serverWebSocked.then((HttpServer httpServer) {
    print("WebSocket server is running on ws://${httpServer.address.address}:${httpServer.port}");
    httpServer.listen((HttpRequest request) {
      if (request.uri.path == '/ws') {
        WebSockedHandler().handleWebSocket(request);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      }
    });
  });
}



// import 'dart:io';
// import 'package:shelf/shelf.dart';
// import 'package:shelf/shelf_io.dart';
//
// import 'services/router_service.dart';
// import 'setup.dart';
//
// void main() async {
//   await SetUp().init();
//   final InternetAddress ip = InternetAddress.anyIPv4;
//   final handler = Pipeline().addMiddleware(logRequests()).addHandler(RouterService().router);
//   final int port = int.parse(Platform.environment['PORT'] ?? '8080');
//   final HttpServer server = await serve(handler, ip, port);
//
//   print('Server listening on port ${server.port}');
// }
