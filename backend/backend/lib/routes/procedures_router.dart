import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/procedures_repo.dart';

class ProceduresRouter {
  final repo = ProceduresRepository();

  Router get router {
    final router = Router();

    router.post('/discount', (Request req) async {
      final body = jsonDecode(await req.readAsString());

      if (body['service_name'] == null || body['percent'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'service_name and percent are required'}),
        );
      }

      try {
        final result = await repo.applyDiscount(
          serviceName: body['service_name'],
          percent: body['percent'],
        );

        return Response.ok(
          jsonEncode({'message': result}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    return router;
  }
}
