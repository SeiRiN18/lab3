import 'package:backend/db/connection.dart';

class WorkersRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getAll() async {
    final result = await db.query('''
        SELECT * FROM workers ORDER BY worker_id;
      ''');
    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<Map<String, dynamic>?> getById(int id) async {
    final result = await db.query(
      '''
      SELECT * FROM workers WHERE worker_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required String surname,
    required String position,
    required String phone,
    String? description,
  }) async {
    final result = await db.query(
      '''
      INSERT INTO workers(name, surname, position, phone, description)
      VALUES (@name, @surname, @position, @phone, @description)
      RETURNING *;
    ''',
      substitutionValues: {
        'name': name,
        'surname': surname,
        'position': position,
        'phone': phone,
        'description': description,
      },
    );
    return result.first.toColumnMap();
  }

  Future<Map<String, dynamic>?> update({
    required int id,
    String? name,
    String? surname,
    String? position,
    String? phone,
    String? description,
  }) async {
    final result = await db.query(
      '''
      UPDATE workers
      SET 
        name = COALESCE(@name, name),
        surname = COALESCE(@surname, surname),
        position = COALESCE(@position, position),
        phone = COALESCE(@phone, phone),
        description = COALESCE(@description, description)
      WHERE worker_id = @id
      RETURNING *;
    ''',
      substitutionValues: {
        'id': id,
        'name': name,
        'surname': surname,
        'position': position,
        'phone': phone,
        'description': description,
      },
    );

    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  Future<bool> delete(int id) async {
    final result = await db.query(
      '''
      DELETE FROM workers WHERE worker_id = @id;
    ''',
      substitutionValues: {'id': id},
    );
    return result.affectedRowCount > 0;
  }
}
