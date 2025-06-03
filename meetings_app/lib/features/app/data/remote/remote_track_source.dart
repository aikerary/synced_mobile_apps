// lib/features/app/data/remote/remote_track_source.dart

import 'package:loggy/loggy.dart';
import '../../models/track_model.dart';
import '../../services/api_service.dart';
import '../../../../utils/constants/api_constants.dart';
import 'i_remote_track_source.dart';

class RemoteTrackSource with UiLoggy implements IRemoteTrackSource {
  final ApiService _apiService;

  RemoteTrackSource({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  @override
  Future<List<Track>> getAllTracks() async {
    try {
      loggy.info('Fetching all tracks from API');
      final data = await _apiService.getAllData(ApiConstants.tracksTable);
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      loggy.error('Error fetching tracks: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addTrack(Track track) async {
    try {
      loggy.info('Creating new track: ${track.nombre}');
      await _apiService.createData(ApiConstants.tracksTable, track.toJson());
      return true;
    } catch (e) {
      loggy.error('Error creating track: $e');
      return false;
    }
  }

  @override
  Future<bool> updateTrack(Track track) async {
    try {
      if (track.id == null) {
        throw Exception('Track ID is required for update');
      }

      loggy.info('Updating track with ID: ${track.id}');
      await _apiService.updateData(
        ApiConstants.tracksTable,
        track.id!,
        track.toJson(),
      );
      return true;
    } catch (e) {
      loggy.error('Error updating track: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteTrack(String nombre) async {
    try {
      // First find the track by name to get its ID
      final tracks = await getAllTracks();
      final track = tracks.firstWhere(
        (t) => t.nombre == nombre,
        orElse: () => throw Exception('Track not found'),
      );

      if (track.id == null) {
        throw Exception('Track ID is null');
      }

      loggy.info('Deleting track: $nombre (ID: ${track.id})');
      return await _apiService.deleteData(ApiConstants.tracksTable, track.id!);
    } catch (e) {
      loggy.error('Error deleting track: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    // For this implementation, we'll return the current time
    // In a real scenario, you might want to store this in the database
    return DateTime.now();
  }
}
