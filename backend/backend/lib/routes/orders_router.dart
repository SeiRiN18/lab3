import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/orders_repo.dart';

class OrdersRouter {
  final OrdersRepository repo = OrdersRepository();

  Router get router {
    final router = Router();
    Map<String, dynamic> jsonSafeOrder(Map<String, dynamic> order) {
      final m = Map<String, dynamic>.from(order);
      if (m['order_date'] is DateTime) {
        m['order_date'] = (m['order_date'] as DateTime).toIso8601String();
      }
      return m;
    }

    router.get('/', (Request req) async {
      final orders = await repo.getAll();

      final converted = orders.map(jsonSafeOrder).toList();
      return Response.ok(
        jsonEncode(converted),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/<id|[0-9]+>', (Request req, String id) async {
      final order = await repo.getById(int.parse(id));
      if (order == null) {
        return Response.notFound(jsonEncode({'error': 'Order not found'}));
      }
      return Response.ok(
        jsonEncode(jsonSafeOrder(order)),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/worker/<id|[0-9]+>', (Request req, String id) async {
      final orders = await repo.getByWorker(int.parse(id));

      final jsonSafe = orders.map((o) {
        return {...o, 'order_date': o['order_date']?.toString()};
      }).toList();

      return Response.ok(
        jsonEncode(jsonSafe),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/car/<id|[0-9]+>', (Request req, String id) async {
      final orders = await repo.getByCar(int.parse(id));
      return Response.ok(
        jsonEncode(orders),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (!body.containsKey('worker_id') || !body.containsKey('car_id')) {
        return Response.badRequest(
          body: jsonEncode({
            'error': 'Missing required fields: worker_id, car_id',
          }),
        );
      }

      try {
        final order = await repo.create(
          orderDate: body['order_date'] != null
              ? DateTime.parse(body['order_date'])
              : null,
          status: body['status'],
          workerId: body['worker_id'],
          carId: body['car_id'],
        );

        return Response.ok(
          jsonEncode(jsonSafeOrder(order)),
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
        orderDate: body['order_date'] != null
            ? DateTime.parse(body['order_date'])
            : null,
        status: body['status'],
        workerId: body['worker_id'],
        carId: body['car_id'],
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Order not found'}));
      }

      return Response.ok(
        jsonEncode(jsonSafeOrder(updated)),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/<id|[0-9]+>', (Request req, String id) async {
      final deleted = await repo.delete(int.parse(id));

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Order not found'}));
      }

      return Response.ok(
        jsonEncode({'status': 'deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
