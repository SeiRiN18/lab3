import 'package:frontend/api/api_client.dart';

class WorkersApi {
  static Future<List<dynamic>> getAll() async {
    return await ApiClient.get('/workers');
  }

  static Future<dynamic> getById(int id) async {
    return await ApiClient.get('/workers/$id');
  }

  static Future<dynamic> create(Map<String, dynamic> body) async {
    return await ApiClient.post('/workers', body);
  }

  static Future<dynamic> update(int id, Map<String, dynamic> body) async {
    return await ApiClient.put('/workers/$id', body);
  }

  static Future<dynamic> delete(int id) async {
    return await ApiClient.delete('/workers/$id');
  }
}
