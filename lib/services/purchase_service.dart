import 'package:dio/dio.dart';
import 'api_client.dart';

class PurchaseService {
  final Dio _dio = ApiClient().dio;

  Future<List<dynamic>> getPurchaseHistory({
    required String userId,
    int skip = 0,
    int limit = 15,
  }) async {
    try {
      final response = await _dio.post(
        '/compras/',
        queryParameters: {
          'skip': skip,
          'limit': limit,
        },
        data: {
          "filters": {
            "user": userId,
          },
          "orders": {"date": -1},
          "populate": [
            {
              "id": "commerce",
              "from": "comercio",
              "as": "commerce"
            }
          ]
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
      print("Error fetching purchase history: $e");
      return [];
    }
  }
}
