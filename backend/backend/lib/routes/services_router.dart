import 'dart:convert';
import 'package:backend/repositories/services_repo.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ServicesRouter {
  final ServicesRepository repo = ServicesRepository();

  Router get router {
    final router = Router();

    router.get('/', (Request req) async {
      final services = await repo.getAll();
      return Response.ok(
        jsonEncode(services),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/<id|[0-9]+>', (Request req, String id) async {
      final service = await repo.getById(int.parse(id));
      if (service == null) {
        return Response.notFound(jsonEncode({'error': 'Service not found'}));
      }
      return Response.ok(
        jsonEncode(service),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (!body.containsKey('name') ||
          !body.containsKey('price') ||
          !body.containsKey('description')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required fields'}),
        );
      }

      final service = await repo.create(
        name: body['name'],
        price: (body['price'] as num).toDouble(),
        description: body['description'],
      );
      return Response.ok(
        jsonEncode(service),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.put('/<id|[0-9]+>', (Request req, String id) async {
      final body = jsonDecode(await req.readAsString());

      final updated = await repo.update(
        id: int.parse(id),
        name: body['name'],
        price: body['price'] == null
            ? null
            : (body['price'] as num).toDouble(),
        description: body['description'],
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Service not found'}));
      }
      return Response.ok(
        jsonEncode(updated),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/<id|[0-9]+>', (Request req, String id) async {
      final deleted = await repo.delete(int.parse(id));

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Service not found'}));
      }

      return Response.ok(
        jsonEncode({'status': 'deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
