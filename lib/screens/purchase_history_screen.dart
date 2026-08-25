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
    final email = _getUserEmail();
    context.read<PurchaseController>().loadInitialPurchases(email);
  }

  String _getUserEmail() {
    final authController = context.read<AuthController>();
    return authController.currentUser?.email ??
        authController.userData['email']?.toString() ??
        '';
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final email = _getUserEmail();
      context.read<PurchaseController>().loadMorePurchases(email);
    }
  }

  Future<void> _showCustomDateModal() async {
    final purchaseController = context.read<PurchaseController>();
    DateTime? tempStart = purchaseController.startDate ?? DateTime.now().subtract(const Duration(days: 30));
    DateTime? tempEnd = purchaseController.endDate ?? DateTime.now();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            String formatDate(DateTime? dt) {
              if (dt == null) return "Seleccionar";
              return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
            }

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "Filtrar per dates",
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onBackground,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempStart ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempStart = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Data d'inici",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatDate(tempStart),
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempEnd ?? DateTime.now(),
                              firstDate: tempStart ?? DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) {
                              setModalState(() {
                                tempEnd = picked;
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Data de fi",
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    color: AppColors.neutral,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      formatDate(tempEnd),
                                      style: GoogleFonts.manrope(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.onBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            final email = _getUserEmail();
                            purchaseController.setFilter(DateFilterType.all, email);
                          },
                          child: Text(
                            "Netejar",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            final email = _getUserEmail();
                            purchaseController.setFilter(
                              DateFilterType.custom,
                              email,
                              customStart: tempStart,
                              customEnd: tempEnd,
                            );
                          },
                          child: Text(
                            "Aplicar Filtre",
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
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
      body: Column(
        children: [
          _buildDateFilterChips(purchaseController),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadData(),
              color: AppColors.primary,
              child: purchaseController.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : purchaseController.purchases.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          itemCount:
                              purchaseController.purchases.length +
                              (purchaseController.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == purchaseController.purchases.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }

                            final purchase = purchaseController.purchases[index];
                            if (purchase.commerceName.isEmpty &&
                                purchase.commerceId.isNotEmpty) {
                              purchaseController.fetchCommerceNameIfNeeded(
                                purchase.commerceId,
                              );
                            }

                            final resolvedName =
                                purchaseController.commerceNames[purchase.commerceId];

                            return PurchaseCard(
                              purchase: purchase,
                              resolvedCommerceName: resolvedName,
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilterChips(PurchaseController controller) {
    final email = _getUserEmail();
    final selected = controller.selectedFilter;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildFilterChip(
            label: "Tots",
            isSelected: selected == DateFilterType.all,
            onTap: () => controller.setFilter(DateFilterType.all, email),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Últims 7 dies",
            isSelected: selected == DateFilterType.last7Days,
            onTap: () => controller.setFilter(DateFilterType.last7Days, email),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: "Aquest mes",
            isSelected: selected == DateFilterType.thisMonth,
            onTap: () => controller.setFilter(DateFilterType.thisMonth, email),
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: selected == DateFilterType.custom && controller.startDate != null
                ? "${controller.startDate!.day}/${controller.startDate!.month} - ${controller.endDate!.day}/${controller.endDate!.month}"
                : "Personalitzat 📅",
            isSelected: selected == DateFilterType.custom,
            onTap: () => _showCustomDateModal(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.onBackground,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.black12,
        ),
      ),
      elevation: isSelected ? 2 : 0,
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.6,
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
              "No s'han trobat compres en el rang de dates seleccionat.",
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
