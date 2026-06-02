/// Centralised, build-time application configuration.
///
/// All values are read from `--dart-define` so that secrets and
/// environment-specific endpoints are never hardcoded in source. Provide
/// them at build time, e.g.:
///
/// ```
/// flutter build apk --release \
///   --dart-define=POCKETBASE_BASE_URL=https://api.example.com \
///   --dart-define=RECAPTCHA_V3_SITE_KEY=6Lxxxxxxxxxxxxxxxxxxx
/// ```
///
/// A `--dart-define-from-file=env.json` is the most convenient way to keep
/// these together; keep that file out of version control.
class AppConfig {
  AppConfig._();

  /// Base URL of the PocketBase backend.
  ///
  /// PRODUCTION REQUIREMENT: this MUST be an `https://` endpoint behind a
  /// domain with a valid TLS certificate. The auth bearer token is sent on
  /// every request, so cleartext HTTP would expose it on the wire. The
  /// default below is for local development only.
  static const String pocketBaseBaseUrl = String.fromEnvironment(
    'POCKETBASE_BASE_URL',
    defaultValue: 'http://195.201.90.14:8080',
  );

  /// reCAPTCHA v3 site key used by Firebase App Check on the web platform.
  /// Obtain it from the Firebase / reCAPTCHA admin console.
  static const String recaptchaV3SiteKey = String.fromEnvironment(
    'RECAPTCHA_V3_SITE_KEY',
    defaultValue: '',
  );

  /// Whether [pocketBaseBaseUrl] uses a secure (TLS) scheme.
  static bool get isBackendSecure =>
      pocketBaseBaseUrl.toLowerCase().startsWith('https://');
}
