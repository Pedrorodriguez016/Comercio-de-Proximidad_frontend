import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../controller/navigation_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/featured_banner.dart';
import '../widgets/bottom_nav_bar.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = context.watch<NavigationController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: navController.currentIndex,
        children: [
          _buildHomeContent(context),
          const Center(child: Text("Pantalla de Búsqueda")), // Placeholder
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: navController.currentIndex,
        onTap: (index) => navController.changeIndex(index),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "Explorar",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              authController.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.logout, color: AppColors.primary),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, ${authController.userData['name'] ?? 'Usuario'}",
              style: GoogleFonts.notoSerif(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "¿Qué comercio quieres visitar hoy?",
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 30),
            
            const FeaturedBanner(
              title: "Mercados Locales",
              subtitle: "Descubre productos frescos cerca de ti",
              imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60',
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Categorías",
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "Ver todas",
                    style: GoogleFonts.manrope(color: AppColors.secondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryCard(title: "Frutas", icon: Icons.apple, color: AppColors.primary),
                  CategoryCard(title: "Panadería", icon: Icons.bakery_dining, color: AppColors.secondary),
                  CategoryCard(title: "Café", icon: Icons.coffee, color: AppColors.neutral),
                  CategoryCard(title: "Flores", icon: Icons.local_florist, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
