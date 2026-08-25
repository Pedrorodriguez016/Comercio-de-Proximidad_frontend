import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controller/auth_controller.dart';
import '../controller/commerce_controller.dart';
import '../theme/app_theme.dart';

class UserPassScreen extends StatefulWidget {
  const UserPassScreen({super.key});

  @override
  State<UserPassScreen> createState() => _UserPassScreenState();
}

class _UserPassScreenState extends State<UserPassScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final email = auth.userData['email'] ?? auth.userData['preferred_username'];
      final customerId = auth.userData['odoo_partner_id'] ?? auth.userData['customer_id'] ?? auth.userData['odoo_id'];
      
      int? odooId;
      if (customerId != null) {
        if (customerId is int) {
          odooId = customerId;
        } else {
          odooId = int.tryParse(customerId.toString());
        }
      }

      context.read<CommerceController>().fetchLoyaltyPoints(
        customerId: odooId,
        email: email,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final commerceController = context.watch<CommerceController>();
    final userData = authController.userData;
    
    final String registeredCity = (userData['city']?.toString().isNotEmpty == true
            ? userData['city']
            : (authController.currentUser?.city.isNotEmpty == true
                ? authController.currentUser!.city
                : 'Calella')).toString().trim();

    final String userId = userData['id'] ?? userData['_id'] ?? 'Unknown ID';
    final String userName = userData['name'] ?? authController.currentUser?.name ?? 'Usuari';
    final String userEmail = userData['email'] ?? authController.currentUser?.email ?? '';
    
    final double userPoints = commerceController.loyaltyPoints;

    final String bgImage = registeredCity.toLowerCase().contains('barcelona')
        ? 'assets/images/park_guell.jpg'
        : 'assets/images/faro_calella.jpg';

    print("USER_PASS_SCREEN: city en userData = '${userData['city']}', registeredCity = '$registeredCity'");

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
                constraints: const BoxConstraints(maxWidth: 420), // Ancho máximo ideal para web y tablets
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
                      height: 220,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(bgImage),
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.0, -0.15), // Encuadra mejor la parte superior y cuerpo del faro
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0x99000000), // Negro al 60% abajo para dar contraste a los puntos
                              Color(0x33000000), // Negro al 20% arriba para dejar ver el faro y el cielo natural
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32),
                            topRight: Radius.circular(32),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                Text(
                                  registeredCity.toUpperCase(),
                                  style: GoogleFonts.manrope(
                                    color: AppColors.tertiary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                commerceController.isPointsLoading
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "ELS MEUS PUNTS",
                                            style: GoogleFonts.manrope(
                                              color: Colors.white54,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          const SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : _buildStatItem("ELS MEUS PUNTS", "${userPoints.toInt()} pts"),
                                _buildStatItem("ESTAT", "Actiu"),
                              ],
                            ),
                          ],
                        ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        children: [
                          QrImageView(
                            data: "MERCATUS:$userId|$userName|$userEmail",
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  const SizedBox(width: 10),
                                  Flexible(
                                    child: Text(
                                      "Afegeix a Google Wallet",
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
