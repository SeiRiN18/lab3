import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/functions_repo.dart';

class FunctionsRouter {
  final repo = FunctionsRepository();

  Router get router {
    final router = Router();

    router.get('/popular/<name>/<surname>', (
      Request req,
      String name,
      String surname,
    ) async {
      final data = await repo.getPopularService(name, surname);

      return Response.ok(
        jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/revenue/service/<id|[0-9]+>', (
      Request req,
      String id,
    ) async {
      final revenue = await repo.getServiceRevenue(int.parse(id));

      return Response.ok(
        jsonEncode({'total_revenue': revenue}),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
