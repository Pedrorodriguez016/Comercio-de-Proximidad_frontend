import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import '../controller/event_controller.dart';
import '../widgets/commerce_map_view.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  final String userEmail;
  final String userName;

  const EventDetailScreen({
    super.key,
    required this.event,
    required this.userEmail,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final eventCtrl = context.watch<EventController>();
    final isRegistered = event.isRegistered ||
        eventCtrl.myEvents.any((m) => m['event_id'] == event.id);
    final isExpired = eventCtrl.isEventExpired(event);
    final isFull = eventCtrl.isEventFull(event);
    final isDisabled = isRegistered || isExpired || isFull;

    final start = event.parsedDateBegin;
    final end = event.parsedDateEnd;

    final dayStr = start != null
        ? "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}"
        : event.dateBegin ?? "Sense data";

    final startTimeStr = start != null
        ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}"
        : "";

    String timeStr = startTimeStr;
    if (start != null && end != null) {
      final endTimeStr =
          "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
      timeStr = "$startTimeStr - $endTimeStr";
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Detall de l'Esdeveniment",
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Status Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          event.name,
                          style: GoogleFonts.notoSerif(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isRegistered)
                        const Chip(
                          avatar: Icon(Icons.check_circle, color: Colors.white, size: 16),
                          label: Text("Inscrit", style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.green,
                        )
                      else if (isExpired)
                        const Chip(
                          avatar: Icon(Icons.history, color: Colors.white, size: 16),
                          label: Text("Finalitzat", style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.grey,
                        )
                      else if (isFull)
                        const Chip(
                          avatar: Icon(Icons.person_off, color: Colors.white, size: 16),
                          label: Text("Completat", style: TextStyle(color: Colors.white, fontSize: 12)),
                          backgroundColor: Colors.orange,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info Cards (Date, Time, Organizer, Seats)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.storefront_outlined,
                          label: "Organitzador",
                          value: event.organizer,
                        ),
                        const Divider(height: 20),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: "Data",
                          value: dayStr,
                        ),
                        if (timeStr.isNotEmpty) ...[
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.access_time_outlined,
                            label: "Horari",
                            value: timeStr,
                          ),
                        ],
                        if (event.seatsMax != null && event.seatsMax! > 0) ...[
                          const Divider(height: 20),
                          _buildInfoRow(
                            icon: Icons.people_outline,
                            label: "Places disponibles",
                            value: "${event.seatsAvailable ?? 0} / ${event.seatsMax}",
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location & OpenStreetMap Section
                  Text(
                    "Ubicació",
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.address,
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CommerceMapView(
                    latitude: 0.0,
                    longitude: 0.0,
                    address: event.address,
                    markerColor: AppColors.primary,
                    height: 200,
                  ),

                  const SizedBox(height: 24),

                  // Full Description Section
                  if (event.description.isNotEmpty) ...[
                    Text(
                      "Descripció",
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: HtmlWidget(
                        event.description,
                        textStyle: GoogleFonts.manrope(
                          fontSize: 14,
                          color: AppColors.neutral,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Fixed Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isDisabled
                      ? null
                      : () async {
                          if (userEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Has d'estar autenticat.")),
                            );
                            return;
                          }

                          bool ok = await context.read<EventController>().registerToEvent(
                                event.id,
                                userEmail,
                                name: userName,
                              );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok ? "Inscripció realitzada amb èxit!" : "Error en la inscripció.",
                                ),
                                backgroundColor: ok ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: Icon(
                    isRegistered
                        ? Icons.check
                        : isExpired
                            ? Icons.event_busy
                            : isFull
                                ? Icons.block
                                : Icons.event_available,
                    color: Colors.white,
                  ),
                  label: Text(
                    isRegistered
                        ? "Ja estàs inscrit"
                        : isExpired
                            ? "Esdeveniment finalitzat"
                            : isFull
                                ? "Aforament complet"
                                : "Apuntar-me a l'Esdeveniment",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(
          "$label: ",
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.onBackground,
            ),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
