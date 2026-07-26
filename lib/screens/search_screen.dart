import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controller/commerce_controller.dart';
import '../controller/navigation_controller.dart';
import '../models/commerce_model.dart';
import '../widgets/commerce_card.dart';
import '../widgets/search_filter_sheet.dart';
import '../theme/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final commerceController = context.read<CommerceController>();
      _searchController.text = commerceController.searchQuery;
      commerceController.fetchEixosComercials();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CommerceController>().loadMoreCommerces();
    }
  }

  @override
  Widget build(BuildContext context) {
    final commerceController = context.watch<CommerceController>();
    final navController = context.watch<NavigationController>();

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
            SearchFilterSheet(
              controller: commerceController,
              searchController: _searchController,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: commerceController.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary))
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
          if (controller.selectedEixId != null ||
              controller.selectedDistrict.isNotEmpty ||
              controller.selectedCategory.isNotEmpty ||
              controller.searchQuery.isNotEmpty)
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
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onSubmitted: (value) => controller.searchCommerces(query: value),
          decoration: InputDecoration(
            hintText: "Nom del comerç...",
            hintStyle: GoogleFonts.manrope(
                color: AppColors.neutral.withValues(alpha: 0.5)),
            prefixIcon: const Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList(List<CommerceModel> commerces) {
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
        return CommerceCard(commerce: commerce);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.neutral.withValues(alpha: 0.3),
          ),
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
}
