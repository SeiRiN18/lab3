import 'package:backend/db/connection.dart';

class OrderServicesRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query(''' 
      SELECT * FROM orderservices ORDER BY order_services_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      ''' 
      SELECT * FROM orderservices WHERE order_services_id = @id;
      ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<List<Map<String, dynamic>>> getByOrder(int orderId) async {
    final result = await db.query(
      '''
      SELECT * FROM orderservices WHERE order_id = @order_id;
      ''',
      substitutionValues: {'order_id': orderId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<List<Map<String, dynamic>>> getByService(int serviceId) async {
    final result = await db.query(
      '''
      SELECT * FROM orderservices WHERE service_id = @service_id;
      ''',
      substitutionValues: {'service_id': serviceId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>> create({
    required int orderId,
    required int serviceId,
    required int quantity,
  }) async {
    final priceResult = await db.query(
      ''' 
      SELECT price FROM services WHERE service_id = @id;
      ''',
      substitutionValues: {'id': serviceId},
    );

    if (priceResult.isEmpty) {
      throw Exception("Service doesn't exist");
    }

    final unitPrice = priceResult.first.toColumnMap()['price'];

    final result = await db.query(
      ''' 
      INSERT INTO orderservices(order_id, service_id, quantity, unit_price)
      VALUES (@order_id, @service_id, @quantity, @unit_price)
      RETURNING *;
      ''',
      substitutionValues: {
        'order_id': orderId,
        'service_id': serviceId,
        'quantity': quantity,
        'unit_price': unitPrice,
      },
    );

    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({required int id, int? quantity}) async {
    final result = await db.query(
      '''
      UPDATE orderservices
      SET quantity = COALESCE(@quantity, quantity)
      WHERE order_services_id = @id
      RETURNING *;
      ''',
      substitutionValues: {'id': id, 'quantity': quantity},
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      ''' 
      DELETE FROM orderservices WHERE order_services_id = @id;
      ''',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount > 0;
  }
}
