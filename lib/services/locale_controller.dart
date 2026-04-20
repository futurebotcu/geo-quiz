import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_locales.dart';

/// Controller for the active app language.
///
/// Two modes:
/// - **Manual override** — user picked a specific language; it persists
///   across launches and always wins.
/// - **System default** (override == null) — the Flutter framework's
///   `localeResolutionCallback` resolves the device locale against the
///   supported set at render time.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale_code';

  Locale? _override;

  /// Current locale override. `null` means "follow system".
  Locale? get override => _override;

  /// True when the user has explicitly picked a language.
  bool get hasOverride => _override != null;

  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final code = sp.getString(_prefsKey);
      if (code != null && code.isNotEmpty && AppLocales.isSupported(code)) {
        _override = Locale(code);
      } else {
        _override = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('LocaleController.load error: $e');
      _override = null;
    }
  }

  /// Set a manual override. Passing `null` clears it (back to system default).
  /// Unsupported codes are rejected silently so the picker can only ever
  /// land on a valid language.
  Future<void> setLocale(Locale? locale) async {
    if (locale != null && !AppLocales.isSupported(locale.languageCode)) {
      debugPrint('LocaleController: rejected unsupported ${locale.languageCode}');
      return;
    }
    _override = locale;
    notifyListeners();

    try {
      final sp = await SharedPreferences.getInstance();
      if (locale == null) {
        await sp.remove(_prefsKey);
      } else {
        await sp.setString(_prefsKey, locale.languageCode);
      }
    } catch (e) {
      debugPrint('LocaleController.setLocale error: $e');
    }
  }

  /// Convenience: clear the override and return to system-default mode.
  Future<void> useSystemDefault() => setLocale(null);

  /// The effective metadata for the current state — honours override, then
  /// system locale, then falls back to English.
  AppLocaleMeta effective(BuildContext context) {
    final system = Localizations.maybeLocaleOf(context) ??
        WidgetsBinding.instance.platformDispatcher.locale;
    return AppLocales.effective(override: _override, systemLocale: system);
  }
}
