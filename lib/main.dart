import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'controller/purchase_controller.dart';
import 'controller/event_controller.dart';
import 'screens/events_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NavigationController()),
        ChangeNotifierProvider(create: (_) => CommerceController()),
        ChangeNotifierProvider(create: (_) => PurchaseController()),
        ChangeNotifierProvider(create: (_) => EventController()),
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
      title: 'Comerç de Proximitat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => const AuthGuard(child: HomeScreen()),
        '/wallet-card': (context) => const AuthGuard(child: WalletCardScreen()),
        '/user-pass': (context) => const AuthGuard(child: UserPassScreen()),
        '/events': (context) => const AuthGuard(child: EventsScreen()),
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
    return const HomeScreen();
  }
}

class AuthGuard extends StatelessWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

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

    return child;
  }
}
