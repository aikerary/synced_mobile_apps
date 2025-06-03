import 'package:hive/hive.dart';
import 'package:loggy/loggy.dart';
import '../../models/track_model.dart';
import 'i_local_track_source.dart';

class HiveTrackSource implements ILocalTrackSource {
  static const String _trackBoxName = 'tracks';
  static const String _metadataBoxName = 'tracksMetadata';
  static const String _lastUpdatedKey = 'lastUpdated';

  Future<Box<Track>> get _trackBox async =>
      await Hive.openBox<Track>(_trackBoxName);

  Future<Box<dynamic>> get _metadataBox async =>
      await Hive.openBox(_metadataBoxName);

  @override
  Future<List<Track>> getAllTracks() async {
    try {
      final box = await _trackBox;
      return box.values.toList();
    } catch (e) {
      logError('Error fetching tracks from Hive: $e');
      return [];
    }
  }

  @override
  Future<bool> addTrack(Track track) async {
    try {
      final box = await _trackBox;
      await box.put(track.nombre, track);
      return true;
    } catch (e) {
      logError('Error adding track to Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> updateTrack(Track track) async {
    try {
      final box = await _trackBox;
      await box.put(track.nombre, track);
      return true;
    } catch (e) {
      logError('Error updating track in Hive: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteTrack(String nombre) async {
    try {
      final box = await _trackBox;
      await box.delete(nombre);
      return true;
    } catch (e) {
      logError('Error deleting track from Hive: $e');
      return false;
    }
  }

  @override
  Future<void> saveAllTracks(List<Track> tracks) async {
    try {
      final box = await _trackBox;
      final trackMap = {for (var track in tracks) track.nombre: track};
      await box.putAll(trackMap);
    } catch (e) {
      logError('Error saving all tracks to Hive: $e');
      throw e;
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    try {
      final box = await _metadataBox;
      final timestamp = box.get(_lastUpdatedKey);
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      logError('Error getting last updated timestamp from Hive: $e');
      return null;
    }
  }

  @override
  Future<void> setLastUpdated(DateTime dateTime) async {
    try {
      final box = await _metadataBox;
      await box.put(_lastUpdatedKey, dateTime.toIso8601String());
    } catch (e) {
      logError('Error setting last updated timestamp in Hive: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      final box = await _trackBox;
      await box.clear();
    } catch (e) {
      logError('Error clearing tracks from Hive: $e');
    }
  }
}
