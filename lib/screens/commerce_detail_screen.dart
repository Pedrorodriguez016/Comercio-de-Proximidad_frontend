import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/commerce_info_card.dart';
import '../widgets/commerce_detail_row.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No s'ha pogut obrir el mapa: $e")),
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
    final String name = commerce['name'] ?? 'Comerç sense nom';
    final String type = commerce['type'] ?? 'General';
    final String address = commerce['address'] ?? 'Adreça no disponible';
    final String neighborhood = commerce['neighborhood'] ?? 'Barri no disponible';
    final String district = commerce['district'] ?? 'Districte no disponible';
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
                            color: Colors.green.withOpacity(0.12),
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
                      title: "Ubicació",
                      icon: Icons.location_on_outlined,
                      iconColor: AppColors.secondary,
                      children: [
                        CommerceDetailRow(icon: Icons.map, label: "Adreça", value: address),
                        CommerceDetailRow(icon: Icons.holiday_village, label: "Barri", value: neighborhood),
                        CommerceDetailRow(icon: Icons.domain, label: "Districte", value: district),
                        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) ...[
                          const SizedBox(height: 15),
                          SizedBox(
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(lat, lng),
                                  initialZoom: 15.0,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app_tfg',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(lat, lng),
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          Icons.location_on,
                                          color: themeColor,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Tarjeta: Coordenadas e Integración del Mapa
                    CommerceInfoCard(
                      title: "Detalls del Comerç",
                      icon: Icons.info_outline,
                      iconColor: AppColors.primary,
                      children: [
                        CommerceDetailRow(
                          icon: Icons.person_outline, 
                          label: "Propietari", 
                          value: commerce['owner'] != null ? "Associat a la xarxa local" : "Pendent de registre"
                        ),
                        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) ...[
                          CommerceDetailRow(icon: Icons.explore_outlined, label: "Coordenades", value: "${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}"),
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
}
