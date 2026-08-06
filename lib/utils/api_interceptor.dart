import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../main.dart';
import 'token_manager.dart';

/// Interceptor global de Dio para gestionar autorización y auto-refresh en 401.
class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenManager.getAccessToken();
    if (token != null && token.isNotEmpty && !token.startsWith('token_ssi_')) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si la petición devuelve 401 (Unauthorized), ejecutamos el proceso de refresco automático
    if (err.response?.statusCode == 401) {
      print("AUTH_INTERCEPTOR: Error 401 detectado en ${err.requestOptions.path}. Intentando refresh...");

      final bool refreshSuccess = await _handleTokenRefresh();

      if (refreshSuccess) {
        final newToken = await TokenManager.getAccessToken();
        print("AUTH_INTERCEPTOR: Refresh exitoso. Reintentando petición original a ${err.requestOptions.path}...");

        try {
          // Reintentamos la petición original con el nuevo token inyectado
          final opts = Options(
            method: err.requestOptions.method,
            headers: {
              ...err.requestOptions.headers,
              'Authorization': 'Bearer $newToken',
            },
          );

          final response = await dio.request(
            err.requestOptions.path,
            data: err.requestOptions.data,
            queryParameters: err.requestOptions.queryParameters,
            options: opts,
          );

          return handler.resolve(response);
        } catch (retryError) {
          if (retryError is DioException) {
            return handler.next(retryError);
          }
        }
      } else {
        print("AUTH_INTERCEPTOR: Refresh token expirado o inválido. Redirigiendo a /login...");
        await TokenManager.clearTokens();
        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await TokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final refreshDio = Dio(BaseOptions(
        baseUrl: dotenv.env['WALLET_API_URL'] ?? 'http://172.20.10.2:8000',
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
        if (newAccessToken != null && newAccessToken.toString().isNotEmpty) {
          await TokenManager.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );
          print("AUTH_INTERCEPTOR: Tokens actualizados en SharedPreferences.");
          return true;
        }
      }
      return false;
    } catch (e) {
      print("AUTH_INTERCEPTOR: Falló la petición de refresh -> $e");
      return false;
    }
  }
}
