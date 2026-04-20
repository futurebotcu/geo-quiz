import 'package:flutter/material.dart';

/// Metadata for a single supported locale. The `flag` is a Unicode
/// regional-indicator pair — used for UI language identification only,
/// not as a country claim.
@immutable
class AppLocaleMeta {
  final Locale locale;
  final String nativeName;
  final String englishName;
  final String flag;
  final TextDirection direction;

  const AppLocaleMeta({
    required this.locale,
    required this.nativeName,
    required this.englishName,
    required this.flag,
    this.direction = TextDirection.ltr,
  });

  String get code => locale.languageCode;
}

/// Central registry of the 12 actively supported languages.
///
/// Order here drives the Settings picker order. English first (default
/// fallback), Turkish second (primary audience), then alphabetical by
/// English name.
class AppLocales {
  AppLocales._();

  static const List<AppLocaleMeta> supported = <AppLocaleMeta>[
    AppLocaleMeta(
      locale: Locale('en'),
      nativeName: 'English',
      englishName: 'English',
      flag: '🇬🇧',
    ),
    AppLocaleMeta(
      locale: Locale('tr'),
      nativeName: 'Türkçe',
      englishName: 'Turkish',
      flag: '🇹🇷',
    ),
    AppLocaleMeta(
      locale: Locale('ar'),
      nativeName: 'العربية',
      englishName: 'Arabic',
      flag: '🇸🇦',
      direction: TextDirection.rtl,
    ),
    AppLocaleMeta(
      locale: Locale('zh'),
      nativeName: '中文',
      englishName: 'Chinese',
      flag: '🇨🇳',
    ),
    AppLocaleMeta(
      locale: Locale('fr'),
      nativeName: 'Français',
      englishName: 'French',
      flag: '🇫🇷',
    ),
    AppLocaleMeta(
      locale: Locale('de'),
      nativeName: 'Deutsch',
      englishName: 'German',
      flag: '🇩🇪',
    ),
    AppLocaleMeta(
      locale: Locale('it'),
      nativeName: 'Italiano',
      englishName: 'Italian',
      flag: '🇮🇹',
    ),
    AppLocaleMeta(
      locale: Locale('ja'),
      nativeName: '日本語',
      englishName: 'Japanese',
      flag: '🇯🇵',
    ),
    AppLocaleMeta(
      locale: Locale('ko'),
      nativeName: '한국어',
      englishName: 'Korean',
      flag: '🇰🇷',
    ),
    AppLocaleMeta(
      locale: Locale('pt'),
      nativeName: 'Português',
      englishName: 'Portuguese',
      flag: '🇵🇹',
    ),
    AppLocaleMeta(
      locale: Locale('ru'),
      nativeName: 'Русский',
      englishName: 'Russian',
      flag: '🇷🇺',
    ),
    AppLocaleMeta(
      locale: Locale('es'),
      nativeName: 'Español',
      englishName: 'Spanish',
      flag: '🇪🇸',
    ),
  ];

  /// Default fallback when nothing else matches — English.
  static const AppLocaleMeta fallback = AppLocaleMeta(
    locale: Locale('en'),
    nativeName: 'English',
    englishName: 'English',
    flag: '🇬🇧',
  );

  static List<Locale> get supportedLocales =>
      supported.map((m) => m.locale).toList(growable: false);

  /// Lookup metadata by language code. Returns null if not supported.
  static AppLocaleMeta? byCode(String? code) {
    if (code == null || code.isEmpty) return null;
    final lower = code.toLowerCase();
    for (final m in supported) {
      if (m.code == lower) return m;
    }
    return null;
  }

  /// Returns true if the language code is in the supported 12-language set.
  static bool isSupported(String? code) => byCode(code) != null;

  /// Resolve a device/system locale against the supported set.
  ///
  /// Order:
  /// 1) exact `languageCode+countryCode` match (future-proof; today only `en`)
  /// 2) `languageCode`-only match (so `en_GB`, `zh_TW`, `pt_BR` all resolve)
  /// 3) fallback to English
  static AppLocaleMeta resolveForSystem(Locale? systemLocale) {
    if (systemLocale == null) return fallback;
    // `Locale('de_AT')` (single-arg constructor) packs the full string into
    // `languageCode`. Normalise by taking the portion before the first
    // separator so `de_AT`, `pt_BR`, `zh-Hans-CN` all resolve cleanly.
    final rawLang = systemLocale.languageCode.toLowerCase();
    final lang = rawLang.split(RegExp(r'[_-]')).first;
    final country = (systemLocale.countryCode ?? '').toLowerCase();

    if (country.isNotEmpty) {
      for (final m in supported) {
        final mc = (m.locale.countryCode ?? '').toLowerCase();
        if (m.code == lang && mc == country) return m;
      }
    }
    final byLang = byCode(lang);
    return byLang ?? fallback;
  }

  /// Given a persisted override (may be null = use system) and the current
  /// system locale, return the effective metadata to display.
  static AppLocaleMeta effective({
    Locale? override,
    Locale? systemLocale,
  }) {
    if (override != null) {
      final m = byCode(override.languageCode);
      if (m != null) return m;
    }
    return resolveForSystem(systemLocale);
  }
}
