import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geo_quiz/core/models.dart';
import 'package:geo_quiz/services/settings_provider.dart';
import 'package:geo_quiz/services/locale_controller.dart';
import 'package:geo_quiz/services/storage_service.dart';
import 'package:geo_quiz/screens/quiz_screen.dart';
import 'package:geo_quiz/l10n/app_localizations.dart';

Widget _wrap(Widget home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
      ChangeNotifierProvider(create: (_) => LocaleController()..load()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
      locale: const Locale('en'),
      home: home,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    StorageService.resetForTesting();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('QuizScreen loads questions and renders 4 options',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const QuizScreen(
        settings: QuizSettings(
          mode: QuizMode.capitalCountry, // text-only mode = deterministic
          questionCount: 3,
        ),
      ),
    ));

    // Allow manifest loads + question generation.
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Loading indicator gone.
    expect(find.byType(CircularProgressIndicator), findsNothing);
    // 4 option buttons rendered (ElevatedButton per option).
    expect(find.byType(ElevatedButton), findsNWidgets(4));
  });

  testWidgets(
      'QuizScreen: popping after answer does not crash within timer window',
      (tester) async {
    // Wrap QuizScreen in a nav that we can push/pop.
    final navKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => SettingsProvider()..initialize()),
          ChangeNotifierProvider(create: (_) => LocaleController()..load()),
        ],
        child: MaterialApp(
          navigatorKey: navKey,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('tr')],
          locale: const Locale('en'),
          home: Builder(
            builder: (ctx) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => const QuizScreen(
                        settings: QuizSettings(
                          mode: QuizMode.capitalCountry,
                          questionCount: 2,
                        ),
                      ),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Push QuizScreen.
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Tap first option to trigger _submitAnswer (which schedules 2s timer).
    final options = find.byType(ElevatedButton);
    expect(options, findsAtLeastNWidgets(4));
    await tester.tap(options.first);
    await tester.pump(const Duration(milliseconds: 100));

    // Pop before timer fires.
    navKey.currentState!.pop();
    // Advance past 2s timer — if cancel is broken, it would fire on disposed
    // context and likely throw.
    await tester.pump(const Duration(seconds: 3));

    expect(tester.takeException(), isNull);
  });
}
