import 'package:backend/db/connection.dart';

class CarsRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query('''
        SELECT * FROM cars ORDER BY car_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      '''
      SELECT * FROM cars WHERE car_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> create({
    required String brand,
    required String model,
    int? year,
    String? vinCode,
    required int clientId,
  }) async {
    final result = await db.query(
      '''
      INSERT INTO cars(brand, model, year, vin_code, client_id)
      VALUES (@brand, @model, @year, @vin_code, @client_id)
      RETURNING *;
    ''',
      substitutionValues: {
        'brand': brand,
        'model': model,
        'year': year,
        'vin_code': vinCode,
        'client_id': clientId,
      },
    );
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({
    required int id,
    String? brand,
    String? model,
    int? year,
    String? vinCode,
    int? clientId,
  }) async {
    final result = await db.query(
      '''
      UPDATE cars
      SET 
        brand = COALESCE(@brand, brand),
        model = COALESCE(@model, model),
        year = COALESCE(@year, year),
        vin_code = COALESCE(@vin_code, vin_code),
        client_id = COALESCE(@client_id, client_id)
      WHERE car_id = @id
      RETURNING *;
    ''',
      substitutionValues: {
        'id': id,
        'brand': brand,
        'model': model,
        'year': year,
        'vin_code': vinCode,
        'client_id': clientId,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      '''
      DELETE FROM cars WHERE car_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount > 0;
  }

  Future<List<Map<String, dynamic>>> getByClientId(int clientId) async {
    final result = await db.query(
      '''
      SELECT * FROM cars WHERE client_id = @client_id;
      ''',
      substitutionValues: {'client_id': clientId},
    );
    return result.map((row) => row.toColumnMap()).toList();
  }
}
