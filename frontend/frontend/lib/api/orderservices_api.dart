import 'package:frontend/api/api_client.dart';

class OrderServicesApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/orderservices');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/orderservices/$id');
  }

  static Future<List<dynamic>> getByOrder(int orderId) async {
    return await ApiClient.get('/orderservices/order/$orderId');
  }

  static Future<List<dynamic>> getByService(int serviceId) async {
    return await ApiClient.get('/orderservices/service/$serviceId');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/orderservices', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/orderservices/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/orderservices/$id');
  }
}
