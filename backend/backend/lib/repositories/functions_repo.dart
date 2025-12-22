import 'package:backend/db/connection.dart';

class FunctionsRepository {
  final db = DB.connection;

  Future<List<Map<String, dynamic>>> getPopularService(
    String name,
    String surname,
  ) async {
    final result = await db.query(
      '''
      SELECT * FROM get_popular_service_by_worker(@name, @surname);
      ''',
      substitutionValues: {'name': name, 'surname': surname},
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  Future<num?> getServiceRevenue(int serviceId) async {
    final result = await db.query(
      '''
      SELECT total_revenue_for_service(@service_id) AS total_revenue;
      ''',
      substitutionValues: {'service_id': serviceId},
    );

    if (result.isEmpty) return null;
    final value = result.first.toColumnMap()['total_revenue'];
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}
