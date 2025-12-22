import 'package:frontend/api/api_client.dart';

class FunctionsApi {
  static Future<List<dynamic>> getPopularService(
    String name,
    String surname,
  ) async {
    return await ApiClient.get('/functions/popular/$name/$surname');
  }

  static Future<dynamic> getServiceRevenue(int serviceId) async {
    return await ApiClient.get('/functions/revenue/service/$serviceId');
  }
}
