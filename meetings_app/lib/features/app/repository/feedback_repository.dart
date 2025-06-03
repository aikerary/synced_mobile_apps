import 'package:loggy/loggy.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/feedback_model.dart';
import '../data/remote/remote_feedback_source.dart';

class FeedbackRepository with UiLoggy {
  final RemoteFeedbackSource _remote;
  final Connectivity _connectivity;

  FeedbackRepository({
    RemoteFeedbackSource? remote,
    Connectivity? connectivity,
  })  : _remote = remote ?? RemoteFeedbackSource(),
        _connectivity = connectivity ?? Connectivity();

  /// Get all feedbacks
  Future<List<Feedback>> getAllFeedbacks() async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Loading feedbacks from API");
        return await _remote.getAllFeedbacks();
      } else {
        loggy.warning("No internet connection available for feedbacks");
        return [];
      }
    } catch (e) {
      loggy.error('Error loading feedbacks: $e');
      return [];
    }
  }

  /// Get feedbacks for a specific event
  Future<List<Feedback>> getFeedbacksForEvent(int eventId) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Loading feedbacks for event $eventId");
        return await _remote.getFeedbacksForEvent(eventId);
      } else {
        loggy.warning("No internet connection available for feedbacks");
        return [];
      }
    } catch (e) {
      loggy.error('Error loading feedbacks for event $eventId: $e');
      return [];
    }
  }

  /// Create a new feedback
  Future<Feedback?> createFeedback(Feedback feedback) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Creating feedback for event ${feedback.eventId}");
        return await _remote.createFeedback(feedback);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error creating feedback: $e');
      return null;
    }
  }

  /// Update an existing feedback
  Future<Feedback?> updateFeedback(Feedback feedback) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Updating feedback with ID: ${feedback.id}");
        return await _remote.updateFeedback(feedback);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error updating feedback: $e');
      return null;
    }
  }

  /// Delete a feedback
  Future<bool> deleteFeedback(int id) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        loggy.info("Deleting feedback with ID: $id");
        return await _remote.deleteFeedback(id);
      } else {
        throw Exception("No internet connection available");
      }
    } catch (e) {
      loggy.error('Error deleting feedback: $e');
      return false;
    }
  }

  /// Get average rating for an event
  Future<double> getAverageRatingForEvent(int eventId) async {
    try {
      var connectivityResult = await _connectivity.checkConnectivity();
      bool isConnected = connectivityResult != ConnectivityResult.none;

      if (isConnected) {
        return await _remote.getAverageRatingForEvent(eventId);
      } else {
        return 0.0;
      }
    } catch (e) {
      loggy.error('Error getting average rating for event $eventId: $e');
      return 0.0;
    }
  }
}
