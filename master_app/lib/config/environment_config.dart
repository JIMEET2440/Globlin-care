import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Environment configuration loader for Globin Care
/// Reads and manages environment variables from .env file
class EnvironmentConfig {
  static final EnvironmentConfig _instance = EnvironmentConfig._internal();
  static final Map<String, String> _envVars = {};
  static bool _isInitialized = false;

  factory EnvironmentConfig() {
    return _instance;
  }

  EnvironmentConfig._internal();

  /// Initialize environment configuration
  /// Must be called before accessing any environment variables
  /// 
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      final envFile = File('.env');
      
      if (await envFile.exists()) {
        final contents = await envFile.readAsString();
        _parseEnvFile(contents);
        if (kDebugMode) {
          print('✓ Environment configuration loaded successfully');
        }
      } else {
        if (kDebugMode) {
          print('⚠ .env file not found. Using default values.');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠ Error loading .env file: $e');
      }
    }

    _isInitialized = true;
  }

  /// Parse .env file content
  static void _parseEnvFile(String content) {
    final lines = content.split('\n');
    
    for (final line in lines) {
      // Skip empty lines and comments
      if (line.isEmpty || line.trim().startsWith('#')) {
        continue;
      }

      // Parse key=value pairs
      if (line.contains('=')) {
        final parts = line.split('=');
        final key = parts[0].trim();
        final value = parts.sublist(1).join('=').trim();

        // Remove quotes if present
        String cleanValue = value;
        if ((cleanValue.startsWith('"') && cleanValue.endsWith('"')) ||
            (cleanValue.startsWith("'") && cleanValue.endsWith("'"))) {
          cleanValue = cleanValue.substring(1, cleanValue.length - 1);
        }

        _envVars[key] = cleanValue;
      }
    }
  }

  /// Get environment variable by key
  static String? get(String key, {String? defaultValue}) {
    return _envVars[key] ?? defaultValue;
  }

  /// Get environment variable as boolean
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = _envVars[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Get environment variable as integer
  static int getInt(String key, {int defaultValue = 0}) {
    final value = _envVars[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get environment variable as double
  static double getDouble(String key, {double defaultValue = 0.0}) {
    final value = _envVars[key];
    if (value == null) return defaultValue;
    return double.tryParse(value) ?? defaultValue;
  }

  /// Get all environment variables (for debugging)
  static Map<String, String> getAll() {
    return Map.from(_envVars);
  }

  /// Check if a key exists
  static bool has(String key) {
    return _envVars.containsKey(key);
  }
}

/// Predefined environment constants for easy access
class AppConfig {
  // App Configuration
  static String get appName => EnvironmentConfig.get('APP_NAME', defaultValue: 'Globin Care') ?? 'Globin Care';
  static String get appEnv => EnvironmentConfig.get('APP_ENV', defaultValue: 'development') ?? 'development';
  static bool get debugMode => EnvironmentConfig.getBool('DEBUG_MODE', defaultValue: true);

  // API Configuration
  static String get apiBaseUrl => EnvironmentConfig.get('API_BASE_URL', defaultValue: 'http://localhost:8000/api') ?? '';
  static int get apiTimeout => EnvironmentConfig.getInt('API_TIMEOUT', defaultValue: 30);
  static String get authLoginEndpoint => EnvironmentConfig.get('AUTH_LOGIN_ENDPOINT', defaultValue: '/auth/login') ?? '';
  static String get authLogoutEndpoint => EnvironmentConfig.get('AUTH_LOGOUT_ENDPOINT', defaultValue: '/auth/logout') ?? '';
  static String get authRefreshTokenEndpoint => EnvironmentConfig.get('AUTH_REFRESH_TOKEN_ENDPOINT', defaultValue: '/auth/refresh') ?? '';

  // Database Configuration
  static String get dbHost => EnvironmentConfig.get('DB_HOST', defaultValue: 'localhost') ?? '';
  static int get dbPort => EnvironmentConfig.getInt('DB_PORT', defaultValue: 5432);
  static String get dbName => EnvironmentConfig.get('DB_NAME', defaultValue: 'globin_care_db') ?? '';
  static String get dbUser => EnvironmentConfig.get('DB_USER', defaultValue: 'admin') ?? '';
  static String get dbPassword => EnvironmentConfig.get('DB_PASSWORD', defaultValue: '') ?? '';

  // JWT Configuration
  static String get jwtSecretKey => EnvironmentConfig.get('JWT_SECRET_KEY', defaultValue: '') ?? '';
  static int get jwtExpiryHours => EnvironmentConfig.getInt('JWT_EXPIRY_HOURS', defaultValue: 24);
  static int get jwtRefreshExpiryDays => EnvironmentConfig.getInt('JWT_REFRESH_EXPIRY_DAYS', defaultValue: 7);

  // OAuth Configuration
  static String get googleClientId => EnvironmentConfig.get('GOOGLE_CLIENT_ID', defaultValue: '') ?? '';
  static String get googleClientSecret => EnvironmentConfig.get('GOOGLE_CLIENT_SECRET', defaultValue: '') ?? '';
  static String get facebookAppId => EnvironmentConfig.get('FACEBOOK_APP_ID', defaultValue: '') ?? '';
  static String get facebookAppSecret => EnvironmentConfig.get('FACEBOOK_APP_SECRET', defaultValue: '') ?? '';

  // Email Configuration
  static String get smtpHost => EnvironmentConfig.get('SMTP_HOST', defaultValue: 'smtp.gmail.com') ?? '';
  static int get smtpPort => EnvironmentConfig.getInt('SMTP_PORT', defaultValue: 587);
  static String get smtpUser => EnvironmentConfig.get('SMTP_USER', defaultValue: '') ?? '';
  static String get smtpPassword => EnvironmentConfig.get('SMTP_PASSWORD', defaultValue: '') ?? '';
  static String get smtpFromEmail => EnvironmentConfig.get('SMTP_FROM_EMAIL', defaultValue: 'noreply@globincare.com') ?? '';
  static String get smtpFromName => EnvironmentConfig.get('SMTP_FROM_NAME', defaultValue: 'Globin Care') ?? '';



  // Firebase Configuration
  static String get firebaseApiKey => EnvironmentConfig.get('FIREBASE_API_KEY', defaultValue: '') ?? '';
  static String get firebaseProjectId => EnvironmentConfig.get('FIREBASE_PROJECT_ID', defaultValue: '') ?? '';
  static String get firebaseMessagingSenderId => EnvironmentConfig.get('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '') ?? '';
  static String get firebaseAppId => EnvironmentConfig.get('FIREBASE_APP_ID', defaultValue: '') ?? '';

  // Stripe Configuration
  static String get stripePublicKey => EnvironmentConfig.get('STRIPE_PUBLIC_KEY', defaultValue: '') ?? '';
  static String get stripeSecretKey => EnvironmentConfig.get('STRIPE_SECRET_KEY', defaultValue: '') ?? '';
  static String get stripeWebhookSecret => EnvironmentConfig.get('STRIPE_WEBHOOK_SECRET', defaultValue: '') ?? '';

  // AWS Configuration
  static String get awsAccessKeyId => EnvironmentConfig.get('AWS_ACCESS_KEY_ID', defaultValue: '') ?? '';
  static String get awsSecretAccessKey => EnvironmentConfig.get('AWS_SECRET_ACCESS_KEY', defaultValue: '') ?? '';
  static String get awsRegion => EnvironmentConfig.get('AWS_REGION', defaultValue: 'us-east-1') ?? '';
  static String get awsS3Bucket => EnvironmentConfig.get('AWS_S3_BUCKET', defaultValue: '') ?? '';

  // Logging Configuration
  static String get logLevel => EnvironmentConfig.get('LOG_LEVEL', defaultValue: 'info') ?? '';
  static String get logFilePath => EnvironmentConfig.get('LOG_FILE_PATH', defaultValue: './logs/app.log') ?? '';
  static String get logMaxFileSize => EnvironmentConfig.get('LOG_MAX_FILE_SIZE', defaultValue: '10M') ?? '';

  // Security Configuration
  static bool get enableSsl => EnvironmentConfig.getBool('ENABLE_SSL', defaultValue: true);
  static String get corsOrigins => EnvironmentConfig.get('CORS_ORIGINS', defaultValue: 'http://localhost:3000') ?? '';
  static int get sessionTimeoutMinutes => EnvironmentConfig.getInt('SESSION_TIMEOUT_MINUTES', defaultValue: 30);
  static int get passwordMinLength => EnvironmentConfig.getInt('PASSWORD_MIN_LENGTH', defaultValue: 8);
  static bool get passwordRequireUppercase => EnvironmentConfig.getBool('PASSWORD_REQUIRE_UPPERCASE', defaultValue: true);
  static bool get passwordRequireNumbers => EnvironmentConfig.getBool('PASSWORD_REQUIRE_NUMBERS', defaultValue: true);
  static bool get passwordRequireSpecialChars => EnvironmentConfig.getBool('PASSWORD_REQUIRE_SPECIAL_CHARS', defaultValue: true);

  // Feature Flags
  static bool get enableTwoFactorAuth => EnvironmentConfig.getBool('ENABLE_TWO_FACTOR_AUTH', defaultValue: true);
  static bool get enableBiometricLogin => EnvironmentConfig.getBool('ENABLE_BIOMETRIC_LOGIN', defaultValue: true);
  static bool get enableDarkMode => EnvironmentConfig.getBool('ENABLE_DARK_MODE', defaultValue: true);
  static bool get enableOfflineMode => EnvironmentConfig.getBool('ENABLE_OFFLINE_MODE', defaultValue: false);
  static bool get maintenanceMode => EnvironmentConfig.getBool('MAINTENANCE_MODE', defaultValue: false);

  // Analytics Configuration
  static bool get analyticsEnabled => EnvironmentConfig.getBool('ANALYTICS_ENABLED', defaultValue: true);
  static String get googleAnalyticsId => EnvironmentConfig.get('GOOGLE_ANALYTICS_ID', defaultValue: '') ?? '';
  static String get sentryDsn => EnvironmentConfig.get('SENTRY_DSN', defaultValue: '') ?? '';

  // Developer Configuration
  static bool get mockApiResponses => EnvironmentConfig.getBool('MOCK_API_RESPONSES', defaultValue: false);
  static bool get verboseLogging => EnvironmentConfig.getBool('VERBOSE_LOGGING', defaultValue: false);
  static bool get enablePerformanceMonitoring => EnvironmentConfig.getBool('ENABLE_PERFORMANCE_MONITORING', defaultValue: true);
}
