import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  static String _sanitizeUrl(String rawUrl) {
    var url = rawUrl.trim();
    if (Platform.isAndroid && (url.contains('localhost') || url.contains('127.0.0.1'))) {
      url = url.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
    }
    return url;
  }

  // Instancia de Dio dedicada para conectar con el backend de la Wallet-App
  final Dio _walletDio = Dio(BaseOptions(
    baseUrl: _sanitizeUrl(dotenv.env['WALLET_API_URL'] ?? 'http://10.0.2.2:8000'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  Future<Response> login(String email, String password) async {
    return await _walletDio.post('/auth/login/user/', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _walletDio.post('/auth/register/user/', data: userData);
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
      final response = await _walletDio.post('/auth/qr-session');
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> exchangeToken(String sessionId) async {
    try {
      print('AUTH_SERVICE: Iniciando intercambio de token para session: $sessionId');
      final response = await _walletDio.post('/auth/token', queryParameters: {
        'session_id': sessionId,
      });
      print('AUTH_SERVICE: response.data raw = ${response.data}');
      final data = response.data;
      if (data != null && data['access_token'] != null) {
        final accessToken = data['access_token'];
        final payload = _decodeJwt(accessToken);
        print('AUTH_SERVICE: decoded JWT payload = $payload');
        
        final Map<String, dynamic> directUser = data['user'] != null
            ? Map<String, dynamic>.from(data['user'])
            : {};
        print('AUTH_SERVICE: directUser from backend = $directUser');

        final String keycloakId = payload['sub'] ?? directUser['keycloak_id'] ?? directUser['id'] ?? '';
        final String userId = keycloakId.startsWith('did:') ? '' : keycloakId;

        data['user'] = {
          'id': userId,
          '_id': userId,
          'keycloak_id': userId,
          'email': (directUser['email']?.toString().isNotEmpty == true)
              ? directUser['email']
              : payload['email'],
          'name': (directUser['name']?.toString().isNotEmpty == true)
              ? directUser['name']
              : (payload['given_name'] ?? payload['name'] ?? 'Usuario Wallet'),
          'surnames': (directUser['surnames']?.toString().isNotEmpty == true)
              ? directUser['surnames']
              : (payload['family_name'] ?? payload['lastName'] ?? ''),
          'address': (directUser['address']?.toString().isNotEmpty == true)
              ? directUser['address']
              : (payload['address'] ?? ''),
          'city': (directUser['city']?.toString().isNotEmpty == true)
              ? directUser['city']
              : (payload['city'] ?? ''),
          'postalCode': (directUser['postalCode']?.toString().isNotEmpty == true)
              ? directUser['postalCode']
              : (payload['postalCode'] ?? payload['postal_code'] ?? ''),
          'firstLogin': false,
        };
      }

      return data;
    } catch (e) {
      print('AUTH_SERVICE: Error en exchangeToken -> $e');
      return null;
    }
  }

  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      var normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      return json.decode(resp);
    } catch (e) {
      print('AUTH_SERVICE: Error decoding JWT: $e');
      return {};
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

