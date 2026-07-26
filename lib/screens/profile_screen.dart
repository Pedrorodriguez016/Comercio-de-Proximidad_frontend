import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/auth_controller.dart';
import '../controller/commerce_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_menu_item.dart';
import 'purchase_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPoints();
    });
  }

  void _refreshPoints() {
    final auth = context.read<AuthController>();
    final user = auth.currentUser;
    final email = user?.email.isNotEmpty == true
        ? user!.email
        : (auth.userData['email'] ?? auth.userData['preferred_username']);
    final customerId = user?.odooPartnerId ??
        auth.userData['odoo_partner_id'] ??
        auth.userData['customer_id'] ??
        auth.userData['odoo_id'];

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
          email: email?.toString(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final commerceController = context.watch<CommerceController>();
    final user = authController.currentUser;

    final String displayName = user?.name.isNotEmpty == true
        ? user!.name
        : (authController.userData['name'] ?? 'Usuari Demo');
    final String displayEmail = user?.email.isNotEmpty == true
        ? user!.email
        : (authController.userData['email'] ?? 'demo@comercio.local');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "El meu Perfil",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await authController.refreshUserData();
          _refreshPoints();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                displayName,
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                displayEmail,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF3D5F4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "PUNTS ACUMULATS",
                              style: GoogleFonts.manrope(
                                color: AppColors.tertiary.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${commerceController.loyaltyPoints.toStringAsFixed(0)} pts",
                              style: GoogleFonts.notoSerif(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stars,
                            color: AppColors.secondary,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/user-pass'),
                      icon: const Icon(Icons.qr_code, color: AppColors.primary),
                      label: Text(
                        "VEURE EL MEU PAS",
                        style: GoogleFonts.manrope(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              ProfileMenuItem(
                icon: Icons.history,
                title: "Historial de compres",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurchaseHistoryScreen()),
                ),
              ),
              ProfileMenuItem(
                icon: Icons.notifications_none,
                title: "Notificacions",
              ),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: "Configuració",
              ),
              const SizedBox(height: 16),

              ProfileMenuItem(
                icon: Icons.logout,
                title: "Tancar sessió",
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  authController.logout();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
