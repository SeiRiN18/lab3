import 'package:backend/db/connection.dart';

class OrdersRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query('''
      SELECT * FROM orders ORDER BY order_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      ''' 
        SELECT * FROM orders WHERE order_id = @id; 
    ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> create({
    DateTime? orderDate,
    String? status,
    required int workerId,
    required int carId,
  }) async {
    final result = await db.query(
      ''' 
      INSERT INTO orders(order_date, status, worker_id, car_id)
      VALUES(
      COALESCE(@order_date, CURRENT_DATE),
      COALESCE(@status, 'new'),
      @worker_id,
      @car_id
      )
      RETURNING *;
    ''',
      substitutionValues: {
        'order_date': orderDate?.toIso8601String(),
        'status': status,
        'worker_id': workerId,
        'car_id': carId,
      },
    );
    if (result.isEmpty) {
      throw Exception("Order creation failed");
    }
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({
    required int id,
    DateTime? orderDate,
    String? status,
    int? workerId,
    int? carId,
  }) async {
    final result = await db.query(
      ''' 
        UPDATE orders
        SET
         order_date = COALESCE(@order_date, order_date),
        status = COALESCE(@status, status),
        worker_id = COALESCE(@worker_id, worker_id),
        car_id = COALESCE(@car_id, car_id)
      WHERE order_id = @id
      RETURNING *;
      ''',
      substitutionValues: {
        'id': id,
        'order_date': orderDate?.toIso8601String(),
        'status': status,
        'worker_id': workerId,
        'car_id': carId,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      '''
      DELETE FROM orders WHERE order_id = @id;
      ''',
      substitutionValues: {'id': id},
    );

    return result.affectedRowCount > 0;
  }

  Future<List<Map<String, dynamic>>> getByWorker(int workerId) async {
    final result = await db.query(
      '''
      SELECT * FROM orders WHERE worker_id = @worker_id;
      ''',
      substitutionValues: {'worker_id': workerId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getByCar(int carId) async {
    final result = await db.query(
      '''
      SELECT * FROM orders WHERE car_id = @car_id;
      ''',
      substitutionValues: {'car_id': carId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }
}
