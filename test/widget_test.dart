import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:geo_quiz/main.dart';
import 'package:geo_quiz/services/settings_provider.dart';
import 'package:geo_quiz/services/locale_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Geo Quiz app smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
          ChangeNotifierProvider(create: (_) => LocaleController()..load()),
        ],
        child: const GeoQuizApp(),
      ),
    );
    await tester.pumpAndSettle();

    // App should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
