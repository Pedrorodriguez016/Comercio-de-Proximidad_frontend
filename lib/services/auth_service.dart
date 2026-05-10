import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<Response> login(String email, String password) async {
    return await _dio.post('/auth/login/user/', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post('/auth/register/user/', data: userData);
  }

  // --- LÓGICA DE IDENTIDAD DIGITAL (SSI) ---

  Future<void> loginWithIdentity() async {
    try {
      print('SSI LOGIN: 1. Pidiendo sesión al backend...');
      final sessionData = await createSSISession();
      if (sessionData == null) throw "No se pudo crear la sesión de identidad";

      String sessionId = sessionData['session_id'];
      String qrData = sessionData['qr_data'];

      final String callbackUrl = 'comercio://login-callback?session_id=$sessionId';
      final Uri walletUri = Uri.parse('wallet://verify?session_id=$sessionId&uri=${Uri.encodeComponent(qrData)}&callback=${Uri.encodeComponent(callbackUrl)}');
      
      if (await canLaunchUrl(walletUri)) {
        await launchUrl(walletUri, mode: LaunchMode.externalApplication);
      } else {
        throw "La aplicación Wallet no está instalada en este dispositivo";
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createSSISession() async {
    try {
      final response = await _dio.post('/auth/qr-session');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> exchangeToken(String sessionId) async {
    try {
      print('AUTH_SERVICE: Iniciando intercambio de token para session: $sessionId');
      final response = await _dio.post('/auth/token', queryParameters: {
        'session_id': sessionId,
      });
      print('AUTH_SERVICE: Intercambio exitoso: ${response.data}');
      return response.data;
    } catch (e) {
      print('AUTH_SERVICE: Error en exchangeToken -> $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String userId, String token) async {
    try {
      // Nota: El token ya se inyecta vía interceptor, pero si pasamos uno manual Dio lo usará
      final response = await _dio.get('/user/$userId');
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
