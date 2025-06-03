import 'package:flutter/foundation.dart';
import 'package:meetings_app/features/app/models/event_model.dart';
import 'package:meetings_app/features/app/models/event_comment_model.dart';
import 'package:meetings_app/features/app/repository/event_repository.dart';
import 'package:meetings_app/features/app/controllers/feedback_controller.dart';
import 'package:get_storage/get_storage.dart';

class EventController extends ChangeNotifier {
  final EventRepository _eventRepository = EventRepository();
  final _storage = GetStorage();

  // Referencia opcional al FeedbackController
  FeedbackController? _feedbackController;

  // Clave para almacenar IDs de eventos suscritos en GetStorage
  static const String _subscribedEventsKey = 'subscribed_events';

  final Map<int, double> _ratings = {};

  // Lista interna para almacenar los eventos.
  List<Event> _events = [];

  // Lista interna para almacenar los comentarios (fallback cuando no hay FeedbackController).
  List<EventComment> _comments = [];

  // Set para llevar un registro de los eventos que ha comentado el usuario actual
  final Set<int> _commentedEventIds = {};

  // Set para almacenar IDs de eventos suscritos
  final Set<int> _subscribedEventIds = {};

  // Constructor para inicializar el controlador
  EventController() {
    _loadSubscribedEvents();
  }

  // Setter para inyectar FeedbackController
  void setFeedbackController(FeedbackController feedbackController) {
    _feedbackController = feedbackController;
  }

  // Getter para exponer los eventos de forma inmutable.
  List<Event> get events => List.unmodifiable(_events);

  // Getter para exponer todos los comentarios de forma inmutable.
  List<EventComment> get comments => 
      _feedbackController?.eventComments ?? List.unmodifiable(_comments);

  // Getter para obtener IDs de eventos suscritos (solo lectura)
  Set<int> get subscribedEventIds => Set.unmodifiable(_subscribedEventIds);

  // Verifica si el usuario ya ha comentado en un evento específico
  bool hasUserCommentedEvent(int eventId, String userId) {
    if (_feedbackController != null) {
      return _feedbackController!.hasCommentedEvent(eventId);
    }
    return _comments.any((comment) =>
        comment.eventId == eventId &&
        comment.userId == userId &&
        !comment.isAnonymous);
  }

  // Verifica si el usuario actual ha comentado en un evento (simplificado)
  bool hasCommentedEvent(int eventId) {
    if (_feedbackController != null) {
      return _feedbackController!.hasCommentedEvent(eventId);
    }
    return _commentedEventIds.contains(eventId);
  }

  // Verifica si el usuario está suscrito a un evento
  bool isSubscribed(int eventId) {
    return _subscribedEventIds.contains(eventId);
  }

  /// Carga los eventos desde el repositorio.
  Future<void> loadEvents() async {
    print("=== EventController.loadEvents() CALLED ===");
    try {
    _events = await _eventRepository.loadEvents();
      print("EventController: Loaded ${_events.length} events");
      
      // Check specifically for chocolate event
      final chocolateEvents = _events.where((event) => 
        event.titulo.toLowerCase().contains('chocolate')
      ).toList();
      print("EventController: Found ${chocolateEvents.length} chocolate events");
      
      // Si tenemos FeedbackController, sincronizar feedbacks
      if (_feedbackController != null) {
        try {
          await _feedbackController!.syncAllFeedbacks();
          print("EventController: Synced feedbacks successfully");
        } catch (e) {
          print("EventController: Warning - could not sync feedbacks: $e");
        }
      }
      
    notifyListeners();
      print("EventController: notifyListeners called");
    } catch (e) {
      print("EventController ERROR: $e");
      rethrow;
    }
  }

