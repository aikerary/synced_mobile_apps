import 'package:loggy/loggy.dart';
import '../../models/feedback_model.dart';
import '../../services/api_service.dart';
import '../../../../utils/constants/api_constants.dart';

/// Remote data source for feedbacks
class RemoteFeedbackSource with UiLoggy {
  final ApiService _apiService;

  RemoteFeedbackSource({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Fetch all feedbacks from the API
  Future<List<Feedback>> getAllFeedbacks() async {
    try {
      loggy.info('Fetching all feedbacks from API');
      
      final data = await _apiService.getAllData(ApiConstants.feedbacksTable);
      loggy.info('Raw feedbacks data received: ${data.length} items');
      
      final feedbacks = <Feedback>[];
      
      for (final feedbackData in data) {
        try {
          // Extract entry_id if it exists (from API wrapper)
          int? entryId;
          Map<String, dynamic> actualFeedbackData = feedbackData;
          
          if (feedbackData.containsKey('entry_id') && feedbackData.containsKey('data')) {
            // Use safe parsing for entry_id since it comes as String from API
            final entryIdValue = feedbackData['entry_id'];
            if (entryIdValue is int) {
              entryId = entryIdValue;
            } else if (entryIdValue is String) {
              entryId = int.tryParse(entryIdValue);
            }
            actualFeedbackData = feedbackData['data'] as Map<String, dynamic>;
            loggy.debug('Found entry_id: $entryId for feedback');
          }
          
          final feedback = Feedback.fromJson(actualFeedbackData);
          
          // Add the entry_id to the feedback
          final feedbackWithEntryId = feedback.copyWith(entryId: entryId);
          
          loggy.debug('Successfully parsed feedback: ID: ${feedbackWithEntryId.id}, EntryID: ${feedbackWithEntryId.entryId}, EventID: ${feedbackWithEntryId.eventId}');
          
          feedbacks.add(feedbackWithEntryId);
        } catch (e) {
          loggy.error('Error parsing individual feedback: $e');
          loggy.error('Feedback data that failed: $feedbackData');
        }
      }
      
      loggy.info('Successfully loaded ${feedbacks.length} feedbacks');
      return feedbacks;
    } catch (e) {
      loggy.error('Error fetching feedbacks: $e');
      throw Exception('Failed to load feedbacks: $e');
    }
  }

  /// Get feedbacks for a specific event
  Future<List<Feedback>> getFeedbacksForEvent(int eventId) async {
    try {
      loggy.info('Fetching feedbacks for event $eventId');
      final allFeedbacks = await getAllFeedbacks();
      final eventFeedbacks = allFeedbacks
          .where((feedback) => feedback.eventId == eventId)
          .toList();
      loggy.info('Found ${eventFeedbacks.length} feedbacks for event $eventId');
      return eventFeedbacks;
    } catch (e) {
      loggy.error('Error loading feedbacks for event $eventId: $e');
      throw Exception('Failed to load feedbacks for event: $e');
    }
  }

  /// Create a new feedback
  Future<Feedback> createFeedback(Feedback feedback) async {
    try {
      loggy.info('Creating feedback for event ${feedback.eventId}');
      loggy.debug('Feedback data: ${feedback.toJson()}');
      
      final response = await _apiService.createData(
        ApiConstants.feedbacksTable,
        feedback.toJson(),
      );
      
      loggy.info('Feedback created successfully with response: $response');
      return Feedback.fromJson(response);
    } catch (e) {
      loggy.error('Error creating feedback: $e');
      throw Exception('Failed to create feedback: $e');
    }
  }

  /// Update an existing feedback
  Future<Feedback> updateFeedback(Feedback feedback) async {
    try {
      // Use entry_id for API updates, fallback to regular id
      final updateId = feedback.entryId ?? feedback.id;
      
      if (updateId == null) {
        throw Exception('Feedback ID or Entry ID is required for update');
      }

      loggy.info('Updating feedback with Entry ID: ${feedback.entryId} (Feedback ID: ${feedback.id})');

      final response = await _apiService.updateData(
        ApiConstants.feedbacksTable,
        updateId,
        feedback.toJson(),
      );
      
      loggy.info('Feedback updated successfully');
      return Feedback.fromJson(response);
    } catch (e) {
      loggy.error('Error updating feedback: $e');
      throw Exception('Failed to update feedback: $e');
    }
  }

  /// Delete a feedback
  Future<bool> deleteFeedback(int id) async {
    try {
      loggy.info('Deleting feedback with ID: $id');
      
      final success = await _apiService.deleteData(ApiConstants.feedbacksTable, id);
      
      if (success) {
        loggy.info('Feedback deleted successfully');
      }
      
      return success;
    } catch (e) {
      loggy.error('Error deleting feedback: $e');
      throw Exception('Failed to delete feedback: $e');
    }
  }

  /// Get average rating for an event
  Future<double> getAverageRatingForEvent(int eventId) async {
    try {
      loggy.info('Getting average rating for event $eventId');
      final feedbacks = await getFeedbacksForEvent(eventId);
      if (feedbacks.isEmpty) {
        loggy.info('No feedbacks found for event $eventId');
        return 0.0;
      }

      final totalRating = feedbacks.fold<int>(0, (sum, feedback) => sum + feedback.rating);
      final average = totalRating / feedbacks.length;
      loggy.info('Average rating for event $eventId: $average (${feedbacks.length} feedbacks)');
      return average;
    } catch (e) {
      loggy.error('Error getting average rating for event $eventId: $e');
      return 0.0;
    }
  }
}
