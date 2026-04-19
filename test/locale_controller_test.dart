import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geo_quiz/services/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load without saved preference yields null override', () async {
      final c = LocaleController();
      await c.load();
      expect(c.override, isNull);
    });

    test('load restores saved locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'tr'});
      final c = LocaleController();
      await c.load();
      expect(c.override, equals(const Locale('tr')));
    });

    test('setLocale persists and notifies', () async {
      final c = LocaleController();
      await c.load();
      int notifyCount = 0;
      c.addListener(() => notifyCount++);

      await c.setLocale(const Locale('en'));
      expect(c.override, equals(const Locale('en')));
      expect(notifyCount, equals(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), equals('en'));
    });

    test('setLocale(null) removes saved value', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'tr'});
      final c = LocaleController();
      await c.load();
      expect(c.override, isNotNull);

      await c.setLocale(null);
      expect(c.override, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), isNull);
    });

    test('getLocaleName handles en, tr, null, and unknown codes', () {
      final c = LocaleController();
      expect(c.getLocaleName(null), equals('System Default'));
      expect(c.getLocaleName(const Locale('en')), equals('English'));
      expect(c.getLocaleName(const Locale('tr')), equals('Türkçe'));
      expect(c.getLocaleName(const Locale('fr')), equals('FR'));
    });
  });
}