  /// Obtiene un evento por su id.
  Event? getEventById(int id) {
    try {
      return _events.firstWhere((event) => event.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Obtiene eventos pasados
  List<Event> getPastEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.fecha.isBefore(now)).toList();
  }

  /// Obtiene eventos futuros
  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.fecha.isAfter(now)).toList();
  }

  /// Obtiene eventos a los que el usuario está suscrito
  List<Event> getSubscribedEvents() {
    return _events
        .where((event) => _subscribedEventIds.contains(event.id))
        .toList();
  }

  /// Obtiene eventos futuros a los que el usuario está suscrito
  List<Event> getUpcomingSubscribedEvents() {
    final now = DateTime.now();
    return getSubscribedEvents()
        .where((event) => event.fecha.isAfter(now))
        .toList();
  }

  /// Obtiene eventos pasados a los que el usuario está suscrito
  List<Event> getPastSubscribedEvents() {
    final now = DateTime.now();
    return getSubscribedEvents()
        .where((event) => event.fecha.isBefore(now))
        .toList();
  }

  /// Obtiene todos los comentarios de un evento específico.
  List<EventComment> getCommentsForEvent(int eventId) {
    if (_feedbackController != null) {
      return _feedbackController!.getCommentsForEvent(eventId);
    }
    return _comments.where((comment) => comment.eventId == eventId).toList();
  }

  /// Calcula la calificación promedio de un evento
  double getAverageRatingForEvent(int eventId) {
    if (_feedbackController != null) {
      return _feedbackController!.getAverageRatingForEvent(eventId);
    }
    
    final eventComments = getCommentsForEvent(eventId);
    if (eventComments.isEmpty) {
      return 0.0;
    }

    final totalRating =
        eventComments.fold(0, (sum, comment) => sum + comment.rating);
    return totalRating / eventComments.length;
  }

  // Método para actualizar el rating de un evento.
  void updateRating(int eventId, double newRating) {
    _ratings[eventId] = newRating;
    notifyListeners();
  }

  // Método para suscribirse a un evento
  Future<bool> subscribeToEvent(int eventId) async {
    print("=== EventController.subscribeToEvent($eventId) CALLED ===");
    
    // Verificar si ya está suscrito
    if (_subscribedEventIds.contains(eventId)) {
      print("Already subscribed to event $eventId");
      return true; // Ya está suscrito
    }

    // Buscar el evento
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      print("Event $eventId not found");
      return false; // Evento no encontrado
    }

    // Verificar si hay cupos disponibles
    final event = _events[eventIndex];
    if (event.suscritos >= event.maxParticipantes) {
      print("Event $eventId is full");
      return false; // No hay cupos disponibles
    }

    try {
    // Crear una copia actualizada del evento con un suscrito más
    final updatedEvent = event.copyWith(
      suscritos: event.suscritos + 1, // Incrementar el contador de suscritos
    );

      print("Updating event in API: suscritos ${event.suscritos} -> ${updatedEvent.suscritos}");
      
      // Guardar en la API a través del repositorio
      final success = await _eventRepository.saveEvent(updatedEvent);
      
      if (success) {
        print("Successfully updated event in API");
        
        // Actualizar el evento en la lista local
    _events[eventIndex] = updatedEvent;

    // Agregar a la lista de suscritos
    _subscribedEventIds.add(eventId);

    // Persistir en almacenamiento local
    _saveSubscribedEvents();

    // Notificar cambios
    notifyListeners();

    return true;
      } else {
        print("Failed to update event in API");
        return false;
      }
    } catch (e) {
      print("Error subscribing to event $eventId: $e");
      return false;
    }
  }

  // Método para cancelar la suscripción a un evento
  Future<bool> unsubscribeFromEvent(int eventId) async {
    print("=== EventController.unsubscribeFromEvent($eventId) CALLED ===");
    
    // Verificar si está suscrito
    if (!_subscribedEventIds.contains(eventId)) {
      print("Not subscribed to event $eventId");
      return false; // No está suscrito
    }

    // Buscar el evento
    final eventIndex = _events.indexWhere((event) => event.id == eventId);
    if (eventIndex == -1) {
      print("Event $eventId not found");
      return false; // Evento no encontrado
    }

    try {
    // Obtener el evento actual
    final event = _events[eventIndex];

    // Crear una copia actualizada del evento con un suscrito menos, pero nunca menos de 0
    final updatedEvent = event.copyWith(
      suscritos: event.suscritos > 0
          ? event.suscritos - 1
          : 0, // Decrementar el contador de suscritos
    );

      print("Updating event in API: suscritos ${event.suscritos} -> ${updatedEvent.suscritos}");
      
      // Guardar en la API a través del repositorio
      final success = await _eventRepository.saveEvent(updatedEvent);
      
      if (success) {
        print("Successfully updated event in API");
        
        // Actualizar el evento en la lista local
    _events[eventIndex] = updatedEvent;

    // Remover de la lista de suscritos
    _subscribedEventIds.remove(eventId);

    // Persistir en almacenamiento local
    _saveSubscribedEvents();

    // Notificar cambios
    notifyListeners();

    return true;
      } else {
        print("Failed to update event in API");
        return false;
      }
    } catch (e) {
      print("Error unsubscribing from event $eventId: $e");
      return false;
    }
  }

  // Método para cargar eventos suscritos desde el almacenamiento local
  void _loadSubscribedEvents() {
    try {
      final List<dynamic>? storedIds =
          _storage.read<List>(_subscribedEventsKey);
      if (storedIds != null) {
        _subscribedEventIds.clear();
        _subscribedEventIds.addAll(storedIds.map<int>((id) => id as int));
      }
    } catch (e) {
      print('Error cargando eventos suscritos: $e');
    }
  }

  // Método para guardar eventos suscritos en el almacenamiento local
  void _saveSubscribedEvents() {
    try {
      _storage.write(_subscribedEventsKey, _subscribedEventIds.toList());
    } catch (e) {
      print('Error guardando eventos suscritos: $e');
    }
  }

  /// Agrega un nuevo comentario a un evento (delegado al FeedbackController si está disponible).
  Future<void> addComment({
    required int eventId,
    required String content,
    required int rating,
    required bool isAnonymous,
    String? userId,
  }) async {
    if (_feedbackController != null) {
      // Usar FeedbackController si está disponible
      await _feedbackController!.addComment(
        eventId: eventId,
        content: content,
        rating: rating,
        isAnonymous: isAnonymous,
        userId: userId,
      );
    } else {
      // Fallback al sistema local
    // Generar un ID único para el comentario
    final commentId = 'comment_${DateTime.now().millisecondsSinceEpoch}';

    // Crear el nuevo comentario
    final newComment = EventComment(
      id: commentId,
      eventId: eventId,
      content: content,
      rating: rating,
      datePosted: DateTime.now(),
      isAnonymous: isAnonymous,
      userId: isAnonymous ? null : userId,
    );

    // Agregar el comentario a la lista
    _comments.add(newComment);

    // Registrar que este evento ha sido comentado
    _commentedEventIds.add(eventId);

    // Notificar a los listeners sobre el cambio
    notifyListeners();
    }
  }

  /// Elimina un comentario específico.
  Future<void> removeComment(String commentId) async {
    if (_feedbackController != null) {
      // Usar FeedbackController si está disponible
      await _feedbackController!.removeComment(commentId);
    } else {
      // Fallback al sistema local
    _comments.removeWhere((comment) => comment.id == commentId);
    notifyListeners();
    }
  }
}
