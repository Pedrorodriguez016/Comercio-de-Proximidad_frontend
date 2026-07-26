import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';
import '../controller/purchase_controller.dart';
import '../widgets/purchase_card.dart';
import '../theme/app_theme.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    final authController = context.read<AuthController>();
    final email = authController.currentUser?.email ??
        authController.userData['email']?.toString() ??
        '';
    context.read<PurchaseController>().loadInitialPurchases(email);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final authController = context.read<AuthController>();
      final email = authController.currentUser?.email ??
          authController.userData['email']?.toString() ??
          '';
      context.read<PurchaseController>().loadMorePurchases(email);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purchaseController = context.watch<PurchaseController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Historial de Compres",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        color: AppColors.primary,
        child: purchaseController.isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : purchaseController.purchases.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: purchaseController.purchases.length +
                        (purchaseController.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == purchaseController.purchases.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        );
                      }

                      final purchase = purchaseController.purchases[index];
                      if (purchase.commerceName.isEmpty && purchase.commerceId.isNotEmpty) {
                        purchaseController.fetchCommerceNameIfNeeded(purchase.commerceId);
                      }

                      final resolvedName = purchaseController.commerceNames[purchase.commerceId];

                      return PurchaseCard(
                        purchase: purchase,
                        resolvedCommerceName: resolvedName,
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_toggle_off_outlined,
              size: 80,
              color: AppColors.neutral.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              "Cap compra registrada",
              style: GoogleFonts.notoSerif(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Encara no has realitzat cap compra. Puja el teu primer tiquet a la secció de Compra per sumar punts.",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: AppColors.neutral,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
