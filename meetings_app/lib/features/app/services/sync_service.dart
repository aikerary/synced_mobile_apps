import 'dart:async';
import 'package:loggy/loggy.dart';
import '../controllers/event_controller.dart';
import '../controllers/speaker_controller.dart';
import '../controllers/feedback_controller.dart';
import '../../../utils/config/app_config.dart';

/// Servicio para sincronización automática con el backend
class SyncService with UiLoggy {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  
  SyncService._();

  Timer? _syncTimer;
  bool _isSyncing = false;
  
  // Controllers para sincronizar
  EventController? _eventController;
  SpeakerController? _speakerController;
  FeedbackController? _feedbackController;
  
  // Configuración desde AppConfig
  static Duration get defaultSyncInterval => AppConfig.autoSyncInterval;
  static Duration get backgroundSyncInterval => AppConfig.backgroundSyncInterval;
  
  /// Inicializar el servicio con los controladores
  void initialize({
    required EventController eventController,
    required SpeakerController speakerController,
    required FeedbackController feedbackController,
  }) {
    _eventController = eventController;
    _speakerController = speakerController;
    _feedbackController = feedbackController;
    
    loggy.info('SyncService initialized');
  }
  
  /// Iniciar sincronización automática
  void startAutoSync({Duration? interval}) {
    interval ??= defaultSyncInterval;
    stopAutoSync(); // Detener cualquier timer existente
    
    loggy.info('Starting auto sync with interval: ${interval.inMinutes} minutes');
    
    _syncTimer = Timer.periodic(interval, (timer) {
      syncAll();
    });
  }
  
  /// Detener sincronización automática
  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    loggy.info('Auto sync stopped');
  }
  
  /// Sincronizar todos los datos
  Future<void> syncAll() async {
    if (_isSyncing) {
      loggy.debug('Sync already in progress, skipping');
      return;
    }
    
    _isSyncing = true;
    loggy.info('Starting full sync');
    
    try {
      final futures = <Future>[];
      
      // Sincronizar eventos
      if (_eventController != null) {
        futures.add(_syncEvents());
      }
      
      // Sincronizar speakers
      if (_speakerController != null) {
        futures.add(_syncSpeakers());
      }
      
      // Sincronizar feedbacks
      if (_feedbackController != null) {
        futures.add(_syncFeedbacks());
      }
      
      // Ejecutar todas las sincronizaciones en paralelo
      await Future.wait(futures);
      
      loggy.info('Full sync completed successfully');
    } catch (e) {
      loggy.error('Error during sync: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  /// Sincronizar solo eventos
  Future<void> _syncEvents() async {
    try {
      loggy.debug('Syncing events...');
      await _eventController!.loadEvents();
      loggy.debug('Events synced successfully');
    } catch (e) {
      loggy.error('Error syncing events: $e');
    }
  }
  
  /// Sincronizar solo speakers
  Future<void> _syncSpeakers() async {
    try {
      loggy.debug('Syncing speakers...');
      await _speakerController!.loadSpeakers();
      loggy.debug('Speakers synced successfully');
    } catch (e) {
      loggy.error('Error syncing speakers: $e');
    }
  }
  
  /// Sincronizar solo feedbacks
  Future<void> _syncFeedbacks() async {
    try {
      loggy.debug('Syncing feedbacks...');
      await _feedbackController!.syncAllFeedbacks();
      loggy.debug('Feedbacks synced successfully');
    } catch (e) {
      loggy.error('Error syncing feedbacks: $e');
    }
  }
  
  /// Verificar si hay cambios disponibles (para mostrar indicador)
  Future<bool> hasUpdatesAvailable() async {
    try {
      // Aquí puedes implementar lógica para verificar timestamps
      // o versiones para saber si hay actualizaciones disponibles
      // Por ahora, siempre retorna false como ejemplo
      return false;
    } catch (e) {
      loggy.error('Error checking for updates: $e');
      return false;
    }
  }
  
  /// Obtener estado de sincronización
  bool get isSyncing => _isSyncing;
  
  /// Obtener estado del auto-sync
  bool get isAutoSyncActive => _syncTimer?.isActive ?? false;
  
  /// Cleanup
  void dispose() {
    stopAutoSync();
    loggy.info('SyncService disposed');
  }
} 