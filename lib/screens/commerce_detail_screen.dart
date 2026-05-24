import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/commerce_info_card.dart';
import '../widgets/commerce_detail_row.dart';

class CommerceDetailScreen extends StatelessWidget {
  final dynamic commerce;

  const CommerceDetailScreen({super.key, required this.commerce});

  Future<void> _openInGoogleMaps(BuildContext context) async {
    final double? lat = commerce['latitude'] is num ? (commerce['latitude'] as num).toDouble() : null;
    final double? lng = commerce['longitude'] is num ? (commerce['longitude'] as num).toDouble() : null;
    final String address = commerce['address'] ?? '';
    final String name = commerce['name'] ?? '';

    Uri url;
    if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
      // Usar coordenadas directamente
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    } else if (address.isNotEmpty) {
      // Fallback a buscar por dirección y nombre
      final String query = '$name, $address, Barcelona';
      url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay información de ubicación disponible')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el mapa: $e')),
      );
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

  Color _getCategoryColor(String type) {
    switch (type.toLowerCase()) {
      case 'alimentación': return AppColors.primary;
      case 'ropa': return AppColors.secondary;
      case 'restauración': return const Color(0xFFE0533C);
      case 'servicios': return const Color(0xFF4CA64C);
      default: return AppColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = commerce['name'] ?? 'Comercio sin nombre';
    final String type = commerce['type'] ?? 'General';
    final String address = commerce['address'] ?? 'Dirección no disponible';
    final String neighborhood = commerce['neighborhood'] ?? 'Barrio no disponible';
    final String district = commerce['district'] ?? 'Distrito no disponible';
    final double? lat = commerce['latitude'] is num ? (commerce['latitude'] as num).toDouble() : null;
    final double? lng = commerce['longitude'] is num ? (commerce['longitude'] as num).toDouble() : null;

    final Color themeColor = _getCategoryColor(type);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar con efecto Hero / Gradient
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.9),
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
                  // Fondo decorativo con gradiente premium
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeColor.withOpacity(0.85),
                          AppColors.primary,
                        ],
                      ),
                    ),
                  ),
                  // Patrón sutil o icono de fondo gigante
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
                  // Gradiente inferior para legibilidad del título si es necesario
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
          
          // Contenido de la pantalla
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
                    // Fila de Categoría y Estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: themeColor.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getCategoryIcon(type), size: 16, color: themeColor),
                              const SizedBox(width: 6),
                              Text(
                                type,
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
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Abierto",
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
                    
                    // Nombre del Comercio
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
                    
                    // Tarjeta: Información de Dirección
                    CommerceInfoCard(
                      title: "Ubicación",
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.secondary,
                      children: [
                        CommerceDetailRow(icon: Icons.map, label: "Dirección", value: address),
                        CommerceDetailRow(icon: Icons.holiday_village, label: "Barrio", value: neighborhood),
                        CommerceDetailRow(icon: Icons.domain, label: "Distrito", value: district),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Tarjeta: Coordenadas e Integración del Mapa
                    CommerceInfoCard(
                      title: "Detalles del Comercio",
                      icon: Icons.info_outline,
                      iconColor: AppColors.primary,
                      children: [
                        CommerceDetailRow(
                          icon: Icons.person_outline, 
                          label: "Propietario", 
                          value: commerce['owner'] != null ? "Asociado a la red local" : "Pendiente de registro"
                        ),
                        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) ...[
                          CommerceDetailRow(icon: Icons.explore_outlined, label: "Coordenadas", value: "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}"),
                        ],
                      ],
                    ),
                    const SizedBox(height: 35),
                    
                    // Botones de acción principales
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
                            icon: const Icon(Icons.map),
                            label: Text(
                              "Ver en Google Maps",
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

}
