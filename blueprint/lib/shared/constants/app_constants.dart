class AppConstants {
  // Logging
  static const int logStacktraceNumber = 5;
  // ---------------------------------------------------------------------------
  // Network
  static const String goRestBaseUrl = 'https://gorest.co.in/public/v2';
  static const String goRestApiToken = String.fromEnvironment(
    'GOREST_API_TOKEN',
  );
  // ---------------------------------------------------------------------------
}
