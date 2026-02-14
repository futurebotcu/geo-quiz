import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/menu_screen.dart';
import 'services/settings_provider.dart';
import 'services/locale_controller.dart';
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
          supportedLocales: const [
            Locale('en'),
            Locale('tr'),
          ],
          locale: localeController.override,
          localeResolutionCallback: (locale, supported) {
            // If locale override is set, use it
            if (localeController.override != null) {
              return localeController.override;
            }
            // Otherwise, try to match system locale
            if (locale == null) return const Locale('en');
            for (final l in supported) {
              if (l.languageCode == locale.languageCode) return l;
            }
            return const Locale('en');
          },
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
            useMaterial3: true,
            // Tüm uygulama varsayılan fontu:
            textTheme: GoogleFonts.nunitoTextTheme(),
            // Başlıkları biraz daha koyu yapalım:
            appBarTheme: AppBarTheme(
              titleTextStyle: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4F46E5),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            textTheme: GoogleFonts.nunitoTextTheme(
                ThemeData(brightness: Brightness.dark).textTheme),
            appBarTheme: AppBarTheme(
              titleTextStyle: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          builder: (context, child) {
            final locale = Localizations.localeOf(context);
            // RTL languages: ar (Arabic), he (Hebrew), fa (Persian), ur (Urdu)
            const rtlLangs = {'ar', 'he', 'fa', 'ur'};
            final forceLtr =
                !rtlLangs.contains(locale.languageCode.toLowerCase());
            return Directionality(
              textDirection: forceLtr ? TextDirection.ltr : TextDirection.rtl,
              child: child!,
            );
          },
          home: const MenuScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
