import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geo_quiz/services/app_locales.dart';
import 'package:geo_quiz/services/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleController', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('load without saved preference yields null override', () async {
      final c = LocaleController();
      await c.load();
      expect(c.override, isNull);
      expect(c.hasOverride, isFalse);
    });

    test('load restores saved supported locale', () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'tr'});
      final c = LocaleController();
      await c.load();
      expect(c.override, equals(const Locale('tr')));
      expect(c.hasOverride, isTrue);
    });

    test('load discards saved unsupported code (falls back to system)',
        () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'xx'});
      final c = LocaleController();
      await c.load();
      expect(c.override, isNull);
    });

    test('setLocale persists and notifies for supported locale', () async {
      final c = LocaleController();
      await c.load();
      int notifyCount = 0;
      c.addListener(() => notifyCount++);

      await c.setLocale(const Locale('de'));
      expect(c.override, equals(const Locale('de')));
      expect(notifyCount, equals(1));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), equals('de'));
    });

    test('setLocale rejects unsupported code without changing state',
        () async {
      final c = LocaleController();
      await c.load();
      await c.setLocale(const Locale('xx'));
      expect(c.override, isNull);
    });

    test('useSystemDefault clears override and removes saved value',
        () async {
      SharedPreferences.setMockInitialValues({'app_locale_code': 'tr'});
      final c = LocaleController();
      await c.load();
      expect(c.override, isNotNull);

      await c.useSystemDefault();
      expect(c.override, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale_code'), isNull);
    });
  });

  group('AppLocales resolver', () {
    test('supports all 12 expected language codes', () {
      final codes = AppLocales.supported.map((m) => m.code).toSet();
      expect(codes, {
        'en', 'tr', 'de', 'fr', 'es', 'it',
        'pt', 'ru', 'ja', 'zh', 'ar', 'ko',
      });
    });

    test('language-code-only system locales resolve to supported entry', () {
      expect(AppLocales.resolveForSystem(const Locale('en_US')).code, 'en');
      expect(AppLocales.resolveForSystem(const Locale('en_GB')).code, 'en');
      expect(AppLocales.resolveForSystem(const Locale('de_AT')).code, 'de');
      expect(AppLocales.resolveForSystem(const Locale('pt_BR')).code, 'pt');
      expect(AppLocales.resolveForSystem(const Locale('zh_TW')).code, 'zh');
      expect(AppLocales.resolveForSystem(const Locale('es_AR')).code, 'es');
    });

    test('unsupported system locale falls back to English', () {
      expect(AppLocales.resolveForSystem(const Locale('xx')).code, 'en');
      expect(AppLocales.resolveForSystem(null).code, 'en');
    });

    test('effective honours override over system locale', () {
      final m = AppLocales.effective(
        override: const Locale('ja'),
        systemLocale: const Locale('fr_FR'),
      );
      expect(m.code, 'ja');
    });

    test('effective falls back to system when override is null', () {
      final m = AppLocales.effective(
        override: null,
        systemLocale: const Locale('ko_KR'),
      );
      expect(m.code, 'ko');
    });

    test('Arabic meta is marked RTL', () {
      final m = AppLocales.byCode('ar');
      expect(m, isNotNull);
      expect(m!.direction, TextDirection.rtl);
    });
  });
}
