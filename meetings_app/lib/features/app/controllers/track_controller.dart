import 'package:flutter/foundation.dart';
import 'package:meetings_app/features/app/models/track_model.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';

class TrackController extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();

  List<Track> _tracks = [];
  List<Event> _events = []; // Lista interna para almacenar todos los eventos

  List<Track> get tracks => List.unmodifiable(_tracks);
  List<Event> get events => List.unmodifiable(_events);

  /// Carga tanto los tracks como los eventos.
  Future<void> loadData() async {
    _tracks = await _eventRepository.loadDummyTracks();
    _events = await _eventRepository.loadEvents();
    notifyListeners();
  }

  /// Carga solo los tracks.
  Future<void> loadTracks() async {
    _tracks = await _eventRepository.loadDummyTracks();
    notifyListeners();
  }

  /// Carga solo los eventos.
  Future<void> loadEvents() async {
    _events = await _eventRepository.loadEvents();
  }

  /// Retorna la lista de eventos asociados al track indicado.
  List<Event> getEventsForTrack(Track track) {
    return _events
        .where((event) => event.trackNames.any((name) => name == track.nombre))
        .toList();
  }

  /// Retorna la lista de eventos asociados a una o más tracks especificadas por su nombre.
  List<Event> getEventsForTracks(List<String> trackNames) {
    // Filter events that have any of the specified track names
    return _events
        .where((event) => event.trackNames
            .any((eventTrackName) => trackNames.contains(eventTrackName)))
        .toList();
  }

  /// Retorna la lista de nombres de los tracks disponibles.
  List<String> getAvailableTrackNames() {
    return _tracks.map((track) => track.nombre).toList();
  }

  // Métodos CRUD para tracks:

  /// Obtiene un track por su nombre.
  Track? getTrackByName(String nombre) {
    try {
      return _tracks.firstWhere((track) => track.nombre == nombre);
    } catch (_) {
      return null;
    }
  }

  /// Agrega un nuevo track.
  void addTrack(Track track) {
    _tracks.add(track);
    notifyListeners();
  }

  /// Actualiza un track existente.
  void updateTrack(Track updatedTrack) {
    int index =
        _tracks.indexWhere((track) => track.nombre == updatedTrack.nombre);
    if (index != -1) {
      _tracks[index] = updatedTrack;
      notifyListeners();
    }
  }

  /// Elimina un track a partir de su nombre.
  void removeTrack(String nombre) {
    _tracks.removeWhere((track) => track.nombre == nombre);
    notifyListeners();
  }
}
