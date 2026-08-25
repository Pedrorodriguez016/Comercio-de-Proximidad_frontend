import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventController with ChangeNotifier {
  final EventService _eventService = EventService();

  bool _isLoading = false;
  List<EventModel> _events = [];
  List<Map<String, dynamic>> _myEvents = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<EventModel> get events => _events;
  List<Map<String, dynamic>> get myEvents => _myEvents;
  String? get errorMessage => _errorMessage;

  /// Carrega tots els esdeveniments amb filtre de data opcional i email de l'usuari
  Future<void> loadEvents({String? startDate, String? endDate, String? email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _eventService.getEvents(
        startDate: startDate,
        endDate: endDate,
        email: email,
      );
    } catch (e) {
      _errorMessage = "No s'han pogut carregar els esdeveniments.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega els esdeveniments de l'usuari
  Future<void> loadMyEvents(String email) async {
    if (email.isEmpty) return;
    try {
      _myEvents = await _eventService.getMyEvents(email);
      notifyListeners();
    } catch (e) {
      print("EVENT_CONTROLLER: Error carregant els meus esdeveniments: $e");
    }
  }

  /// Apunta l'usuari a un esdeveniment
  Future<bool> registerToEvent(int eventId, String email, {String? name}) async {
    _isLoading = true;
    notifyListeners();

    bool success = await _eventService.registerToEvent(eventId, email, name: name);
    
    if (success) {
      // Actualitzar estat local
      int index = _events.indexWhere((e) => e.id == eventId);
      if (index != -1) {
        _events[index] = _events[index].copyWith(isRegistered: true);
      }
      await loadMyEvents(email);
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  /// Comprova si l'esdeveniment ja ha començat o finalitzat/expirat
  bool isEventExpired(EventModel event) {
    final start = event.parsedDateBegin;
    if (start != null && DateTime.now().isAfter(start)) {
      return true;
    }
    final end = event.parsedDateEnd;
    if (end != null && DateTime.now().isAfter(end)) {
      return true;
    }
    return false;
  }

  /// Comprova si l'aforament de l'esdeveniment està complet
  bool isEventFull(EventModel event) {
    // Si seatsMax és 0 o null, l'aforament és il·limitat en Odoo
    if (event.seatsMax == null || event.seatsMax == 0) {
      return false;
    }
    return event.seatsAvailable != null && event.seatsAvailable! <= 0;
  }
}
