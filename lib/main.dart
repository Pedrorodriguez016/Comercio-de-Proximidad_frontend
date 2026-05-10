import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/wallet_card_screen.dart';
import 'screens/user_pass_screen.dart';
import 'theme/app_theme.dart';
import 'controller/auth_controller.dart';
import 'controller/navigation_controller.dart';
import 'controller/commerce_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => CommerceController()),
      ],
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Comercio Proximidad',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/wallet-card': (context) => const WalletCardScreen(),
        '/user-pass': (context) => UserPassScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    
    // Solo mostrar Splash durante la inicialización (checkLoginStatus)
    if (auth.isInitializing) {
      return const SplashScreen();
    }
    
    // Si no está logueado, ir al Login
    if (!auth.isLoggedIn) {
      return LoginScreen();
    }


    // Por defecto, ir a Home
    return HomeScreen();
  }
}
