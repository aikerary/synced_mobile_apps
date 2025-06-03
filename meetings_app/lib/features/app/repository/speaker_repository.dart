import 'package:loggy/loggy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/speaker_model.dart';
import '../data/remote/remote_speaker_source.dart';

class SpeakerRepository with UiLoggy {
  final RemoteSpeakerSource _remote;
  final Connectivity _connectivity;

  SpeakerRepository({
    RemoteSpeakerSource? remote,
    Connectivity? connectivity,
  })  : _remote = remote ?? RemoteSpeakerSource(),
        _connectivity = connectivity ?? Connectivity();

  /// Get all speakers
  Future<List<Speaker>> getAllSpeakers() async {
    try {
      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Loading speakers from API");
        return await _remote.getAllSpeakers();
      } else {
        loggy.warning("No internet connection available for speakers");
        return [];
      }
    } catch (e) {
      loggy.error('Error loading speakers: $e');
      return [];
    }
  }

  /// Get speaker by ID
  Future<Speaker?> getSpeakerById(int id) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        return await _remote.getSpeakerById(id);
      }
      return null;
    } catch (e) {
      loggy.error('Error getting speaker $id: $e');
      return null;
    }
  }

  /// Create a new speaker
  Future<Speaker?> createSpeaker(Speaker speaker) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Creating speaker: ${speaker.name}");
        return await _remote.createSpeaker(speaker);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error creating speaker: $e');
      return null;
    }
  }

  /// Update an existing speaker
  Future<Speaker?> updateSpeaker(Speaker speaker) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Updating speaker with ID: ${speaker.id}");
        return await _remote.updateSpeaker(speaker);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error updating speaker: $e');
      return null;
    }
  }

  /// Delete a speaker
  Future<bool> deleteSpeaker(int id) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Deleting speaker with ID: $id");
        return await _remote.deleteSpeaker(id);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error deleting speaker: $e');
      return false;
    }
  }
}
