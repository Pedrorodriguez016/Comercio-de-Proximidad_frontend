import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import '../controller/event_controller.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final String userEmail;
  final String userName;

  const EventCard({
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    event.name,
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (isRegistered)
                  const Chip(
                    avatar: Icon(Icons.check_circle, color: Colors.white, size: 16),
                    label: Text(
                      "Inscrit",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.green,
                  )
                else if (isExpired)
                  const Chip(
                    avatar: Icon(Icons.history, color: Colors.white, size: 16),
                    label: Text(
                      "Finalitzat",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.grey,
                  )
                else if (isFull)
                  const Chip(
                    avatar: Icon(Icons.person_off, color: Colors.white, size: 16),
                    label: Text(
                      "Completat",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (event.description.isNotEmpty) ...[
              HtmlWidget(
                event.description,
                textStyle: GoogleFonts.manrope(
                  fontSize: 14,
                  color: AppColors.neutral,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  event.address,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.storefront_outlined,
                    size: 18, color: AppColors.secondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    event.organizer,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (event.dateBegin != null && event.dateBegin!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildDateInfo(event),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isDisabled
                    ? null
                    : () async {
                        if (userEmail.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Has d'estar autenticat.")),
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
                                ok
                                    ? "Inscripció realitzada amb èxit!"
                                    : "Error en la inscripció.",
                              ),
                              backgroundColor:
                                  ok ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(EventModel event) {
    final start = event.parsedDateBegin;
    if (start == null) {
      return Row(
        children: [
          const Icon(Icons.calendar_today_outlined,
              size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            event.dateBegin!,
            style: GoogleFonts.manrope(
                fontSize: 12, color: AppColors.neutral),
          ),
        ],
      );
    }

    final end = event.parsedDateEnd;
    final dayStr =
        "${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year}";
    final startTimeStr =
        "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}";

    String timeStr = startTimeStr;
    if (end != null) {
      final endTimeStr =
          "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}";
      timeStr = "$startTimeStr - $endTimeStr";
    }

    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              "Dia: ",
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              dayStr,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.access_time_outlined,
                size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              "Hora: ",
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              timeStr,
              style: GoogleFonts.manrope(
                fontSize: 13,
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
