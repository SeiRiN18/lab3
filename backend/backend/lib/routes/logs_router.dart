import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:backend/repositories/logs_repo.dart';

class LogsRouter {
  final repo = LogsRepository();

  Router get router {
    final router = Router();
    Map<String, dynamic> jsonSafeLog(Map<String, dynamic> log) {
      final m = Map<String, dynamic>.from(log);
      if (m['time_of_attempt'] is DateTime) {
        m['time_of_attempt'] = (m['time_of_attempt'] as DateTime)
            .toIso8601String();
      }
      if (m['time_of_modify'] is DateTime) {
        m['time_of_modify'] = (m['time_of_modify'] as DateTime)
            .toIso8601String();
      }
      return m;
    }

    router.get('/orders', (Request req) async {
      final logs = await repo.getOrderLogs();
      final converted = logs.map(jsonSafeLog).toList();
      return Response.ok(
        jsonEncode(converted),
        headers: {'Content-Type': 'application/json'},
      );
    });

    router.get('/blocked', (Request req) async {
      final logs = await repo.getBlockedOrderLogs();
      final converted = logs.map(jsonSafeLog).toList();
      return Response.ok(
        jsonEncode(converted),
        headers: {'Content-Type': 'application/json'},
      );
    });

    return router;
  }
}
