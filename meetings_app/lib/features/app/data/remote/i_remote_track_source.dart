// lib/features/app/data/remote/i_remote_track_source.dart

import 'package:meetings_app/features/app/models/track_model.dart';

abstract class IRemoteTrackSource {
  Future<List<Track>> getAllTracks();
  Future<bool> addTrack(Track track);
  Future<bool> updateTrack(Track track);
  Future<bool> deleteTrack(String nombre);
  Future<DateTime?> getLastUpdated();
}
