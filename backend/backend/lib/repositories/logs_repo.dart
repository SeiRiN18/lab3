import 'package:backend/db/connection.dart';

class LogsRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getOrderLogs() async {
    final result = await db.query('''
      SELECT * FROM orders_logs ORDER BY log_id DESC;
    ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getBlockedOrderLogs() async {
    final result = await db.query('''
      SELECT * FROM orders_block_logs ORDER BY log_id DESC;
    ''');
    return result.map((row) => row.toColumnMap()).toList();
  }
}
