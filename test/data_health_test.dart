import 'package:flutter_test/flutter_test.dart';
import 'package:geo_quiz/utils/data_health.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DataHealth Tests', () {
    test('probe loads real manifests and reports all modes healthy', () async {
      final h = await DataHealth.probe();
      // Project bundles 195 capital entries (≥80 with photos), 195 flags,
      // 35 foods — all thresholds are met.
      expect(h.hasCapitalPhotos, isTrue);
      expect(h.hasFlags, isTrue);
      expect(h.hasFoods, isTrue);
    });

    test('isEnabled: real modes map to their respective availability', () {
      const h = DataHealth(
        hasCapitalPhotos: true,
        hasFlags: true,
        hasFoods: true,
      );
      expect(h.isEnabled('foodCountry'), isTrue);
      expect(h.isEnabled('capitalPhoto'), isTrue);
      // flagCountry and capitalCountry are always enabled (emoji/text-only).
      expect(h.isEnabled('flagCountry'), isTrue);
      expect(h.isEnabled('capitalCountry'), isTrue);
    });

    test('isEnabled: disabled photo modes reflect missing data', () {
      const h = DataHealth(
        hasCapitalPhotos: false,
        hasFlags: true,
        hasFoods: false,
      );
      expect(h.isEnabled('foodCountry'), isFalse);
      expect(h.isEnabled('capitalPhoto'), isFalse);
      // Text/emoji modes remain available.
      expect(h.isEnabled('flagCountry'), isTrue);
      expect(h.isEnabled('capitalCountry'), isTrue);
    });

    test('isEnabled: mixed requires at least one photo-based mode', () {
      // Only text/emoji modes available → mixed is NOT meaningful.
      const barren = DataHealth(
        hasCapitalPhotos: false,
        hasFlags: true,
        hasFoods: false,
      );
      expect(barren.isEnabled('mixed'), isFalse);

      // With foods only → mixed OK.
      const withFoods = DataHealth(
        hasCapitalPhotos: false,
        hasFlags: true,
        hasFoods: true,
      );
      expect(withFoods.isEnabled('mixed'), isTrue);

      // With capital photos only → mixed OK.
      const withCapitals = DataHealth(
        hasCapitalPhotos: true,
        hasFlags: true,
        hasFoods: false,
      );
      expect(withCapitals.isEnabled('mixed'), isTrue);
    });

    test('getTooltipMessage returns guidance only for disabled modes', () {
      const h = DataHealth(
        hasCapitalPhotos: false,
        hasFlags: true,
        hasFoods: false,
      );
      // Enabled mode → null tooltip.
      expect(h.getTooltipMessage('flagCountry'), isNull);
      // Disabled modes → non-null message.
      expect(h.getTooltipMessage('foodCountry'), isNotNull);
      expect(h.getTooltipMessage('capitalPhoto'), isNotNull);
      expect(h.getTooltipMessage('mixed'), isNotNull);
    });
  });
}
