import 'package:flutter/foundation.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';

class CalendarController extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();

  List<Event> _events = [];

  List<Event> get events => _events;

  /// Carga todos los eventos del repositorio
  Future<void> loadEvents() async {
    _events = await _eventRepository.loadEvents();
    notifyListeners();
  }

  /// Retorna la lista de eventos para el día indicado (normalizando la fecha a año, mes y día)
  List<Event> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events.where((event) {
      final eventDay = DateTime(event.fecha.year, event.fecha.month, event.fecha.day);
      return eventDay == normalizedDay;
    }).toList();
  }
}
