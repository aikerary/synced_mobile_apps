import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import '../../models/event_model.dart';
import '../../models/speaker_model.dart';
import '../../models/track_model.dart';
import '../../services/api_service.dart';
import '../../../../utils/constants/api_constants.dart';
import 'i_remote_event_source.dart';
import 'remote_speaker_source.dart';

class RemoteEventSource with UiLoggy implements IRemoteEventSource {
  final ApiService _apiService;
  final RemoteSpeakerSource _speakerSource;

  RemoteEventSource({
    ApiService? apiService,
    RemoteSpeakerSource? speakerSource,
  })  : _apiService = apiService ?? ApiService(),
        _speakerSource = speakerSource ?? RemoteSpeakerSource();

  @override
  Future<List<Event>> getAllEvents() async {
    try {
      loggy.info('Fetching all events from API');

      // Get events data
      final eventsData = await _apiService.getAllData(ApiConstants.eventsTable);

      // Get related data
      final speakers = await _speakerSource.getAllSpeakers();
      final tracks = await _getAllTracks();
      final eventTracks = await _getEventTracks();
      final eventSpeakers = await _getEventSpeakers();

      // Build events with related data
      final events = <Event>[];

      for (final eventData in eventsData) {
        final event = Event.fromJson(eventData);

        // Find main speaker
        Speaker? mainSpeaker;
        if (event.ponenteId != null) {
          try {
            mainSpeaker = speakers.firstWhere(
              (s) => s.id == event.ponenteId,
            );
          } catch (e) {
            mainSpeaker = Speaker(name: 'Ponente no encontrado');
          }
        }

        // Find all speakers for this event
        final eventSpeakerIds = eventSpeakers
            .where((es) => es['event_id'] == event.id)
            .map((es) => es['speaker_id'] as int)
            .toList();

        final allEventSpeakers =
            speakers.where((s) => eventSpeakerIds.contains(s.id)).toList();

        // Find track names for this event
        final eventTrackIds = eventTracks
            .where((et) => et['event_id'] == event.id)
            .map((et) => et['track_id'] as int)
            .toList();

        final trackNames = tracks
            .where((t) => eventTrackIds.contains(t.id))
            .map((t) => t.nombre)
            .toList();

        // Create enriched event
        final enrichedEvent = event.copyWith(
          ponente: mainSpeaker,
          speakers: allEventSpeakers,
          trackNames: trackNames,
        );

        events.add(enrichedEvent);
      }

      loggy.info('Successfully loaded ${events.length} events');
      return events;
    } catch (e) {
      loggy.error('Error fetching events: $e');
      rethrow;
    }
  }

  @override
  Future<Event> getEventById(int id) async {
    try {
      loggy.info('Fetching event with ID: $id');

      final events = await getAllEvents();
      final event = events.firstWhere(
        (e) => e.id == id,
        orElse: () => throw Exception('Event not found'),
      );

      return event;
    } catch (e) {
      loggy.error('Error fetching event by ID: $e');
      rethrow;
    }
  }

  @override
  Future<bool> addEvent(Event event) async {
    try {
      loggy.info('Creating new event: ${event.titulo}');

      final response = await _apiService.createData(
        ApiConstants.eventsTable,
        event.toJson(),
      );

      loggy.info('Event created successfully with ID: ${response['id']}');
      return true;
    } catch (e) {
      loggy.error('Error creating event: $e');
      return false;
    }
  }

  @override
  Future<bool> updateEvent(Event event) async {
    try {
      if (event.id == null) {
        throw Exception('Event ID is required for update');
      }

      loggy.info('Updating event with ID: ${event.id}');

      await _apiService.updateData(
        ApiConstants.eventsTable,
        event.id!,
        event.toJson(),
      );

      loggy.info('Event updated successfully');
      return true;
    } catch (e) {
      loggy.error('Error updating event: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteEvent(int id) async {
    try {
      loggy.info('Deleting event with ID: $id');

      final success =
          await _apiService.deleteData(ApiConstants.eventsTable, id);

      if (success) {
        loggy.info('Event deleted successfully');
      }

      return success;
    } catch (e) {
      loggy.error('Error deleting event: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastUpdated() async {
    // For this implementation, we'll return the current time
    // In a real scenario, you might want to store this in the database
    return DateTime.now();
  }

  /// Get all tracks from API
  Future<List<Track>> _getAllTracks() async {
    try {
      final data = await _apiService.getAllData(ApiConstants.tracksTable);
      return data.map((json) => Track.fromJson(json)).toList();
    } catch (e) {
      loggy.warning('Error fetching tracks: $e');
      return [];
    }
  }

  /// Get event-track relationships
  Future<List<Map<String, dynamic>>> _getEventTracks() async {
    try {
      return await _apiService.getAllData(ApiConstants.eventTracksTable);
    } catch (e) {
      loggy.warning('Error fetching event-tracks: $e');
      return [];
    }
  }

  /// Get event-speaker relationships
  Future<List<Map<String, dynamic>>> _getEventSpeakers() async {
    try {
      return await _apiService.getAllData(ApiConstants.eventSpeakersTable);
    } catch (e) {
      loggy.warning('Error fetching event-speakers: $e');
      return [];
    }
  }
}
