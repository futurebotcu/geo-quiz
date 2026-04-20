import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/menu_screen.dart';
import 'services/settings_provider.dart';
import 'services/locale_controller.dart';
import 'services/app_locales.dart';
import 'theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocaleController()..load()),
      ],
      child: const GeoQuizApp(),
    ),
  );
}

class GeoQuizApp extends StatelessWidget {
  const GeoQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleController>(
      builder: (context, localeController, child) {
        return MaterialApp(
          onGenerateTitle: (context) => S.of(context).appName,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocales.supportedLocales,
          locale: localeController.override,
          localeResolutionCallback: (locale, supported) {
            // Manual override always wins.
            if (localeController.override != null) {
              return localeController.override;
            }
            // System default: resolve against our registry (exact match,
            // then languageCode-only, then English fallback).
            return AppLocales.resolveForSystem(locale).locale;
          },
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const MenuScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
