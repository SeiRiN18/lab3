import 'package:frontend/api/api_client.dart';

class ClientsApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/clients');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/clients/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/clients', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/clients/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/clients/$id');
  }
}
