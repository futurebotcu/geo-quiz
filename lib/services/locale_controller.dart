import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controller for managing app locale/language settings
class LocaleController extends ChangeNotifier {
  Locale? _override;

  /// Current locale override (null = system default)
  Locale? get override => _override;

  /// Load saved locale from SharedPreferences
  Future<void> load() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final code = sp.getString('app_locale_code');
      _override = (code == null || code.isEmpty) ? null : Locale(code);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading locale: $e');
      _override = null;
    }
  }

  /// Set locale and save to SharedPreferences
  Future<void> setLocale(Locale? locale) async {
    _override = locale;
    notifyListeners();

    try {
      final sp = await SharedPreferences.getInstance();
      if (locale == null) {
        await sp.remove('app_locale_code');
      } else {
        await sp.setString('app_locale_code', locale.languageCode);
      }
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Get display name for locale
  String getLocaleName(Locale? locale) {
    if (locale == null) return 'System Default';
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}
