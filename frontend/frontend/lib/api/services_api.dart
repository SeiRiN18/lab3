import 'package:frontend/api/api_client.dart';

class ServicesApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/services');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/services/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/services', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/services/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/services/$id');
  }
}
