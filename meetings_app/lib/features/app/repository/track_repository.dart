import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:loggy/loggy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meetings_app/features/app/models/track_model.dart';

import '../data/local/i_local_track_source.dart';
import '../data/local/hive_track_source.dart';
import '../data/remote/i_remote_track_source.dart';
import '../data/remote/remote_track_source.dart';

class TrackRepository {
  final IRemoteTrackSource _remote;
  final ILocalTrackSource _local;
  final Connectivity _connectivity;

  TrackRepository({
    IRemoteTrackSource? remote,
    ILocalTrackSource? local,
    Connectivity? connectivity,
  })  : _remote = remote ?? RemoteTrackSource(),
        _local = local ?? HiveTrackSource(),
        _connectivity = connectivity ?? Connectivity();

  // Smart data loading with sync check
  Future<List<Track>> loadTracks() async {
    try {
      // First, try to load from local cache
      List<Track> localTracks = await _local.getAllTracks();

      // Check if we have connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // Check if we need to sync data
        bool shouldSync = await _shouldSyncData();

        if (shouldSync || localTracks.isEmpty) {
          // Get data from remote source
          logInfo("Syncing tracks from remote source");
          List<Track> remoteTracks = await _remote.getAllTracks();

          // Save to local database
          await _local.saveAllTracks(remoteTracks);
          await _local.setLastUpdated(DateTime.now());

          return remoteTracks;
        }
      }

      // If we have local data or couldn't sync, return local data
      return localTracks;
    } catch (e) {
      logError('Error loading tracks: $e');
      // If there's an error, try to return local data as fallback
      return _local.getAllTracks();
    }
  }

  // Check if we need to sync data based on last update times
  Future<bool> _shouldSyncData() async {
    try {
      DateTime? localLastUpdated = await _local.getLastUpdated();
      DateTime? remoteLastUpdated = await _remote.getLastUpdated();

      // If we don't have local data or remote is newer, we should sync
      if (localLastUpdated == null) return true;
      if (remoteLastUpdated == null) return false;

      return remoteLastUpdated.isAfter(localLastUpdated);
    } catch (e) {
      logError('Error checking sync status: $e');
      return false;
    }
  }

  // Save or update a track
  Future<bool> saveTrack(Track track) async {
    try {
      // First save locally to ensure data is not lost
      bool localSuccess = await _local.addTrack(track);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // If online, also save to remote
        bool remoteSuccess = await _remote.addTrack(track);

        // Update local last updated timestamp if remote succeeded
        if (remoteSuccess) {
          await _local.setLastUpdated(DateTime.now());
        }

        return remoteSuccess;
      }

      return localSuccess;
    } catch (e) {
      logError('Error saving track: $e');
      return false;
    }
  }

  // Update a track
  Future<bool> updateTrack(Track track) async {
    try {
      // First update locally
      bool localSuccess = await _local.updateTrack(track);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // If online, also update remotely
        bool remoteSuccess = await _remote.updateTrack(track);

        // Update local last updated timestamp if remote succeeded
        if (remoteSuccess) {
          await _local.setLastUpdated(DateTime.now());
        }

        return remoteSuccess;
      }

      return localSuccess;
    } catch (e) {
      logError('Error updating track: $e');
      return false;
    }
  }

  // Delete a track
  Future<bool> deleteTrack(String nombre) async {
    try {
      // Delete locally first
      bool localSuccess = await _local.deleteTrack(nombre);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // If online, also delete from remote
        bool remoteSuccess = await _remote.deleteTrack(nombre);

        // Update local last updated timestamp if remote succeeded
        if (remoteSuccess) {
          await _local.setLastUpdated(DateTime.now());
        }

        return remoteSuccess;
      }

      return localSuccess;
    } catch (e) {
      logError('Error deleting track $nombre: $e');
      return false;
    }
  }

  Future<List<Track>> loadDummyTracks() async {
    // Carga el archivo JSON como String.
    final String jsonString =
        await rootBundle.loadString('assets/data/events.json');

    // Convierta el String en la estructura deseada.
    final dynamic jsonResponse = json.decode(jsonString);

    // Verifica si la estructura contiene la clave "tracks".
    if (jsonResponse is Map<String, dynamic> &&
        jsonResponse.containsKey('tracks')) {
      final List<dynamic> tracksJson = jsonResponse['tracks'];
      return tracksJson.map((data) => Track.fromJson(data)).toList();
    }
    // Si no se encuentra la clave "tracks", se retorna una lista vacía.
    return [];
  }
}
