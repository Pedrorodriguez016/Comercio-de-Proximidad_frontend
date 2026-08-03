import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/event_model.dart';

class EventService {
  late final Dio _dio;

  EventService() {
    final baseUrl = dotenv.env['ODOO_API_URL'] ?? 'http:localhost:8069';
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print("EVENT_SERVICE_REQUEST: [${options.method}] ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print("EVENT_SERVICE_RESPONSE: [${response.statusCode}] DATA=${response.data}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("EVENT_SERVICE_ERROR: $e");
        return handler.next(e);
      },
    ));
  }

  /// Obté tots els esdeveniments disponibles des d'Odoo enviant el filtre per POST
  Future<List<EventModel>> getEvents({String? startDate, String? endDate}) async {
    try {
      final body = <String, dynamic>{};
      if (startDate != null && startDate.isNotEmpty) {
        body['start_date'] = startDate;
      }
      if (endDate != null && endDate.isNotEmpty) {
        body['end_date'] = endDate;
      }

      final response = await _dio.post('/events', data: body);
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data != null && data is Map && data['events'] is List) {
        return (data['events'] as List)
            .map((e) => EventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } catch (e, stack) {
      print('EVENT_SERVICE Error carregant esdeveniments: $e\n$stack');
      return [];
    }
  }

  /// Inscriu un usuari a un esdeveniment per email en Odoo
  Future<bool> registerToEvent(int eventId, String email, {String? name}) async {
    try {
      final response = await _dio.post(
        '/events/$eventId/register',
        data: {
          'email': email.trim(),
          if (name != null && name.isNotEmpty) 'name': name.trim(),
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('EVENT_SERVICE Error inscripció: $e');
      return false;
    }
  }

  /// Obté els esdeveniments de l'usuari des d'Odoo
  Future<List<Map<String, dynamic>>> getMyEvents(String email) async {
    try {
      final response = await _dio.get(
        '/events/my-events',
        queryParameters: {'email': email.trim()},
      );
      dynamic data = response.data;
      if (data is String) {
        data = jsonDecode(data);
      }
      if (data != null && data is Map && data['my_events'] is List) {
        return List<Map<String, dynamic>>.from(data['my_events']);
      }
      return [];
    } catch (e) {
      print('EVENT_SERVICE Error carregant els meus esdeveniments: $e');
      return [];
    }
  }
}
