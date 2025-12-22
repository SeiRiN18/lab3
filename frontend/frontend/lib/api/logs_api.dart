import 'package:frontend/api/api_client.dart';

class LogsApi {
  static Future<List<dynamic>> getOrderLogs() async {
    return await ApiClient.get('/logs/orders');
  }

  static Future<List<dynamic>> getBlockedLogs() async {
    return await ApiClient.get('/logs/blocked');
  }
}
