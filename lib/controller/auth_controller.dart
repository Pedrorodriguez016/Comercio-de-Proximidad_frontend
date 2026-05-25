import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import 'package:app_links/app_links.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  late AppLinks _appLinks;

  bool _isInitializing =
      true; // Nuevo: para saber si estamos cargando la app al inicio
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _userToken = '';
  Map<String, dynamic> _userData = {};

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get userToken => _userToken;
  Map<String, dynamic> get userData => _userData;

  AuthController() {
    _initDeepLinks();
    checkLoginStatus();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
      print("DEEP LINK RECIBIDO: $uri");
      if (uri.scheme == 'comercio' && uri.host == 'login-callback') {
        final sessionId = uri.queryParameters['session_id'];
        if (sessionId != null) {
          _completeSameDeviceLogin(sessionId);
        }
      }
    });
  }

  Future<void> _completeSameDeviceLogin(String sessionId) async {
    print("AUTH_CONTROLLER: Completando login para $sessionId");
    try {
      _isLoading = true;
      notifyListeners();

      final tokens = await _authService.exchangeToken(sessionId);

      if (tokens != null) {
        print("AUTH_CONTROLLER: Token recibido con éxito");
        _userToken = tokens['access_token'];
        _isLoggedIn = true;

        var userRawData = tokens['user'];
        if (userRawData != null) {
          _userData = Map<String, dynamic>.from(userRawData);
        }

        await TokenManager.saveTokens(
          accessToken: _userToken,
          userId: _userData['_id'] ?? _userData['id'],
        );
        print("AUTH_CONTROLLER: Sesión guardada y login marcado como TRUE");
      } else {
        print("AUTH_CONTROLLER: El intercambio de tokens devolvió NULL");
      }
    } catch (e) {
      print("AUTH_CONTROLLER: ERROR SSI LOGIN -> $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      _isInitializing = true;
      notifyListeners();

      String? token = await TokenManager.getAccessToken();
      String? userId = await TokenManager.getUserId();

      if (token != null) {
        _userToken = token;
        _isLoggedIn = true;
        if (userId != null && userId.isNotEmpty) {
          _userData = {'_id': userId};
        }
        notifyListeners();
        await refreshUserData();
      }
    } catch (e) {
      print("Error checking login status: $e");
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      var response = await _authService.login(email, password);

      if (response.statusCode == 200 && response.data != null) {
        String? token = response.data['token'];
        if (token == null) throw "El servidor no ha devuelto un token";

        _userToken = token;
        _isLoggedIn = true;

        var userRawData = response.data['user'];
        if (userRawData != null) {
          _userData = Map<String, dynamic>.from(userRawData);
        }

        await TokenManager.saveTokens(
          accessToken: _userToken,
          userId: _userData['_id'] ?? _userData['id'],
        );

        return true;
      }
      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String name,
    String surnames,
    String email,
    String password,
    String address,
    String city,
    String postalCode,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();
      var response = await _authService.register({
        'name': name,
        'surnames': surnames,
        'email': email,
        'password': password,
        'address': address,
        'city': city,
        'postalCode': postalCode,
      });
      return response.statusCode == 200;
    } catch (e) {
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    String? userId = _userData['_id'] ?? _userData['id'];
    if (userId != null && _userToken.isNotEmpty) {
      final updatedUser = await _authService.getProfile(userId, _userToken);
      if (updatedUser != null) {
        _userData = Map<String, dynamic>.from(updatedUser);
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await TokenManager.clearTokens();
    _userToken = '';
    _isLoggedIn = false;
    _userData = {};
    notifyListeners();
  }

  Future<void> loginSameDevice() async {
    try {
      // Nota: Aquí NO ponemos _isLoading = true global si no queremos que AuthWrapper reaccione
      // Pero si queremos feedback en el botón, podemos usarlo.
      // El problema era que AuthWrapper usaba isLoading para mostrar la Splash.
      _isLoading = true;
      notifyListeners();
      await _authService.loginWithIdentity();
    } catch (e) {
      print("Error lanzando wallet: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
