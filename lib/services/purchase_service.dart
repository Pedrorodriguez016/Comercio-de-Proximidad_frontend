import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  late final Dio _odooDio;

  PurchaseService() {
    final baseUrl = dotenv.env['ODOO_API_URL'] ?? 'http://172.20.10.2:8069';
    _odooDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));
  }

  Future<List<PurchaseModel>> getPurchaseHistory({
    required String email,
    int skip = 0,
    int limit = 15,
  }) async {
    try {
      final response = await _odooDio.post(
        '/purchase_history',
        queryParameters: {
          'skip': skip.toString(),
          'limit': limit.toString(),
        },
        data: {
          'email': email,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => PurchaseModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching purchase history from Odoo: $e");
      return [];
    }
  }
}
