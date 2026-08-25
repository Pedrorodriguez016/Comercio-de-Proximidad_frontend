import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../controller/commerce_controller.dart';

class CommerceMapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String? address;
  final Color markerColor;
  final double height;

  const CommerceMapView({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.markerColor,
    this.height = 180,
  });

  @override
  State<CommerceMapView> createState() => _CommerceMapViewState();
}

class _CommerceMapViewState extends State<CommerceMapView> {
  final MapController _mapController = MapController();
  late double _currentLat;
  late double _currentLng;
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    _currentLat = widget.latitude;
    _currentLng = widget.longitude;

    if (_currentLat == 0.0 && _currentLng == 0.0 && widget.address != null && widget.address!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _geocodeAddress(widget.address!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CommerceMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude || widget.longitude != oldWidget.longitude) {
      setState(() {
        _currentLat = widget.latitude;
        _currentLng = widget.longitude;
      });
    } else if (_currentLat == 0.0 && _currentLng == 0.0 && widget.address != oldWidget.address && widget.address != null && widget.address!.isNotEmpty) {
      _geocodeAddress(widget.address!);
    }
  }

  Future<void> _geocodeAddress(String rawAddress) async {
    if (_isGeocoding) return;
    setState(() {
      _isGeocoding = true;
    });

    try {
      final commerceController = context.read<CommerceController>();
      final coords = await commerceController.geocodeAddress(rawAddress);

      if (coords != null && mounted) {
        final double? parsedLat = coords['lat'];
        final double? parsedLng = coords['lng'];

        if (parsedLat != null && parsedLng != null) {
          setState(() {
            _currentLat = parsedLat;
            _currentLng = parsedLng;
          });
          _mapController.move(LatLng(parsedLat, parsedLng), 16.0);
        }
      }
    } catch (e) {
      print("Geocoding error for address '$rawAddress': $e");
    } finally {
      if (mounted) {
        setState(() {
          _isGeocoding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double displayLat = (_currentLat == 0.0) ? 41.38506 : _currentLat;
    final double displayLng = (_currentLng == 0.0) ? 2.1734 : _currentLng;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(displayLat, displayLng),
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app_tfg',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(displayLat, displayLng),
                      width: 44,
                      height: 44,
                      child: Icon(
                        Icons.location_on,
                        color: widget.markerColor,
                        size: 44,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_isGeocoding)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 6),
                      Text("Buscant ubicació...", style: TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
