import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controller/auth_controller.dart';
import '../theme/app_theme.dart';

class UserPassScreen extends StatelessWidget {
  const UserPassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final userData = authController.userData;
    final String userId = userData['_id'] ?? userData['id'] ?? 'Unknown ID';
    final String userName = userData['name'] ?? 'Usuari';
    final String userEmail = userData['email'] ?? '';
    final int userPoints = userData['points'] is int 
        ? userData['points'] 
        : int.tryParse(userData['points']?.toString() ?? '0') ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("El meu Pas Digital", style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // El "Pase" o Tarjeta
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, Color(0xFF3D5F4D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userName.toUpperCase(),
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      userEmail,
                                      style: GoogleFonts.manrope(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.qr_code_2, color: AppColors.secondary, size: 40),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatItem("ELS MEUS PUNTS", "$userPoints pts"),
                              _buildStatItem("ESTAT", "Actiu"),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(color: Colors.black12, thickness: 1, height: 1),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle)),
                            Container(width: 20, height: 20, decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle)),
                          ],
                        ),
                      ],
                    ),

                    // Parte inferior: QR i botó Google Wallet
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                      child: Column(
                        children: [
                          QrImageView(
                            data: userId,
                            version: QrVersions.auto,
                            size: 200.0,
                            foregroundColor: AppColors.primary,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.primary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("S'està afegint a Google Wallet..."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: Colors.white24, width: 1.5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/google-wallet.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "Afegeix a Google Wallet",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.notoSerif(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
