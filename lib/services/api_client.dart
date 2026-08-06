import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/api_interceptor.dart';
import '../utils/token_manager.dart';

class ApiClient {
  late Dio dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: dotenv.env['API_URL'] ?? 'http://172.20.10.2:8005',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(AuthInterceptor(dio));
  }
}
