import 'package:flutter/material.dart';
import '../utils/token_manager.dart';
import 'package:app_links/app_links.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../main.dart';

class AuthController with ChangeNotifier {
  final AuthService _authService = AuthService();
  late AppLinks _appLinks;

  bool _isInitializing = true;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _userToken = '';
  Map<String, dynamic> _userData = {};
  UserModel? _currentUser;

  // Getters
  bool get isInitializing => _isInitializing;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get userToken => _userToken;
  Map<String, dynamic> get userData => _userData;
  UserModel? get currentUser => _currentUser;

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
          _currentUser = UserModel.fromJson(_userData);
        }

        await TokenManager.saveTokens(
          accessToken: _userToken,
          refreshToken: tokens['refresh_token'],
          userId: _userData['_id'] ?? _userData['id'],
          userData: _userData,
        );
        print("AUTH_CONTROLLER: Sesión guardada y login marcado como TRUE");

        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (route) => false);
        }
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
      String? token = await TokenManager.getAccessToken();
      String? userId = await TokenManager.getUserId();
      Map<String, dynamic>? userData = await TokenManager.getUserData();

      if (token != null) {
        _userToken = token;
        _isLoggedIn = true;
        if (userData != null) {
          _userData = userData;
          _currentUser = UserModel.fromJson(_userData);
        } else if (userId != null && userId.isNotEmpty) {
          _userData = {'_id': userId};
          _currentUser = UserModel.fromJson(_userData);
        }
        notifyListeners();
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
          _currentUser = UserModel.fromJson(_userData);
        }

        await TokenManager.saveTokens(
          accessToken: _userToken,
          refreshToken: response.data['refresh_token'],
          userId: _userData['_id'] ?? _userData['id'],
          userData: _userData,
        );

        if (navigatorKey.currentState != null) {
          navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (route) => false);
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
    print("AUTH_CONTROLLER: refreshUserData started. Current _userData: $_userData");
    String? userId = _userData['_id'] ?? _userData['id'];
    if (userId != null && _userToken.isNotEmpty) {
      final updatedUser = await _authService.getProfile(userId, _userToken);
      print("AUTH_CONTROLLER: getProfile response: $updatedUser");
      if (updatedUser != null) {
        final Map<String, dynamic> mergedData = Map<String, dynamic>.from(updatedUser);
        // Preserve SSI/Wallet identity fields if Odoo profile fields are empty
        if ((mergedData['city']?.toString().isEmpty ?? true) && _userData['city']?.toString().isNotEmpty == true) {
          mergedData['city'] = _userData['city'];
        }
        if ((mergedData['poblacion']?.toString().isEmpty ?? true) && _userData['poblacion']?.toString().isNotEmpty == true) {
          mergedData['poblacion'] = _userData['poblacion'];
        }
        if ((mergedData['address']?.toString().isEmpty ?? true) && _userData['address']?.toString().isNotEmpty == true) {
          mergedData['address'] = _userData['address'];
        }
        if ((mergedData['postalCode']?.toString().isEmpty ?? true) && _userData['postalCode']?.toString().isNotEmpty == true) {
          mergedData['postalCode'] = _userData['postalCode'];
        }

        _userData = mergedData;
        _currentUser = UserModel.fromJson(_userData);
        await TokenManager.saveUserData(_userData);
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await TokenManager.clearTokens();
    _userToken = '';
    _isLoggedIn = false;
    _userData = {};
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loginSameDevice() async {
    try {
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
