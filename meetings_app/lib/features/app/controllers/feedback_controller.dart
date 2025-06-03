import 'package:flutter/foundation.dart';
import 'package:loggy/loggy.dart';
import '../models/feedback_model.dart';
import '../models/event_comment_model.dart';
import '../repository/feedback_repository.dart';
import 'package:get_storage/get_storage.dart';

class FeedbackController extends ChangeNotifier with UiLoggy {
  final FeedbackRepository _feedbackRepository;
  final _storage = GetStorage();

  // Clave para almacenar IDs de eventos comentados en GetStorage
  static const String _commentedEventsKey = 'commented_events';

  // Lista interna para almacenar los feedbacks.
  List<Feedback> _feedbacks = [];

  // Lista interna para almacenar los comentarios locales (compatibilidad con UI existente).
  List<EventComment> _eventComments = [];

  // Set para llevar un registro de los eventos que ha comentado el usuario actual
  final Set<int> _commentedEventIds = {};

  // Constructor
  FeedbackController({FeedbackRepository? feedbackRepository})
      : _feedbackRepository = feedbackRepository ?? FeedbackRepository() {
    _loadCommentedEvents();
  }

  // Getters para exponer los datos de forma inmutable
  List<Feedback> get feedbacks => List.unmodifiable(_feedbacks);
  List<EventComment> get eventComments => List.unmodifiable(_eventComments);
  Set<int> get commentedEventIds => Set.unmodifiable(_commentedEventIds);

  /// Verifica si el usuario ya ha comentado en un evento específico
  bool hasCommentedEvent(int eventId) {
    return _commentedEventIds.contains(eventId);
  }

  /// Carga todos los feedbacks desde la API
  Future<void> loadAllFeedbacks() async {
    try {
      loggy.info('Loading all feedbacks');
      _feedbacks = await _feedbackRepository.getAllFeedbacks();
      loggy.info('Loaded ${_feedbacks.length} feedbacks');
      notifyListeners();
    } catch (e) {
      loggy.error('Error loading feedbacks: $e');
      rethrow;
    }
  }

  /// Carga feedbacks para un evento específico
  Future<void> loadFeedbacksForEvent(int eventId) async {
    try {
      loggy.info('Loading feedbacks for event $eventId');
      final eventFeedbacks = await _feedbackRepository.getFeedbacksForEvent(eventId);
      
      // Actualizar los feedbacks locales para este evento
      _feedbacks.removeWhere((f) => f.eventId == eventId);
      _feedbacks.addAll(eventFeedbacks);
      
      // Convertir feedbacks a EventComments para compatibilidad con UI existente
      final eventComments = eventFeedbacks.map((feedback) => EventComment(
        id: feedback.id?.toString() ?? '${feedback.eventId}_${DateTime.now().millisecondsSinceEpoch}',
        eventId: feedback.eventId,
        content: feedback.comment,
        rating: feedback.rating,
        datePosted: feedback.createdAt ?? DateTime.now(),
        isAnonymous: true, // Por simplicidad, todos los feedbacks son anónimos
        userId: null,
      )).toList();
      
      // Actualizar comentarios locales
      _eventComments.removeWhere((c) => c.eventId == eventId);
      _eventComments.addAll(eventComments);
      
      loggy.info('Loaded ${eventFeedbacks.length} feedbacks for event $eventId');
      notifyListeners();
    } catch (e) {
      loggy.error('Error loading feedbacks for event $eventId: $e');
      rethrow;
    }
  }

  /// Obtiene todos los comentarios de un evento específico (compatibilidad con UI existente)
  List<EventComment> getCommentsForEvent(int eventId) {
    return _eventComments.where((comment) => comment.eventId == eventId).toList();
  }

  /// Obtiene todos los feedbacks de un evento específico
  List<Feedback> getFeedbacksForEvent(int eventId) {
    return _feedbacks.where((feedback) => feedback.eventId == eventId).toList();
  }

  /// Calcula la calificación promedio de un evento
  double getAverageRatingForEvent(int eventId) {
    final eventFeedbacks = getFeedbacksForEvent(eventId);
    if (eventFeedbacks.isEmpty) {
      return 0.0;
    }

    final totalRating = eventFeedbacks.fold(0, (sum, feedback) => sum + feedback.rating);
    return totalRating / eventFeedbacks.length;
  }

