import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import '../services/auth_service.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  late AppLinks _appLinks;

  bool _isInitializing = true; // Nuevo: para saber si estamos cargando la app al inicio
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
    try {
      _isLoading = true;
      notifyListeners();
      
      final tokens = await _authService.exchangeToken(sessionId);

      if (tokens != null) {
        _userToken = tokens['access_token'];
        _isLoggedIn = true;

        var userRawData = tokens['user'];
        if (userRawData != null) {
          _userData = Map<String, dynamic>.from(userRawData);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _userToken);
        
        // Manejar el ID de forma robusta
        String? userId = _userData['_id'] ?? _userData['id'];
        if (userId != null) {
          await prefs.setString('userId', userId);
        }
      }
    } catch (e) {
      print("ERROR SSI LOGIN: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    try {
      _isInitializing = true;
      notifyListeners();
      
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? userId = prefs.getString('userId');
      
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

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        String? userId = _userData['_id'] ?? _userData['id'];
        if (userId != null) {
          await prefs.setString('userId', userId);
        }

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

  Future<bool> register(String name, String surnames, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      var response = await _authService.register({
        'name': name,
        'surnames': surnames,
        'email': email,
        'password': password,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
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
