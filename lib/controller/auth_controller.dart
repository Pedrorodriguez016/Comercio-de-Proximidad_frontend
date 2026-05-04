import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  late AppLinks _appLinks;
  
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userToken = ''.obs;
  var userData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    _initDeepLinks();
  }

  @override
  void onReady() {
    super.onReady();
    checkLoginStatus();
  }

  void _initDeepLinks() {
    _appLinks = AppLinks();
    _appLinks.uriLinkStream.listen((uri) {
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
      isLoading.value = true;
      final tokens = await _authService.exchangeToken(sessionId);
      
      if (tokens != null) {
        userToken.value = tokens['access_token'];
        isLoggedIn.value = true;
        
        // Usamos postFrameCallback para asegurar que la navegación es estable al volver de la Wallet
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.currentRoute != '/home') {
              Get.offAllNamed('/home');
            }
          });
        });
      } else {
        Get.snackbar("Error", "No se pudo completar el inicio de sesión");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      userToken.value = token;
      isLoggedIn.value = true;
      
      // Pequeño retraso para evitar errores de navegación al arrancar
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.currentRoute != '/home') {
            Get.offAllNamed('/home');
          }
        });
      });
    } else {
      // Si no hay sesión, vamos al login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          Get.offAllNamed('/login');
        });
      });
    }
  }

  // --- LOGIN CON IDENTIDAD DIGITAL (SSI) ---
  Future<void> loginSameDevice() async {
    try {
      isLoading.value = true;
      await _authService.loginWithIdentity();
      // El proceso continuará cuando recibamos el deep link en _initDeepLinks
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error de Identidad", e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1));
    }
  }

  // --- LOGIN TRADICIONAL ---
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      var response = await _authService.login(email, password);
      
      if (response.statusCode == 200 && response.data != null) {
        // Verificamos que el token no sea nulo antes de asignarlo
        String? token = response.data['token'];
        if (token == null) {
          throw "El servidor no ha devuelto un token de acceso";
        }

        userToken.value = token;
        isLoggedIn.value = true;
        
        // Verificamos que los datos del usuario existan
        var userRawData = response.data['user'];
        if (userRawData != null) {
          userData.value = Map<String, dynamic>.from(userRawData);
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        // Check for firstLogin con valor por defecto
        bool isFirstLogin = userData.value['firstLogin'] ?? false;
        if (isFirstLogin) {
          Get.offAllNamed('/wallet-card');
        } else {
          Get.offAllNamed('/home');
        }
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error de Login', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register(String name, String surnames, String email, String password) async {
    try {
      isLoading.value = true;
      var response = await _authService.register({
        'name': name,
        'surnames': surnames,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Registration successful! Please login.');
        Get.toNamed('/login');
        return true;
      }
      return false;
    } catch (e) {
      Get.snackbar('Error', 'Registration failed: ${e.toString()}');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    userToken.value = '';
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
