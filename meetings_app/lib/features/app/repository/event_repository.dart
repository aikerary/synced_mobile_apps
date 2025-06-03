import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:loggy/loggy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/track_model.dart';

import '../data/local/i_local_event_source.dart';
import '../data/local/hive_event_source.dart';
import '../data/remote/i_remote_event_source.dart';
import '../data/remote/remote_event_source.dart';

class EventRepository {
  final IRemoteEventSource _remote;
  final ILocalEventSource _local;
  final Connectivity _connectivity;

  EventRepository({
    IRemoteEventSource? remote,
    ILocalEventSource? local,
    Connectivity? connectivity,
  })  : _remote = remote ?? RemoteEventSource(),
        _local = local ?? HiveEventSource(),
        _connectivity = connectivity ?? Connectivity();

  // Smart data loading with sync check
  Future<List<Event>> loadEvents() async {
    try {
      print("=== EventRepository.loadEvents() STARTED ===");
      logInfo("Starting loadEvents()");
      
      // First, try to load from local cache
      List<Event> localEvents = await _local.getAllEvents();
      print("Local events loaded: ${localEvents.length}");
      logInfo("Loaded ${localEvents.length} events from local cache");

      // Check if we have connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;
      print("Connected: $isConnected");
      logInfo("Connectivity status: $isConnected ($connectivityResult)");

      if (isConnected) {
        // Check if we need to sync data
        bool shouldSync = await _shouldSyncData();
        print("Should sync: $shouldSync");
        logInfo("Should sync: $shouldSync, Local events empty: ${localEvents.isEmpty}");

        // TEMPORARY: Force sync to always load fresh data from API during development
        bool forceSync = true; // Set to false in production
        print("Force sync: $forceSync");
        logInfo("Force sync enabled: $forceSync");

        if (shouldSync || localEvents.isEmpty || forceSync) {
          // Get data from remote source
          print("=== CALLING REMOTE SOURCE ===");
          logInfo("Syncing events from remote source");
          List<Event> remoteEvents = await _remote.getAllEvents();
          print("Remote events received: ${remoteEvents.length}");
          logInfo("Retrieved ${remoteEvents.length} events from remote source");

          // Check specifically for chocolate event in remote data
          final chocolateEvents = remoteEvents.where((event) => 
            event.titulo.toLowerCase().contains('chocolate')
          ).toList();
          print("Chocolate events found: ${chocolateEvents.length}");
          logInfo("Chocolate events in remote data: ${chocolateEvents.length}");

          // TEMPORARY: Skip saving to Hive to avoid key issues
          // TODO: Fix Hive model compatibility later
          /*
          try {
          // Save to local database
          await _local.saveAllEvents(remoteEvents);
          await _local.setLastUpdated(DateTime.now());
            print("Events saved to local cache");
            logInfo("Saved ${remoteEvents.length} events to local cache");
          } catch (e) {
            print("Warning: Could not save to local cache: $e");
            logError("Warning: Could not save to local cache: $e");
          }
          */

          print("=== RETURNING REMOTE EVENTS ===");
          return remoteEvents;
        } else {
          print("Using cached events");
          logInfo("Using cached local events (no sync needed)");
        }
      } else {
        print("No connectivity - using cache");
        logInfo("No connectivity - using local cache");
      }

      // If we have local data or couldn't sync, return local data
      print("Returning local events: ${localEvents.length}");
      logInfo("Returning ${localEvents.length} local events");
      return localEvents;
    } catch (e) {
      print("ERROR in loadEvents: $e");
      logError('Error loading events: $e');
      // If there's an error, try to return local data as fallback
      final fallbackEvents = await _local.getAllEvents();
      print("Fallback events: ${fallbackEvents.length}");
      logInfo("Fallback: returning ${fallbackEvents.length} local events due to error");
      return fallbackEvents;
    }
  }

  // Check if we need to sync data based on last update times
  Future<bool> _shouldSyncData() async {
    try {
      logInfo("Checking if sync is needed...");
      DateTime? localLastUpdated = await _local.getLastUpdated();
      DateTime? remoteLastUpdated = await _remote.getLastUpdated();

      logInfo("Local last updated: $localLastUpdated");
      logInfo("Remote last updated: $remoteLastUpdated");

      // If we don't have local data or remote is newer, we should sync
      if (localLastUpdated == null) {
        logInfo("No local timestamp found - sync needed");
        return true;
      }
      if (remoteLastUpdated == null) {
        logInfo("No remote timestamp found - sync not needed");
        return false;
      }

      bool shouldSync = remoteLastUpdated.isAfter(localLastUpdated);
      logInfo("Remote is newer: $shouldSync");
      return shouldSync;
    } catch (e) {
      logError('Error checking sync status: $e');
      return false;
    }
  }

  // Get a single event
  Future<Event?> getEvent(int id) async {
    try {
      // First try local
      Event? localEvent = await _local.getEventById(id);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (localEvent == null && isConnected) {
        // If not in local storage but online, try remote
        Event remoteEvent = await _remote.getEventById(id);
        // Save to local
        await _local.addEvent(remoteEvent);
        return remoteEvent;
      }

      return localEvent;
    } catch (e) {
      logError('Error getting event $id: $e');
      return null;
    }
  }

  // Save or update an event
  Future<bool> saveEvent(Event e) async {
    try {
      // First save locally to ensure data is not lost
      bool localSuccess =
          e.id == 0 ? await _local.addEvent(e) : await _local.updateEvent(e);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // If online, also save to remote
        bool remoteSuccess = e.id == 0
            ? await _remote.addEvent(e)
            : await _remote.updateEvent(e);

        // Update local last updated timestamp if remote succeeded
        if (remoteSuccess) {
          await _local.setLastUpdated(DateTime.now());
        }

        return remoteSuccess;
      }

      return localSuccess;
    } catch (e) {
      logError('Error saving event: $e');
      return false;
    }
  }

  // Delete an event
  Future<bool> deleteEvent(int id) async {
    try {
      // Delete locally first
      bool localSuccess = await _local.deleteEvent(id);

      // Check connectivity
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        // If online, also delete from remote
        bool remoteSuccess = await _remote.deleteEvent(id);

        // Update local last updated timestamp if remote succeeded
        if (remoteSuccess) {
          await _local.setLastUpdated(DateTime.now());
        }

        return remoteSuccess;
      }

      return localSuccess;
    } catch (e) {
      logError('Error deleting event $id: $e');
      return false;
    }
  }

  // Load events - try API first, fallback to local JSON
  Future<List<Event>> loadDummyEvents() async {
    try {
      // Check connectivity first
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        try {
          // Try to load from API
          logInfo("Loading events from API");
          return await _remote.getAllEvents();
        } catch (e) {
          logError("Failed to load from API, falling back to local data: $e");
          // Fall through to load from JSON
        }
      }

      // Load from local JSON file as fallback
      logInfo("Loading events from local JSON file");
      final String jsonString =
          await rootBundle.loadString('assets/data/events.json');
      final dynamic jsonResponse = json.decode(jsonString);

      // Handle new structure with "eventos" key
      if (jsonResponse is Map<String, dynamic> &&
          jsonResponse.containsKey('eventos')) {
        final List<dynamic> eventsJson = jsonResponse['eventos'];
        return eventsJson.map((data) => Event.fromJson(data)).toList();
      } else if (jsonResponse is List) {
        // Compatibility with old structure (list of events)
        return jsonResponse.map((data) => Event.fromJson(data)).toList();
      } else {
        return [];
      }
    } catch (e) {
      logError('Error loading events: $e');
      return [];
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
