import '../config/app_config.dart';

/// API Configuration Constants
class ApiConstants {
  // Base URL with contract key replacement
  static String get baseUrl =>
      '${AppConfig.baseUrl}/${AppConfig.contractKey}';

  // Contract key from configuration
  static String get contractKey => AppConfig.contractKey;

  // API Endpoints
  static const String dataPath = '/data';
  static const String store = '/data/store';
  static const String allData = '/all';
  static const String update = '/update';
  static const String delete = '/delete';

  // Table names
  static const String speakersTable = 'speakers';
  static const String eventsTable = 'events';
  static const String eventSpeakersTable = 'event_speakers';
  static const String tracksTable = 'tracks';
  static const String eventTracksTable = 'event_tracks';
  static const String feedbacksTable = 'feedbacks';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout settings
  static Duration get timeoutDuration => AppConfig.apiTimeout;

  // Build full URL for a table endpoint
  static String buildTableUrl(String tableName) {
    return '$baseUrl$dataPath/$tableName';
  }

  // Build full URL for specific operations
  static String buildStoreUrl() {
    return '${AppConfig.baseUrl}/$contractKey$store';
  }

  static String buildAllDataUrl(String tableName) {
    return '${buildTableUrl(tableName)}$allData?format=json';
  }

  static String buildUpdateUrl(String tableName, int id) {
    return '${buildTableUrl(tableName)}$update/$id';
  }

  static String buildDeleteUrl(String tableName, int id) {
    return '${buildTableUrl(tableName)}$delete/$id';
  }
}
