import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import '../controller/event_controller.dart';
import '../controller/auth_controller.dart';
import '../models/event_model.dart';
import '../theme/app_theme.dart';
import '../widgets/event_card.dart';
import '../widgets/events_empty_state.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isCalendarView = true;
  bool _showOnlyMyEvents = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventCtrl = context.read<EventController>();
      final authCtrl = context.read<AuthController>();

      final email =
          authCtrl.currentUser?.email ?? authCtrl.userData['email'] ?? '';
      eventCtrl.loadEvents(email: email.isNotEmpty ? email : null);
      if (email.isNotEmpty) {
        eventCtrl.loadMyEvents(email);
      }
    });
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<EventModel> _getEventsForDay(DateTime day, List<EventModel> eventsList) {
    return eventsList.where((ev) {
      final pDate = ev.parsedDateBegin;
      return pDate != null && _isSameDay(pDate, day);
    }).toList();
  }

  bool _isUserRegistered(EventModel ev, List<Map<String, dynamic>> myEvents) {
    return ev.isRegistered || myEvents.any((m) => m['event_id'] == ev.id);
  }

  @override
  Widget build(BuildContext context) {
    final eventCtrl = context.watch<EventController>();
    final authCtrl = context.watch<AuthController>();

    final userEmail =
        authCtrl.currentUser?.email ?? authCtrl.userData['email'] ?? '';
    final userName =
        authCtrl.currentUser?.name ?? authCtrl.userData['name'] ?? '';

    final allEvents = eventCtrl.events;
    final registeredEvents = allEvents
        .where((ev) => _isUserRegistered(ev, eventCtrl.myEvents))
        .toList();

    final baseEvents = _showOnlyMyEvents ? registeredEvents : allEvents;

    final selectedEvents = _selectedDay != null
        ? _getEventsForDay(_selectedDay!, baseEvents)
        : baseEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          "Esdeveniments Comercials",
          style: GoogleFonts.notoSerif(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isCalendarView
                  ? Icons.view_list_rounded
                  : Icons.calendar_month_rounded,
            ),
            tooltip: _isCalendarView ? "Veure com a llista" : "Veure calendari",
            onPressed: () {
              setState(() {
                _isCalendarView = !_isCalendarView;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await eventCtrl.loadEvents(email: userEmail.isNotEmpty ? userEmail : null);
          if (userEmail.isNotEmpty) {
            await eventCtrl.loadMyEvents(userEmail);
          }
        },
        child: eventCtrl.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Selector de Pestaña / Filtro (Tots / Els meus)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showOnlyMyEvents = false;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: !_showOnlyMyEvents
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Tots els esdeveniments (${allEvents.length})",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: !_showOnlyMyEvents
                                        ? Colors.white
                                        : AppColors.neutral,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showOnlyMyEvents = true;
                                });
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: _showOnlyMyEvents
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  "Els meus esdeveniments (${registeredEvents.length})",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: _showOnlyMyEvents
                                        ? Colors.white
                                        : AppColors.neutral,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isCalendarView) ...[
                    Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TableCalendar<EventModel>(
                          firstDay: DateTime.utc(2024, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) =>
                              _isSameDay(_selectedDay, day),
                          eventLoader: (day) =>
                              _getEventsForDay(day, baseEvents),
                          onDaySelected: (selectedDay, focusedDay) async {
                            final isDeselecting =
                                _isSameDay(_selectedDay, selectedDay);
                            final formattedDate =
                                "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";

                            setState(() {
                              _selectedDay = isDeselecting ? null : selectedDay;
                              _focusedDay = focusedDay;
                            });

                            if (isDeselecting) {
                              await context.read<EventController>().loadEvents(email: userEmail.isNotEmpty ? userEmail : null);
                            } else {
                              await context
                                  .read<EventController>()
                                  .loadEvents(
                                    startDate: formattedDate,
                                    endDate: formattedDate,
                                    email: userEmail.isNotEmpty ? userEmail : null,
                                  );
                            }
                          },
                          onFormatChanged: (format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.secondary.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          headerStyle: HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: true,
                            formatButtonShowsNext: false,
                            formatButtonDecoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            formatButtonTextStyle: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            titleTextStyle: GoogleFonts.notoSerif(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDay != null
                                ? "Esdeveniments el ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}"
                                : _showOnlyMyEvents
                                    ? "Els meus esdeveniments (${registeredEvents.length})"
                                    : "Esdeveniments actius (${allEvents.length})",
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (_selectedDay != null)
                            TextButton.icon(
                              onPressed: () async {
                                setState(() {
                                  _selectedDay = null;
                                });
                                await context.read<EventController>().loadEvents(email: userEmail.isNotEmpty ? userEmail : null);
                              },
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text("Veure tots"),
                            ),
                        ],
                      ),
                    ),
                  ],
                  Expanded(
                    child: selectedEvents.isEmpty
                        ? EventsEmptyState(
                            message: _selectedDay != null
                                ? "No hi ha cap esdeveniment per a aquest dia seleccionat."
                                : _showOnlyMyEvents
                                    ? "Encara no t'has inscrit a cap esdeveniment."
                                    : "No hi ha esdeveniments disponibles.",
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: selectedEvents.length,
                            itemBuilder: (context, index) {
                              final ev = selectedEvents[index];
                              return EventCard(
                                event: ev,
                                userEmail: userEmail,
                                userName: userName,
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }
}
