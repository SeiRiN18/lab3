import 'package:frontend/api/api_client.dart';

class ProceduresApi {
  static Future<dynamic> applyDiscount({
    required String serviceName,
    required int percent,
  }) async {
    return await ApiClient.post('/procedures/discount', {
      'service_name': serviceName,
      'percent': percent,
    });
  }
}
