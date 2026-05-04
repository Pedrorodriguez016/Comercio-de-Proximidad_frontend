import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Explorar",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _authController.logout(),
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
              "Hola, ${_authController.userData['name'] ?? 'Usuario'}",
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
            // Placeholder for content
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1542838132-92c53300491e?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=60'),
                  fit: BoxFit.cover,
                  opacity: 0.7,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mercados Locales",
                      style: GoogleFonts.notoSerif(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
                      ),
                    ),
                    Text(
                      "Descubre productos frescos cerca de ti",
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        shadows: [const Shadow(blurRadius: 10, color: Colors.black45)],
                      ),
                    ),
                  ],
                ),
              ),
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
                children: [
                  _categoryCard("Frutas", Icons.apple, AppColors.primary),
                  _categoryCard("Panadería", Icons.bakery_dining, AppColors.secondary),
                  _categoryCard("Café", Icons.coffee, AppColors.neutral),
                  _categoryCard("Flores", Icons.local_florist, AppColors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Buscar"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        ],
      ),
    );
  }

  Widget _categoryCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}
