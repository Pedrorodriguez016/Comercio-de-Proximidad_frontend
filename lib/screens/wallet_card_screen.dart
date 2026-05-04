import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import '../controller/auth_controller.dart';
import '../theme/app_theme.dart';

class WalletCardScreen extends StatelessWidget {
  const WalletCardScreen({super.key});

  Future<void> _addPass() async {
    try {
      bool isCardShown = await FlutterWalletCard.addFromUrl(
        'http://localhost:8005/storage/wallet/download/user_card.pkpass?user_id=${Get.find<AuthController>().userData['id'] ?? ''}',
      );

      if (isCardShown) {
        Get.snackbar("Éxito", "Tarjeta añadida a Google Wallet");
        Get.offAllNamed('/home');
      }
    } catch (e) {
      Get.snackbar("Error", "No se pudo añadir la tarjeta: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Fidelización",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Earth & Ethos",
                        style: GoogleFonts.notoSerif(
                          color: AppColors.tertiary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.eco, color: AppColors.tertiary),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    Get.find<AuthController>().userData['name']
                            ?.toUpperCase() ??
                        "USUARIO",
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontSize: 18,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "ID: #${Get.find<AuthController>().userData['id']?.toString().substring(0, 8) ?? '12345678'}",
                    style: GoogleFonts.manrope(
                      color: AppColors.tertiary.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "PUNTOS: 500",
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "¡Bienvenido a tu primer login!",
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Tu tarjeta de fidelización está lista para ser añadida a tu Google Wallet. Disfruta de beneficios exclusivos en comercios locales.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 16,
                color: AppColors.neutral,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: _addPass,
              icon: const Icon(Icons.wallet, size: 24),
              label: Text(
                "Añadir a Google Wallet",
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.onBackground,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.offAllNamed('/home'),
              child: Text(
                "Omitir por ahora",
                style: GoogleFonts.manrope(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
