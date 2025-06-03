import '../../models/track_model.dart';

abstract class ILocalTrackSource {
  Future<List<Track>> getAllTracks();
  Future<bool> addTrack(Track track);
  Future<bool> updateTrack(Track track);
  Future<bool> deleteTrack(String nombre);
  Future<void> saveAllTracks(List<Track> tracks);
  Future<DateTime?> getLastUpdated();
  Future<void> setLastUpdated(DateTime dateTime);
  Future<void> clear();
}
