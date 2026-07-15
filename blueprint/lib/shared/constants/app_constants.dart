class AppConstants {
  // Debug
  static const String debugPrefix = 'debug_';
  // ---------------------------------------------------------------------------
  // Logging
  static const int logStacktraceNumber = 5;

  /// Sentry DSN - By default, it is project "Pixelita"
  static const String sentryDsn = 'https://3a136dc602b6f06602e1f9f87119d40c@o4511727383871488.ingest.de.sentry.io/4511727449669712';
  // ---------------------------------------------------------------------------
  // Network
  static const String goRestBaseUrl = 'https://gorest.co.in/public/v2';
  static const String goRestApiToken = String.fromEnvironment(
    'GOREST_API_TOKEN',
  );
  // ---------------------------------------------------------------------------
}
