import 'package:backend/db/connection.dart';

class ProceduresRepository {
  final db = DB.connection;

  Future<String> applyDiscount({
    required String serviceName,
    required int percent,
  }) async {
    try {
      await db.query(
        ''' 
        CALL apply_discount_to_service(@name, @percent);
        ''',
        substitutionValues: {'name': serviceName, 'percent': percent},
      );
      return 'Discount applied';
    } catch (e) {
      return "ERROR: ${e.toString()}";
    }
  }
}
