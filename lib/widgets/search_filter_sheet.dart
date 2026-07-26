import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/commerce_controller.dart';
import '../models/eix_comercial_model.dart';
import '../theme/app_theme.dart';

class SearchFilterSheet extends StatelessWidget {
  final CommerceController controller;
  final TextEditingController searchController;

  const SearchFilterSheet({
    super.key,
    required this.controller,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Dropdown Filters Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      hint: Text(
                        "Eix Comercial",
                        style: GoogleFonts.manrope(fontSize: 14, color: AppColors.neutral),
                      ),
                      value: controller.selectedEixId,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text("Tots els eixos", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                        ...controller.eixosComercials.map((EixComercialModel e) {
                          return DropdownMenuItem<int>(
                            value: e.id,
                            child: Text(
                              e.name,
                              style: GoogleFonts.manrope(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        controller.searchCommerces(eixId: val ?? -1);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: Text(
                        "Tipus de Comerç",
                        style: GoogleFonts.manrope(fontSize: 14, color: AppColors.neutral),
                      ),
                      value: controller.selectedCategory.isEmpty ? null : controller.selectedCategory,
                      isExpanded: true,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text("Tots els tipus", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                        DropdownMenuItem<String>(
                          value: "Alimentació",
                          child: Text("Alimentació", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                        DropdownMenuItem<String>(
                          value: "Roba",
                          child: Text("Roba", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                        DropdownMenuItem<String>(
                          value: "Restauració",
                          child: Text("Restauració", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                        DropdownMenuItem<String>(
                          value: "Serveis",
                          child: Text("Serveis", style: GoogleFonts.manrope(fontSize: 14)),
                        ),
                      ],
                      onChanged: (val) {
                        controller.searchCommerces(category: val ?? "");
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Active Filter Badges
        _buildActiveFiltersBadge(context),
      ],
    );
  }

  Widget _buildActiveFiltersBadge(BuildContext context) {
    final List<Widget> filterChips = [];

    if (controller.selectedEixId != null) {
      EixComercialModel? eix;
      try {
        eix = controller.eixosComercials.firstWhere((e) => e.id == controller.selectedEixId);
      } catch (_) {
        eix = null;
      }
      if (eix != null) {
        filterChips.add(
          Chip(
            label: Text(eix.name),
            onDeleted: () => controller.searchCommerces(eixId: -1),
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
            deleteIconColor: AppColors.secondary,
          ),
        );
      }
    }

    if (controller.selectedCategory.isNotEmpty) {
      filterChips.add(
        Chip(
          label: Text(controller.selectedCategory),
          onDeleted: () => controller.searchCommerces(category: ""),
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          deleteIconColor: AppColors.secondary,
        ),
      );
    }

    if (controller.selectedDistrict.isNotEmpty) {
      filterChips.add(
        Chip(
          label: Text(controller.selectedDistrict),
          onDeleted: () => controller.searchCommerces(district: ""),
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          deleteIconColor: AppColors.secondary,
        ),
      );
    }

    if (controller.searchQuery.isNotEmpty) {
      filterChips.add(
        Chip(
          label: Text('"${controller.searchQuery}"'),
          onDeleted: () {
            searchController.clear();
            controller.searchCommerces(query: "");
          },
          backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
          labelStyle: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
          deleteIconColor: AppColors.secondary,
        ),
      );
    }

    if (filterChips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: filterChips,
            ),
          ),
        ],
      ),
    );
  }
}
