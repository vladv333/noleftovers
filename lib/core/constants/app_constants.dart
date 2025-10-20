class AppConstants {
  // App Info
  static const String appName = 'NoLeftovers';
  static const String appVersion = '1.0.0';

  // Default coordinates (Tallinn, Estonia)
  static const double defaultLatitude = 59.437;
  static const double defaultLongitude = 24.7536;
  static const double defaultZoom = 13.0;

  // Formatting
  static const String currencySymbol = '€';
  static const String dateFormat = 'dd.MM.yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // OpenStreetMap
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String osmUserAgent = 'NoLeftovers';
}