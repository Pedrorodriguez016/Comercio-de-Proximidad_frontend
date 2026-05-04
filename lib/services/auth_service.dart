import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  // Backend de Comercio de Proximidad (Puerto 8005)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.0.25:8005', 
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // Backend de Comercio de Proximidad (Puerto 8005) - Ahora gestiona también la identidad
  final Dio _authDio = Dio(BaseOptions(
    baseUrl: 'http://192.168.0.25:8005',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Response> login(String email, String password) async {
    try {
      return await _dio.post('/auth/login/user/', data: {
        'email': email,
        'password': password,
      });
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    try {
      return await _dio.post('/auth/register/user/', data: userData);
    } on DioException catch (e) {
      rethrow;
    }
  }

  // --- LÓGICA DE IDENTIDAD DIGITAL (SSI) ---

  Future<void> loginWithIdentity() async {
    try {
      print('SSI LOGIN: 1. Pidiendo sesión al backend...');
      // 1. Pedir sesión al backend de identidad
      final sessionData = await createSSISession();
      if (sessionData == null) throw "No se pudo crear la sesión de identidad";

      String sessionId = sessionData['session_id'];
      String qrData = sessionData['qr_data'];
      print('SSI LOGIN: 2. Sesión creada: $sessionId');
      print('SSI LOGIN: 2b. QR data: $qrData');

      // 2. Lanzar la Wallet App por Deep Link
      final String callbackUrl = 'comercio://login-callback?session_id=$sessionId';
      final Uri walletUri = Uri.parse('wallet://verify?session_id=$sessionId&uri=${Uri.encodeComponent(qrData)}&callback=${Uri.encodeComponent(callbackUrl)}');
      
      print('SSI LOGIN: 3. Lanzando wallet con URI: $walletUri');
      
      if (await canLaunchUrl(walletUri)) {
        print('SSI LOGIN: 4. canLaunchUrl = TRUE, abriendo wallet...');
        await launchUrl(walletUri, mode: LaunchMode.externalApplication);
      } else {
        print('SSI LOGIN: 4. canLaunchUrl = FALSE, wallet NO encontrada');
        throw "La aplicación Wallet no está instalada en este dispositivo";
      }
    } catch (e) {
      print('SSI LOGIN: ERROR -> $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> createSSISession() async {
    try {
      print('SSI SESSION: Llamando a POST /auth/qr-session ...');
      final response = await _authDio.post('/auth/qr-session');
      print('SSI SESSION: Respuesta ${response.statusCode}: ${response.data}');
      return response.data;
    } catch (e) {
      print('SSI SESSION: ERROR -> $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> exchangeToken(String sessionId) async {
    try {
      final response = await _authDio.post('/auth/token', queryParameters: {
        'session_id': sessionId,
      });
      return response.data;
    } catch (e) {
      return null;
    }
  }
}
