import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userDataKey = 'user_data';

  static Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
    String? userId,
    Map<String, dynamic>? userData,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    if (refreshToken != null) {
      await prefs.setString(_refreshTokenKey, refreshToken);
    }
    if (userId != null) {
      await prefs.setString(_userIdKey, userId);
    }
    if (userData != null) {
      await prefs.setString(_userDataKey, json.encode(userData));
    }
  }

  /// Guarda solo los datos del usuario
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userDataKey, json.encode(userData));
  }

  /// Recupera los datos del usuario
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final dataStr = prefs.getString(_userDataKey);
    if (dataStr != null && dataStr.isNotEmpty) {
      try {
        return json.decode(dataStr) as Map<String, dynamic>;
      } catch (e) {
        print("Error decoding user data: $e");
        return null;
      }
    }
    return null;
  }

  /// Recupera el access token
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Recupera el refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Recupera el ID de usuario
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Elimina todos los datos de sesión
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userDataKey);
  }

  /// Verifica si hay una sesión activa
  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
