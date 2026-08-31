class AppConstants {
  // ---------------------------------------------------------------------------
  // Logging
  static const int logStacktraceNumber = 5;
  // ---------------------------------------------------------------------------
  // Layout
  /// iPhone portrait aspect ratio (width / height), used to cap the app width
  /// on wide screens (web, desktop).
  static const double iphoneAspectRatio = 9 / 19.5;

  /// Background image shown behind the phone frame on web.
  static const String webBackgroundAsset =
      'assets/background/bluestone_background.jpg';
  // ---------------------------------------------------------------------------
  // Network
  static const String goRestBaseUrl = 'https://gorest.co.in/public/v2';
  static const String goRestApiToken = String.fromEnvironment(
    'GOREST_API_TOKEN',
  );
  // ---------------------------------------------------------------------------
}
