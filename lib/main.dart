import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_card_screen.dart';

import 'theme/app_theme.dart';

import 'binidings/auth_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Comercio Proximidad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: AuthBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen(), transition: Transition.noTransition),
        GetPage(
          name: '/login',
          page: () => LoginScreen(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterScreen(),
        ),
        GetPage(
          name: '/home',
          page: () => HomeScreen(),
        ),
        GetPage(
          name: '/wallet-card',
          page: () => const WalletCardScreen(),
        ),
      ],
    );
  }
}
