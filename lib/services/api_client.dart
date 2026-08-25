import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/api_interceptor.dart';

class ApiClient {
  late Dio dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  static String _sanitizeUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (Platform.isAndroid && (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: _sanitizeUrl(dotenv.env['API_URL'] ?? 'http://10.0.2.2:8005'),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(AuthInterceptor(dio));
  }
}
