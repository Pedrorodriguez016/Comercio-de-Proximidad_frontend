import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/commerce_model.dart';
import '../models/eix_comercial_model.dart';

class CommerceService {
  late final Dio _dio;

  CommerceService() {
    final baseUrl = dotenv.env['ODOO_API_URL'] ?? 'http://172.20.10.2:8069';
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
            "ODOO_COMMERCE_SERVICE_REQUEST: [${options.method}] ${options.uri}",
          );
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print("ODOO_COMMERCE_SERVICE_ERROR: $e");
          return handler.next(e);
        },
      ),
    );
  }

  /// Searches Odoo commerces matching parameters and returns a list of CommerceModel.
  Future<List<CommerceModel>> searchCommerces({
    String? queryName,
    int? eixComercialId,
    String? district,
    String? category,
    String? token,
    int skip = 0,
    int limit = 100,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      final requestData = <String, dynamic>{};
      if (eixComercialId != null) {
        requestData['eix_comercial_id'] = eixComercialId;
      }
      if (district != null && district.isNotEmpty) {
        requestData['district'] = district;
      }
      if (category != null && category.isNotEmpty) {
        requestData['category'] = category;
      }
      if (queryName != null && queryName.isNotEmpty) {
        requestData['search'] = queryName;
      }

      final response = await _dio.post(
        '/comercios',
        queryParameters: queryParams,
        data: requestData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => CommerceModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error searching Odoo commerces: $e");
      return [];
    }
  }

  /// Gets a single Odoo commerce by ID.
  Future<CommerceModel?> getCommerceById(String id) async {
    try {
      final List<CommerceModel> allComerces = await searchCommerces();
      for (final c in allComerces) {
        if (c.id == id) {
          return c;
        }
      }
      return null;
    } catch (e) {
      print("Error getting Odoo commerce by id $id: $e");
      return null;
    }
  }

  /// Fetches commercial axes (eixos comercials) from Odoo.
  Future<List<EixComercialModel>> getEixosComercials() async {
    try {
      final response = await _dio.get('/eixos_comercials');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map((json) => EixComercialModel.fromJson(json))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching eixos comercials from Odoo: $e");
      return [];
    }
  }

  /// Fetches loyalty points balance from Odoo using partner/customer ID or email.
  Future<double?> getLoyaltyPoints({int? customerId, String? email}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (customerId != null) {
        queryParams['customer_id'] = customerId.toString();
      } else if (email != null) {
        queryParams['email'] = email;
      } else {
        return null;
      }

      final response = await _dio.get(
        '/loyalty_points',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data.containsKey('loyalty_points')) {
          final points = data['loyalty_points'];
          if (points is num) {
            return points.toDouble();
          } else if (points is String) {
            return double.tryParse(points);
          } else if (points == false || points == null) {
            return 0.0;
          }
        }
      }
      return null;
    } catch (e) {
      print("Error fetching loyalty points from Odoo: $e");
      return null;
    }
  }

  /// Geocodes an address string using OpenStreetMap's Nominatim API.
  Future<Map<String, double>?> geocodeAddress(String rawAddress) async {
    if (rawAddress.isEmpty) return null;
    final dio = Dio();

    final queriesToTry = <String>[];
    final lower = rawAddress.toLowerCase();

    final withCity = lower.contains('barcelona') ? rawAddress : '$rawAddress, Barcelona';
    queriesToTry.add(withCity);

    final match = RegExp(r'^(.*?)\s+(\d+)(.*)$').firstMatch(rawAddress);
    if (match != null) {
      final streetName = match.group(1)?.trim() ?? '';
      final number = match.group(2)?.trim() ?? '';
      final rest = match.group(3)?.trim() ?? '';
      final formattedNumberFirst = '$number $streetName $rest'.trim();
      queriesToTry.add(formattedNumberFirst.toLowerCase().contains('barcelona')
          ? formattedNumberFirst
          : '$formattedNumberFirst, Barcelona');
    }

    for (final query in queriesToTry) {
      try {
        final url = 'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1';
        final response = await dio.get(
          url,
          options: Options(
            headers: {
              'User-Agent': 'ComercioDeProximidadApp/1.0 (com.example.app_tfg)',
            },
          ),
        );

        if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
          final firstResult = (response.data as List).first;
          final double? lat = double.tryParse(firstResult['lat']?.toString() ?? '');
          final double? lon = double.tryParse(firstResult['lon']?.toString() ?? '');
          if (lat != null && lon != null) {
            return {'lat': lat, 'lng': lon};
          }
        }
      } catch (e) {
        print("Error in geocoding attempt for '$query': $e");
      }
    }
    return null;
  }
}
