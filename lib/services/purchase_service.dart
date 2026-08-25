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
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final String? startStr = startDate != null
          ? "${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}"
          : null;
      final String? endStr = endDate != null
          ? "${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}"
          : null;

      final queryParams = <String, dynamic>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (startStr != null) queryParams['start_date'] = startStr;
      if (endStr != null) queryParams['end_date'] = endStr;

      final bodyData = <String, dynamic>{
        'email': email,
      };
      if (startStr != null) bodyData['start_date'] = startStr;
      if (endStr != null) bodyData['end_date'] = endStr;

      final response = await _odooDio.post(
        '/purchase_history',
        queryParameters: queryParams,
        data: bodyData,
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
