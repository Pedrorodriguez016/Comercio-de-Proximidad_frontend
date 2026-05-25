import 'package:dio/dio.dart';
import 'api_client.dart';

class CommerceService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> searchCommerces({
    String? queryName,
    String? type,
    String? token,
    int skip = 0,
    int limit = 15,
  }) async {
    try {
      final response = await _dio.post(
        '/comercios/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
        data: {
          "filters": {
            if (queryName != null && queryName.isNotEmpty) "name": queryName,
            if (type != null && type.isNotEmpty) "type": type,
          },
          "orders": {}
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data;
        } else if (data is Map) {
          return (data['items'] ?? data['results'] ?? []) as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print("Error searching commerces: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCommerceById(String id) async {
    try {
      final response = await _dio.get('/comercio/$id');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error getting commerce by id $id: $e");
      return null;
    }
  }
}
