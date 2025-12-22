import 'package:frontend/api/api_client.dart';

class CarsApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/cars');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/cars/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/cars', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/cars/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/cars/$id');
  }
}
