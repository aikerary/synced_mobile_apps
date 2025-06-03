import 'package:flutter/material.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/repository/track_repository.dart';

/// 0 => All, 1 => This Week, 2 => This Month, 3 => Next Month, 4 => Past
enum EventDateFilter { all, thisWeek, thisMonth, nextMonth, past }

class AllEventsController extends ChangeNotifier {
  final EventRepository eventRepo;
  final TrackRepository trackRepo;

  // Lista completa de eventos (cargada una vez).
  List<Event> _allEvents = [];
  // Lista final ya filtrada, que la UI mostrará.
  List<Event> filteredEvents = [];

  // Filtro seleccionado
  EventDateFilter selectedFilter = EventDateFilter.all;

  // Nombre del track (null => todos)
  String? trackName;

  AllEventsController({
    required this.eventRepo,
    required this.trackRepo,
    this.trackName,
  });

  // Carga inicial de los eventos.
  Future<void> loadEvents() async {
    final all = await eventRepo.loadEvents();
    _allEvents = all;
    applyFilters();
  }

  // Cambia el filtro seleccionado y vuelve a filtrar.
  void setFilter(EventDateFilter filter) {
    selectedFilter = filter;
    applyFilters();
  }

  // Cambia el track (opcional) y vuelve a filtrar.
  void setTrackName(String? name) {
    trackName = name;
    applyFilters();
  }

  // Aplica filtros: track y fecha.
  Future<void> applyFilters() async {
    // Primero filtrar por track
    final trackList = await trackRepo.loadDummyTracks();
    List<Event> filteredByTrack =
        _filterByTrack(_allEvents, trackList, trackName);
    // Luego filtrar por fecha
    filteredEvents = _applyDateFilter(filteredByTrack, selectedFilter);
    notifyListeners();
  }

  // Devuelve la cantidad de eventos filtrados
  int get eventCount => filteredEvents.length;

  /// Filtra los eventos según el trackName (si no es null).
  List<Event> _filterByTrack(
      List<Event> events, List<Track> tracks, String? trackName) {
    if (trackName == null) return events; // Mostrar todos
    // Filter events by trackNames field (since Track no longer has eventos field)
    return events
        .where((event) => event.trackNames
            .any((name) => name.toLowerCase() == trackName.toLowerCase()))
        .toList();
  }

  /// Filtra los eventos según el filtro seleccionado.
  List<Event> _applyDateFilter(List<Event> events, EventDateFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case EventDateFilter.thisWeek:
        final oneWeekLater = now.add(const Duration(days: 7));
        return events
            .where(
                (e) => e.fecha.isAfter(now) && e.fecha.isBefore(oneWeekLater))
            .toList();
      case EventDateFilter.thisMonth:
        return events
            .where((e) =>
                e.fecha.year == now.year &&
                e.fecha.month == now.month &&
                e.fecha.isAfter(now))
            .toList();
      case EventDateFilter.nextMonth:
        final nextMonth = (now.month == 12) ? 1 : now.month + 1;
        final nextYear = (now.month == 12) ? now.year + 1 : now.year;
        return events
            .where(
                (e) => e.fecha.year == nextYear && e.fecha.month == nextMonth)
            .toList();
      case EventDateFilter.past:
        return events.where((e) => e.fecha.isBefore(now)).toList();
      case EventDateFilter.all:
        // All => mostrar solo los futuros
        return events.where((e) => e.fecha.isAfter(now)).toList();
    }
  }
}