  /// Agrega un nuevo comentario/feedback (guarda tanto local como en API)
  Future<bool> addComment({
    required int eventId,
    required String content,
    required int rating,
    required bool isAnonymous,
    String? userId,
  }) async {
    try {
      loggy.info('Adding comment for event $eventId');
      
      // Crear el feedback para enviar a la API
      final feedback = Feedback(
        eventId: eventId,
        rating: rating,
        comment: content,
        createdAt: DateTime.now(),
      );

      // Intentar guardar en la API
      final createdFeedback = await _feedbackRepository.createFeedback(feedback);
      
      if (createdFeedback != null) {
        loggy.info('Feedback created successfully in API with ID: ${createdFeedback.id}');
        
        // Agregar al estado local
        _feedbacks.add(createdFeedback);

        // Crear EventComment para compatibilidad con UI existente
        final eventComment = EventComment(
          id: createdFeedback.id?.toString() ?? 'comment_${DateTime.now().millisecondsSinceEpoch}',
          eventId: eventId,
          content: content,
          rating: rating,
          datePosted: createdFeedback.createdAt ?? DateTime.now(),
          isAnonymous: isAnonymous,
          userId: isAnonymous ? null : userId,
        );

        _eventComments.add(eventComment);

        // Registrar que este evento ha sido comentado
        _commentedEventIds.add(eventId);
        _saveCommentedEvents();

        // Notificar cambios
        notifyListeners();
        
        return true;
      } else {
        loggy.error('Failed to create feedback in API');
        return false;
      }
    } catch (e) {
      loggy.error('Error adding comment: $e');
      return false;
    }
  }

  /// Elimina un comentario específico
  Future<bool> removeComment(String commentId) async {
    try {
      // Buscar el feedback correspondiente
      final commentToRemove = _eventComments.firstWhere(
        (comment) => comment.id == commentId,
        orElse: () => throw Exception('Comment not found'),
      );

      final feedback = _feedbacks.firstWhere(
        (f) => f.id?.toString() == commentId || f.eventId == commentToRemove.eventId,
        orElse: () => throw Exception('Feedback not found'),
      );

      if (feedback.id != null) {
        // Eliminar de la API
        final success = await _feedbackRepository.deleteFeedback(feedback.id!);
        
        if (success) {
          // Eliminar del estado local
          _feedbacks.removeWhere((f) => f.id == feedback.id);
          _eventComments.removeWhere((comment) => comment.id == commentId);
          
          notifyListeners();
          return true;
        }
      }
      
      return false;
    } catch (e) {
      loggy.error('Error removing comment: $e');
      return false;
    }
  }

  /// Carga eventos comentados desde almacenamiento local
  void _loadCommentedEvents() {
    try {
      final List<dynamic>? storedIds = _storage.read<List>(_commentedEventsKey);
      if (storedIds != null) {
        _commentedEventIds.clear();
        _commentedEventIds.addAll(storedIds.map<int>((id) => id as int));
      }
    } catch (e) {
      loggy.error('Error loading commented events: $e');
    }
  }

  /// Guarda eventos comentados en almacenamiento local
  void _saveCommentedEvents() {
    try {
      _storage.write(_commentedEventsKey, _commentedEventIds.toList());
    } catch (e) {
      loggy.error('Error saving commented events: $e');
    }
  }

  /// Sincroniza feedbacks desde la API para todos los eventos
  Future<void> syncAllFeedbacks() async {
    try {
      loggy.info('Syncing all feedbacks from API');
      await loadAllFeedbacks();
      
      // Convertir todos los feedbacks a EventComments para compatibilidad
      _eventComments.clear();
      for (final feedback in _feedbacks) {
        final eventComment = EventComment(
          id: feedback.id?.toString() ?? '${feedback.eventId}_${feedback.createdAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}',
          eventId: feedback.eventId,
          content: feedback.comment,
          rating: feedback.rating,
          datePosted: feedback.createdAt ?? DateTime.now(),
          isAnonymous: true,
          userId: null,
        );
        _eventComments.add(eventComment);
      }
      
      loggy.info('Sync completed successfully');
    } catch (e) {
      loggy.error('Error syncing feedbacks: $e');
    }
  }
} 