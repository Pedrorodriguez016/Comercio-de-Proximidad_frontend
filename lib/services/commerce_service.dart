import 'package:dio/dio.dart';
import 'api_client.dart';

class CommerceService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> searchCommerces({String? queryName, String? type, String? token}) async {
    try {
      final response = await _dio.post(
        '/comercios/',
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
}
