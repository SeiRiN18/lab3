import 'package:frontend/api/api_client.dart';

class OrdersApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/orders');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/orders/$id');
  }

  static Future<List<dynamic>> getByWorker(int workerId) async {
    return await ApiClient.get('/orders/worker/$workerId');
  }

  static Future<List<dynamic>> getByCar(int carId) async {
    return await ApiClient.get('/orders/car/$carId');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/orders', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/orders/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/orders/$id');
  }
}
