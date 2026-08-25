import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/commerce_model.dart';
import '../theme/app_theme.dart';
import '../widgets/commerce_info_card.dart';
import '../widgets/commerce_detail_row.dart';
import '../widgets/commerce_map_view.dart';

class CommerceDetailScreen extends StatelessWidget {
  final CommerceModel commerce;

  const CommerceDetailScreen({super.key, required this.commerce});

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final double? lat = commerce.latitude;
    final double? lng = commerce.longitude;
    final String address = commerce.address;
    final String name = commerce.name;

    Uri url;
    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else if (address.isNotEmpty) {
      final String query = '$name, $address, Barcelona';
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hi ha informació de la ubicació disponible')),
      );
      return;
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No s'ha pogut obrir el mapa: $e")),
      );
    }
  }

  IconData _getCategoryIcon(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('aliment')) {
      return Icons.restaurant;
    } else if (lower.contains('ropa') || lower.contains('roba')) {
      return Icons.shopping_bag;
    } else if (lower.contains('cultur')) {
      return Icons.book;
    } else if (lower.contains('servei') || lower.contains('servicio')) {
      return Icons.build;
    } else if (lower.contains('restaurac')) {
      return Icons.coffee;
    } else if (lower.contains('salu')) {
      return Icons.medical_services;
    }
    return Icons.store;
  }

  Color _getCategoryColor(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('aliment')) {
      return AppColors.primary;
    } else if (lower.contains('ropa') || lower.contains('roba')) {
      return AppColors.secondary;
    } else if (lower.contains('restaurac')) {
      return const Color(0xFFE0533C);
    } else if (lower.contains('servei') || lower.contains('servicio')) {
      return const Color(0xFF4CA64C);
    }
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final String name = commerce.name;
    final String type = commerce.category;
    final String address = commerce.address;
    final String neighborhood = commerce.neighborhood.isNotEmpty ? commerce.neighborhood : 'Barri no disponible';
    final String district = commerce.district.isNotEmpty ? commerce.district : 'Districte no disponible';
    final double? lat = commerce.latitude;
    final double? lng = commerce.longitude;

    final Color themeColor = _getCategoryColor(type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeColor.withValues(alpha: 0.85),
                          AppColors.primary,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    bottom: -20,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        _getCategoryIcon(type),
                        size: 220,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black26,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: themeColor.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(type), size: 16, color: themeColor),
                              const SizedBox(width: 6),
                              Text(
                                _getTranslatedCategory(type),
                                style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Obert",
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: GoogleFonts.notoSerif(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 25),
                    CommerceInfoCard(
                      title: "Ubicació",
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.secondary,
                      children: [
                        CommerceDetailRow(icon: Icons.map_outlined, label: "Adreça", value: address),
                        if (commerce.eixComercialName != null && commerce.eixComercialName!.isNotEmpty)
                          CommerceDetailRow(
                            icon: Icons.storefront_outlined,
                            label: "Eix Comercial",
                            value: commerce.eixComercialName!,
                          ),
                        if (commerce.neighborhood.isNotEmpty)
                          CommerceDetailRow(icon: Icons.holiday_village_outlined, label: "Barri", value: neighborhood),
                        const SizedBox(height: 15),
                        CommerceMapView(
                          latitude: lat ?? 0.0,
                          longitude: lng ?? 0.0,
                          address: address,
                          markerColor: themeColor,
                          height: 200,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) ...[
                      CommerceInfoCard(
                        title: "Detalls del Comerç",
                        icon: Icons.info_outline,
                        iconColor: AppColors.primary,
                        children: [
                          CommerceDetailRow(
                            icon: Icons.explore_outlined,
                            label: "Coordenades",
                            value: "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}",
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 35),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () => _openInGoogleMaps(context),
                            icon: const Icon(Icons.navigation),
                            label: Text(
                              "Obrir a Google Maps",
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedCategory(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('aliment')) {
      return 'Alimentació';
    } else if (lower.contains('ropa') || lower.contains('roba')) {
      return 'Roba';
    } else if (lower.contains('cultur')) {
      return 'Cultura';
    } else if (lower.contains('servei') || lower.contains('servicio')) {
      return 'Serveis';
    } else if (lower.contains('restaurac')) {
      return 'Restauració';
    } else if (lower.contains('salu')) {
      return 'Salut';
    }
    return type;
  }
}
