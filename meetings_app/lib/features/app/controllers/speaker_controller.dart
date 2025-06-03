import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import '../models/speaker_model.dart';
import '../repository/speaker_repository.dart';

class SpeakerController extends ChangeNotifier with UiLoggy {
  final SpeakerRepository _speakerRepository;

  // Lista interna para almacenar los speakers
  List<Speaker> _speakers = [];

  // Estado de carga
  bool _isLoading = false;

  // Constructor
  SpeakerController({SpeakerRepository? speakerRepository})
      : _speakerRepository = speakerRepository ?? SpeakerRepository();

  // Getters para exponer los datos de forma inmutable
  List<Speaker> get speakers => List.unmodifiable(_speakers);
  bool get isLoading => _isLoading;

  /// Carga todos los speakers desde la API
  Future<void> loadSpeakers() async {
    try {
      loggy.info('Loading speakers');
      _isLoading = true;
      notifyListeners();

      _speakers = await _speakerRepository.getAllSpeakers();
      loggy.info('Loaded ${_speakers.length} speakers');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      loggy.error('Error loading speakers: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Obtiene un speaker por su ID
  Speaker? getSpeakerById(int id) {
    try {
      return _speakers.firstWhere((speaker) => speaker.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene speakers que contienen un texto específico en su nombre
  List<Speaker> searchSpeakers(String query) {
    if (query.isEmpty) return _speakers;
    
    return _speakers.where((speaker) => 
      speaker.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  /// Obtiene speakers ordenados alfabéticamente
  List<Speaker> getSpeakersAlphabetically() {
    final speakersCopy = List<Speaker>.from(_speakers);
    speakersCopy.sort((a, b) => a.name.compareTo(b.name));
    return speakersCopy;
  }

  /// Crea un nuevo speaker
  Future<bool> createSpeaker(String name) async {
    try {
      loggy.info('Creating speaker: $name');
      
      final speaker = Speaker(name: name);
      final createdSpeaker = await _speakerRepository.createSpeaker(speaker);
      
      if (createdSpeaker != null) {
        _speakers.add(createdSpeaker);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      loggy.error('Error creating speaker: $e');
      return false;
    }
  }

  /// Actualiza un speaker existente
  Future<bool> updateSpeaker(Speaker speaker) async {
    try {
      loggy.info('Updating speaker: ${speaker.name}');
      
      final updatedSpeaker = await _speakerRepository.updateSpeaker(speaker);
      
      if (updatedSpeaker != null) {
        final index = _speakers.indexWhere((s) => s.id == speaker.id);
        if (index != -1) {
          _speakers[index] = updatedSpeaker;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      loggy.error('Error updating speaker: $e');
      return false;
    }
  }

  /// Elimina un speaker
  Future<bool> deleteSpeaker(int id) async {
    try {
      loggy.info('Deleting speaker with ID: $id');
      
      final success = await _speakerRepository.deleteSpeaker(id);
      
      if (success) {
        _speakers.removeWhere((speaker) => speaker.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      loggy.error('Error deleting speaker: $e');
      return false;
    }
  }
} 