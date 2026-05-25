import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/commerce_controller.dart';
import '../controller/navigation_controller.dart';
import '../theme/app_theme.dart';
import 'commerce_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Sincronizamos el texto de búsqueda inicial sin disparar llamada de red
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commerceController = context.read<CommerceController>();
      _searchController.text = commerceController.searchQuery;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<CommerceController>().loadMoreCommerces();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commerceController = context.watch<CommerceController>();
    final navController = context.watch<NavigationController>();

    // Cargar comercios de forma perezosa solo cuando la pantalla es visible (index 1)
    if (navController.currentIndex == 1 &&
        commerceController.commerces.isEmpty &&
        !commerceController.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          commerceController.searchCommerces();
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(commerceController),
            _buildSearchBar(commerceController),
            if (commerceController.selectedCategory.isNotEmpty)
              _buildCategoryBadge(commerceController),
            Expanded(
              child: commerceController.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : commerceController.commerces.isEmpty
                      ? _buildEmptyState()
                      : _buildResultsList(commerceController.commerces),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(CommerceController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Buscar Comerços",
            style: GoogleFonts.notoSerif(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          if (controller.selectedCategory.isNotEmpty || controller.searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.secondary),
              onPressed: () {
                _searchController.clear();
                controller.clearFilters();
              },
            )
        ],
      ),
    );
  }

  Widget _buildSearchBar(CommerceController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (value) => controller.searchCommerces(query: value, category: ''),
          decoration: InputDecoration(
            hintText: "Nom del comerç...",
            hintStyle: GoogleFonts.manrope(color: AppColors.neutral.withOpacity(0.5)),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(CommerceController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        children: [
          Chip(
            label: Text(_getTranslatedCategory(controller.selectedCategory)),
            onDeleted: () => controller.clearFilters(),
            backgroundColor: AppColors.secondary.withOpacity(0.1),
            labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
            deleteIconColor: AppColors.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<dynamic> commerces) {
    final commerceController = context.watch<CommerceController>();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      itemCount: commerces.length + (commerceController.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == commerces.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        final commerce = commerces[index];
        return _buildCommerceCard(commerce);
      },
    );
  }

  Widget _buildCommerceCard(dynamic commerce) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommerceDetailScreen(commerce: commerce),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                _getCategoryIcon(commerce['type'] ?? ''),
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    commerce['name'] ?? 'Sense nom',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getTranslatedCategory(commerce['type'] ?? 'General'),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.neutral),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: AppColors.neutral.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            "No hem trobat res",
            style: GoogleFonts.manrope(
              fontSize: 18,
              color: AppColors.neutral,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedCategory(String type) {
    switch (type.toLowerCase()) {
      case 'alimentación': return 'Alimentació';
      case 'ropa': return 'Roba';
      case 'cultura': return 'Cultura';
      case 'servicios': return 'Serveis';
      case 'restauración': return 'Restauració';
      case 'salud': return 'Salut';
      default: return type;
    }
  }

  IconData _getCategoryIcon(String type) {
    switch (type.toLowerCase()) {
      case 'alimentación': return Icons.restaurant;
      case 'ropa': return Icons.shopping_bag;
      case 'cultura': return Icons.book;
      case 'servicios': return Icons.build;
      case 'restauración': return Icons.coffee;
      case 'salud': return Icons.medical_services;
      default: return Icons.store;
    }
  }
}
