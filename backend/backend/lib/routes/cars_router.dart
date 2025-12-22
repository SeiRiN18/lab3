import 'dart:convert';
import 'package:backend/repositories/cars_repo.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class CarsRouter {
  final CarsRepository repo = CarsRepository();

  Router get router {
    final router = Router();

    router.get('/', (Request req) async {
      final cars = await repo.getAll();
      return Response.ok(
        jsonEncode(cars),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/<id|[0-9]+>', (Request req, String id) async {
      final car = await repo.getById(int.parse(id));
      if (car == null) {
        return Response.notFound(jsonEncode({'error': 'Car not found'}));
      }
      return Response.ok(
        jsonEncode(car),

        headers: {'Content-Type': 'application/json'},
      );
    });

    router.post('/', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (!body.containsKey('brand') ||
          !body.containsKey('model') ||
          !body.containsKey('client_id')) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Missing required fields'}),
        );
      }

      final car = await repo.create(
        brand: body['brand'],
        model: body['model'],
        year: body['year'],
        vinCode: body['vin_code'],
        clientId: body['client_id'],
      );
      return Response.ok(
        jsonEncode(car),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.put('/<id|[0-9]+>', (Request req, String id) async {
      final body = jsonDecode(await req.readAsString());

      final updated = await repo.update(
        id: int.parse(id),
        brand: body['brand'],
        model: body['model'],
        year: body['year'],
        vinCode: body['vin_code'],
        clientId: body['client_id'],
      );

      if (updated == null) {
        return Response.notFound(jsonEncode({'error': 'Car not found'}));
      }
      return Response.ok(
        jsonEncode(updated),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.delete('/<id|[0-9]+>', (Request req, String id) async {
      final deleted = await repo.delete(int.parse(id));

      if (!deleted) {
        return Response.notFound(jsonEncode({'error': 'Car not found'}));
      }

      return Response.ok(
        jsonEncode({'status': 'deleted'}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
