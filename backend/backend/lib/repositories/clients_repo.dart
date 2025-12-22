import 'package:backend/db/connection.dart';

class ClientsRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query('''
        SELECT * FROM clients ORDER BY client_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      '''
      SELECT * FROM clients WHERE client_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required String surname,
    required String phone,
  }) async {
    final result = await db.query(
      '''
      INSERT INTO clients(name, surname, phone)
      VALUES (@name, @surname, @phone)
      RETURNING *;
    ''',
      substitutionValues: {'name': name, 'surname': surname, 'phone': phone},
    );
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({
    required int id,
    String? name,
    String? surname,
    String? phone,
  }) async {
    final result = await db.query(
      '''
      UPDATE clients
      SET 
        name = COALESCE(@name, name),
        surname = COALESCE(@surname, surname),
        phone = COALESCE(@phone, phone)
      WHERE client_id = @id
      RETURNING *;
    ''',
      substitutionValues: {
        'id': id,
        'name': name,
        'surname': surname,
        'phone': phone,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      '''
      DELETE FROM clients WHERE client_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount > 0;
  }
}
