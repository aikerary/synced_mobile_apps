import 'package:loggy/loggy.dart';
import '../../models/speaker_model.dart';
import '../../services/api_service.dart';
import '../../../../utils/constants/api_constants.dart';

/// Remote data source for speakers
class RemoteSpeakerSource with UiLoggy {
  final ApiService _apiService;

  RemoteSpeakerSource({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetch all speakers from the API
  Future<List<Speaker>> getAllSpeakers() async {
    try {
      loggy.info('Fetching all speakers from API');
      
      final data = await _apiService.getAllData(ApiConstants.speakersTable);
      loggy.info('Raw speakers data received: ${data.length} items');
      
      final speakers = <Speaker>[];
      
      for (final speakerData in data) {
        try {
          // Extract entry_id if it exists (from API wrapper)
          int? entryId;
          Map<String, dynamic> actualSpeakerData = speakerData;
          
          if (speakerData.containsKey('entry_id') && speakerData.containsKey('data')) {
            // Use safe parsing for entry_id since it comes as String from API
            final entryIdValue = speakerData['entry_id'];
            if (entryIdValue is int) {
              entryId = entryIdValue;
            } else if (entryIdValue is String) {
              entryId = int.tryParse(entryIdValue);
            }
            actualSpeakerData = speakerData['data'] as Map<String, dynamic>;
            // Add entry_id to the data for Speaker.fromJson to parse
            actualSpeakerData['entry_id'] = entryId;
            loggy.debug('Found entry_id: $entryId for speaker: ${actualSpeakerData['name']}');
          }
          
          final speaker = Speaker.fromJson(actualSpeakerData);
          
          // The entry_id should now be included in the speaker from fromJson
          
          loggy.debug('Successfully parsed speaker: ${speaker.name} (ID: ${speaker.id}, EntryID: ${speaker.entryId})');
          
          speakers.add(speaker);
        } catch (e) {
          loggy.error('Error parsing individual speaker: $e');
          loggy.error('Speaker data that failed: $speakerData');
        }
      }
      
      loggy.info('Successfully loaded ${speakers.length} speakers');
      return speakers;
    } catch (e) {
      loggy.error('Error fetching speakers: $e');
      throw Exception('Failed to load speakers: $e');
    }
  }

  /// Create a new speaker
  Future<Speaker> createSpeaker(Speaker speaker) async {
    try {
      loggy.info('Creating speaker: ${speaker.name}');
      loggy.debug('Speaker data: ${speaker.toJson()}');
      
      final response = await _apiService.createData(
        ApiConstants.speakersTable,
        speaker.toJson(),
      );
      
      loggy.info('Speaker created successfully with response: $response');
      return Speaker.fromJson(response);
    } catch (e) {
      loggy.error('Error creating speaker: $e');
      throw Exception('Failed to create speaker: $e');
    }
  }

  /// Update an existing speaker
  Future<Speaker> updateSpeaker(Speaker speaker) async {
    try {
      // Use entry_id for API updates, fallback to regular id
      final updateId = speaker.entryId ?? speaker.id;
      
      if (updateId == null) {
        throw Exception('Speaker ID or Entry ID is required for update');
      }

      loggy.info('Updating speaker with Entry ID: ${speaker.entryId} (Speaker ID: ${speaker.id})');

      final response = await _apiService.updateData(
        ApiConstants.speakersTable,
        updateId,
        speaker.toJson(),
      );
      
      loggy.info('Speaker updated successfully');
      return Speaker.fromJson(response);
    } catch (e) {
      loggy.error('Error updating speaker: $e');
      throw Exception('Failed to update speaker: $e');
    }
  }

  /// Delete a speaker
  Future<bool> deleteSpeaker(int id) async {
    try {
      loggy.info('Deleting speaker with ID: $id');
      
      final success = await _apiService.deleteData(ApiConstants.speakersTable, id);
      
      if (success) {
        loggy.info('Speaker deleted successfully');
      }
      
      return success;
    } catch (e) {
      loggy.error('Error deleting speaker: $e');
      throw Exception('Failed to delete speaker: $e');
    }
  }

  /// Get speaker by ID
  Future<Speaker?> getSpeakerById(int id) async {
    try {
      loggy.info('Getting speaker by ID: $id');
      final speakers = await getAllSpeakers();
      final speaker = speakers.firstWhere(
        (speaker) => speaker.id == id,
        orElse: () => throw Exception('Speaker not found'),
      );
      loggy.info('Found speaker: ${speaker.name}');
      return speaker;
    } catch (e) {
      loggy.error('Error getting speaker by ID $id: $e');
      return null;
    }
  }
}
