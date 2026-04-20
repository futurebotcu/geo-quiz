import '../core/models.dart';
import 'image_picker.dart';

/// Runtime locale-aware lookup for answer-option labels. The quiz engine
/// produces parallel `options` + `optionIso2s` lists; the UI uses this
/// helper to re-resolve option text whenever the active locale changes
/// (mid-quiz language switches included).
class CountryLocalizer {
  CountryLocalizer._();

  static Map<String, CountryItem> _byIso = const {};

  /// Build/refresh the iso2 index. Called once from the quiz screen after
  /// the engine has loaded its country list, or whenever the dataset is
  /// reloaded (dev-only — in prod the data is static).
  static void setCountries(Iterable<CountryItem> items) {
    _byIso = {
      for (final c in items) c.iso2.toLowerCase(): c,
    };
  }

  static bool get isReady => _byIso.isNotEmpty;

  /// Resolve an option label for the given iso2 + kind + language.
  /// Falls back to [fallback] (the quiz-start-time string) when the iso2
  /// isn't in the index — keeps the option visible rather than blank.
  static String labelFor({
    required String iso2,
    required OptionKind kind,
    required String languageCode,
    required String fallback,
  }) {
    final c = _byIso[iso2.toLowerCase()];
    if (c == null) return fallback;
    final v = kind == OptionKind.country
        ? c.nameFor(languageCode)
        : c.capitalFor(languageCode);
    return v.isNotEmpty ? v : fallback;
  }

  static String? capitalOf(String iso2, String languageCode) {
    final c = _byIso[iso2.toLowerCase()];
    if (c == null) return null;
    final v = c.capitalFor(languageCode);
    return v.isEmpty ? null : v;
  }
}
