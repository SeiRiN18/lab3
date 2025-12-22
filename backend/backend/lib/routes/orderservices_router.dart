import 'dart:convert';

import 'package:backend/repositories/orderservices_repo.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class OrderServicesRouter {
  final OrderServicesRepository repo = OrderServicesRepository();

  Router get router {
    final router = Router();

    router.get('/', (Request req) async {
      final orderservices = await repo.getAll();
      return Response.ok(
        jsonEncode(orderservices),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/<id|[0-9]+>', (Request req, String id) async {
      final orderservice = await repo.getById(int.parse(id));

      if (orderservice == null) {
        return Response.notFound(
          jsonEncode({'error': 'Orderservice not found'}),
        );
      }
      return Response.ok(
        jsonEncode(orderservice),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/order/<id|[0-9]+>', (Request req, String id) async {
      final orderservice = await repo.getByOrder(int.parse(id));

      return Response.ok(
        jsonEncode(orderservice),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/service/<id|[0-9]+>', (Request req, String id) async {
      final orderservice = await repo.getByService(int.parse(id));

      return Response.ok(
        jsonEncode(orderservice),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (!body.containsKey('order_id') ||
          !body.containsKey('service_id') ||
          !body.containsKey('quantity')) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Required fields: order_id, service_id, quantity',
          }),
        );
      }

      try {
        final created = await repo.create(
          orderId: body['order_id'],
          serviceId: body['service_id'],
          quantity: body['quantity'],
        );

        return Response.ok(
          jsonEncode(created),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    router.put('/<id|[0-9]+>', (Request req, String id) async {
      final body = jsonDecode(await req.readAsString());

      final updated = await repo.update(
        id: int.parse(id),
        quantity: body['quantity'],
      );

      if (updated == null) {
        return Response.notFound(
          jsonEncode({'error': 'OrderService not found'}),
        );
      }

      return Response.ok(
        jsonEncode(updated),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/<id|[0-9]+>', (Request req, String id) async {
      final deleted = await repo.delete(int.parse(id));

      if (!deleted) {
        return Response.notFound(
          jsonEncode({'error': 'OrderService not found'}),
        );
      }

      return Response.ok(
        jsonEncode({'status': 'deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
