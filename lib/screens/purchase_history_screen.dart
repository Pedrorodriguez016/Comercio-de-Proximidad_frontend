import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/auth_controller.dart';
import '../services/purchase_service.dart';
import '../services/commerce_service.dart';
import '../theme/app_theme.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({super.key});

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  final PurchaseService _purchaseService = PurchaseService();
  final CommerceService _commerceService = CommerceService();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _purchases = [];
  bool _isLoading = true;
  bool _isLoadMoreLoading = false;
  bool _hasMore = true;
  int _skip = 0;
  static const int _limit = 15;

  // Caché de nombres de comercios para evitar llamadas repetidas
  final Map<String, String> _commerceNames = {};
  final Set<String> _loadingCommerceIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialPurchases();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMorePurchases();
    }
  }

  Future<void> _loadInitialPurchases() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _skip = 0;
      _hasMore = true;
      _purchases = [];
    });

    final authController = context.read<AuthController>();
    final userId = authController.userData['_id'] ?? authController.userData['id'];

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final results = await _purchaseService.getPurchaseHistory(
      userId: userId,
      skip: _skip,
      limit: _limit,
    );

    if (mounted) {
      setState(() {
        _purchases = results;
        _isLoading = false;
        if (results.length < _limit) {
          _hasMore = false;
        }
      });
    }
  }

  Future<void> _loadMorePurchases() async {
    if (_isLoadMoreLoading || !_hasMore || _isLoading) return;

    setState(() {
      _isLoadMoreLoading = true;
    });

    final authController = context.read<AuthController>();
    final userId = authController.userData['_id'] ?? authController.userData['id'];

    if (userId == null) {
      setState(() {
        _isLoadMoreLoading = false;
      });
      return;
    }

    _skip = _purchases.length;
    final results = await _purchaseService.getPurchaseHistory(
      userId: userId,
      skip: _skip,
      limit: _limit,
    );

    if (mounted) {
      setState(() {
        _isLoadMoreLoading = false;
        if (results.isEmpty) {
          _hasMore = false;
        } else {
          _purchases.addAll(results);
          if (results.length < _limit) {
            _hasMore = false;
          }
        }
      });
    }
  }

  void _loadCommerceName(String commerceId) async {
    if (_commerceNames.containsKey(commerceId) || _loadingCommerceIds.contains(commerceId)) {
      return;
    }

    _loadingCommerceIds.add(commerceId);

    final commerceData = await _commerceService.getCommerceById(commerceId);
    if (commerceData != null && mounted) {
      setState(() {
        _commerceNames[commerceId] = commerceData['name'] ?? 'Comerç sense nom';
        _loadingCommerceIds.remove(commerceId);
      });
    } else if (mounted) {
      setState(() {
        _commerceNames[commerceId] = 'Comerç Associat';
        _loadingCommerceIds.remove(commerceId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        onRefresh: _loadInitialPurchases,
        color: AppColors.primary,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : _purchases.isEmpty
                ? _buildEmptyState()
                : _buildPurchaseList(),
      ),
    );
  }

  Widget _buildPurchaseList() {
    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: _purchases.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _purchases.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final purchase = _purchases[index];
        final rawCommerce = purchase['commerce'];
        final String date = purchase['date']?.toString() ?? 'Data no disponible';
        final double amount = (purchase['amount'] as num?)?.toDouble() ?? 0.0;
        final int points = (purchase['points'] as num?)?.toInt() ?? 0;

        String commerceName = 'Comerç Associat';
        if (rawCommerce is Map) {
          commerceName = rawCommerce['name']?.toString() ?? 'Comerç sense nom';
        } else if (rawCommerce is List && rawCommerce.isNotEmpty) {
          final first = rawCommerce.first;
          if (first is Map) {
            commerceName = first['name']?.toString() ?? 'Comerç sense nom';
          }
        } else if (rawCommerce is String && rawCommerce.isNotEmpty) {
          final String commerceId = rawCommerce;
          if (_commerceNames.containsKey(commerceId)) {
            commerceName = _commerceNames[commerceId]!;
          } else {
            commerceName = 'Carregant comerç...';
            _loadCommerceName(commerceId);
          }
        } else {
          commerceName = 'Comerç General';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      commerceName,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onBackground,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${amount.toStringAsFixed(2)} €",
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "+$points pts",
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
              color: AppColors.neutral.withOpacity(0.3),
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
