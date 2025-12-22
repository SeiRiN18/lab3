import 'package:backend/db/connection.dart';
import 'package:backend/routes/cars_router.dart';
import 'package:backend/routes/clients_router.dart';
import 'package:backend/routes/functions_router.dart';
import 'package:backend/routes/logs_router.dart';
import 'package:backend/routes/orders_router.dart';
import 'package:backend/routes/orderservices_router.dart';
import 'package:backend/routes/procedures_router.dart';
import 'package:backend/routes/services_router.dart';
import 'package:backend/routes/workers_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  await DB.connect();

  final router = Router();

  Middleware corsMiddleware = createMiddleware(
    requestHandler: (Request req) {
      if (req.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
          },
        );
      }
      return null;
    },
    responseHandler: (Response resp) => resp.change(
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
      },
    ),
  );

  router.mount('/api/workers', WorkersRouter().router.call);
  router.mount('/api/services', ServicesRouter().router.call);
  router.mount('/api/cars', CarsRouter().router.call);
  router.mount('/api/clients', ClientsRouter().router.call);
  router.mount('/api/orders', OrdersRouter().router.call);
  router.mount('/api/orderservices', OrderServicesRouter().router.call);
  router.mount('/api/procedures', ProceduresRouter().router.call);
  router.mount('/api/functions', FunctionsRouter().router.call);
  router.mount('/api/logs', LogsRouter().router.call);

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsMiddleware)
      .addHandler(router.call);

  await io.serve(handler, 'localhost', 9000);
  print("Server started");
}
