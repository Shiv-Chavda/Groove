// Build-time environment configuration (set via --dart-define)
// Examples:
// flutter run --dart-define=PROD=true --dart-define=PROD_BASE=https://galaxtune.onrender.com
// flutter run --dart-define=DEV_HOST=192.168.1.10 --dart-define=DEV_PORT=9000

class Env {
  // If true, use production base URL
  static const bool prod = bool.fromEnvironment('PROD', defaultValue: false);

  // Production base URL (only used when prod=true)
  static const String prodBase = String.fromEnvironment(
    'PROD_BASE',
    defaultValue: 'https://galaxtune.onrender.com',
  );

  // Dev overrides (optional)
  static const String devHostOverride = String.fromEnvironment(
    'DEV_HOST',
    defaultValue: '',
  );
  static const String devPort = String.fromEnvironment(
    'DEV_PORT',
    defaultValue: '9000',
  );
}
