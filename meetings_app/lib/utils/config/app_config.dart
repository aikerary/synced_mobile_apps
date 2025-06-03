/// Configuration file for API settings
///
/// IMPORTANT: You must update the contractKey with your actual contract key
/// from the unidb.openlab.uninorte.edu.co service
class AppConfig {
  // Updated contract key for API access
  static const String contractKey = 'bolt1234';

  // API Configuration
  static const String baseUrl = 'https://unidb.openlab.uninorte.edu.co';

  // Development/Debug flags
  static const bool enableApiLogging = true;
  static const bool enableDebugMode = true;

  // Timeout settings
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // Cache settings
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100; // number of items

  // Offline settings
  static const bool enableOfflineMode = true;
  static const Duration syncInterval = Duration(minutes: 15);
  
  // Auto-sync settings
  static const bool enableAutoSync = true;
  static const Duration autoSyncInterval = Duration(minutes: 5);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);
  static const Duration onResumeDelay = Duration(seconds: 2);
}

/// Environment-specific configurations
class Environment {
  static const String development = 'development';
  static const String production = 'production';

  // Current environment - change this for different builds
  static const String current = development;

  static bool get isDevelopment => current == development;
  static bool get isProduction => current == production;
}
