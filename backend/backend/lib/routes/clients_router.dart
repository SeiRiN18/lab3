import 'dart:convert';

import 'package:backend/repositories/clients_repo.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ClientsRouter {
  final ClientsRepository repo = ClientsRepository();

  Router get router {
    final router = Router();

    router.get('/', (Request req) async {
      final clients = await repo.getAll();
      return Response.ok(
        jsonEncode(clients),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/<id|[0-9]+>', (Request req, String id) async {
      final client = await repo.getById(int.parse(id));
      if (client == null) {
        return Response.notFound(jsonEncode({'error': 'Client not found'}));
      }
      return Response.ok(
        jsonEncode(client),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (!body.containsKey('name') ||
          !body.containsKey('surname') ||
          !body.containsKey('phone')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required fields'}),
        );
      }

      final client = await repo.create(
        name: body['name'],
        surname: body['surname'],
        phone: body['phone'],
      );
      return Response.ok(
        jsonEncode(client),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.put('/<id|[0-9]+>', (Request req, String id) async {
      final body = jsonDecode(await req.readAsString());

      final updated = await repo.update(
        id: int.parse(id),
        name: body['name'],
        surname: body['surname'],
        phone: body['phone'],
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Client not found'}));
      }
      return Response.ok(
        jsonEncode(updated),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/<id|[0-9]+>', (Request req, String id) async {
      final deleted = await repo.delete(int.parse(id));

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Client not found'}));
      }

      return Response.ok(
        jsonEncode({'status': 'deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
