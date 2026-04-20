/// Static app metadata. Kept as constants so we don't pull in a runtime
/// package dependency (e.g. package_info_plus) for a value that's
/// authoritative at build time and already declared in pubspec.yaml.
///
/// Keep in sync with `pubspec.yaml`'s `version:` line on each release.
class AppInfo {
  const AppInfo._();

  /// Semantic version displayed to the user.
  static const String version = '1.0.1';

  /// Platform build / versionCode. Must increase on each Play Store upload.
  static const int buildNumber = 3;

  /// `1.0.0 (2)` — user-visible release label.
  static String get displayVersion => '$version ($buildNumber)';

  /// Support contact email surfaced in Settings → Support.
  static const String supportEmail = 'trultruva@gmail.com';
}
