import 'package:dio/dio.dart';
import '../utils/token_manager.dart';

class ApiClient {
  late Dio dio;
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.0.13:8005',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getAccessToken();
        
        // SOLO inyectamos el token si existe y NO es el token dummy de SSI
        if (token != null && token.isNotEmpty && !token.startsWith('token_ssi_')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // 1. Si el error es 401, intentamos refrescar token
        if (e.response?.statusCode == 401) {
          print("API_CLIENT: Error 401 detectado. Intentando refresh...");
          
          // Nota: Aquí llamaríamos a la lógica de refresh. 
          // Como en tu código de e-vital, si el refresh falla -> logout.
          bool refreshSuccess = await _handleTokenRefresh();
          
          if (refreshSuccess) {
            // Si el refresh funcionó, reintentamos la petición original con el nuevo token
            final newToken = await TokenManager.getAccessToken();
            final opts = Options(
              method: e.requestOptions.method,
              headers: {
                ...e.requestOptions.headers,
                'Authorization': 'Bearer $newToken',
              },
            );
            
            final response = await dio.request(
              e.requestOptions.path,
              data: e.requestOptions.data,
              queryParameters: e.requestOptions.queryParameters,
              options: opts,
            );
            return handler.resolve(response);
          } else {
            print("API_CLIENT: Error 401 detectado. Ignorando auto-logout por ahora...");
          
          /* 
          // Si quieres que te eche al login en el futuro, descomenta esto:
          await TokenManager.clearTokens();
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
          }
          */
          }
        }
        return handler.next(e);
      },
    ));
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Creamos una instancia de Dio limpia para el refresh y evitar bucles
      final refreshDio = Dio(BaseOptions(
        baseUrl: 'http://192.168.0.13:8005',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        if (newAccessToken != null && newRefreshToken != null) {
          await TokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          print("API_CLIENT: Token refreshed con éxito");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("API_CLIENT: Error en _handleTokenRefresh -> $e");
      return false;
    }
  }
}
