import 'package:backend/db/connection.dart';

class ServicesRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query('''
        SELECT * FROM services ORDER BY service_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      '''
      SELECT * FROM services WHERE service_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required double price,
    required String description,
  }) async {
    final result = await db.query(
      '''
      INSERT INTO services(name, price, description)
      VALUES (@name, @price, @description)
      RETURNING *;
    ''',
      substitutionValues: {
        'name': name,
        'price': price,
        'description': description,
      },
    );
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({
    required int id,
    String? name,
    double? price,
    String? description,
  }) async {
    final result = await db.query(
      '''
      UPDATE services
      SET 
        name = COALESCE(@name, name),
        price = COALESCE(@price, price),
        description = COALESCE(@description, description)
      WHERE service_id = @id
      RETURNING *;
    ''',
      substitutionValues: {
        'id': id,
        'name': name,
        'price': price,
        'description': description,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      '''
      DELETE FROM services WHERE service_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount > 0;
  }
}
