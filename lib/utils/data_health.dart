// lib/utils/data_health.dart
import 'image_picker.dart';

/// Veri sağlık kontrolü - hangi modların oynanabilir olduğunu belirler
class DataHealth {
  final bool hasCapitalPhotos; // >= 80 (capitalPhoto modu için)
  final bool
      hasFlags; // >= 150 (emoji fallback sayesinde her zaman true olmalı)
  final bool hasFoods; // >= 25 (foodCountry modu için)

  const DataHealth({
    required this.hasCapitalPhotos,
    required this.hasFlags,
    required this.hasFoods,
  });

  /// Hızlı veri sağlık kontrolü (IO'suz sayım)
  static Future<DataHealth> probe() async {
    final capitalItems = await loadCapitalManifest();
    final flagItems = await loadFlagManifest();
    final foodItems = await loadFoodManifest();

    // Capital photos: en az 80 foto olmalı
    final capitalCount = capitalItems.where((item) => item.hasPhoto).length;
    final hasCapitalPhotos = capitalCount >= 80;

    // Flags: emoji fallback var, her zaman true
    // Ama manifest'te en az 150 ülke olmalı
    final hasFlags = flagItems.length >= 150;

    // Foods: en az 25 yemek olmalı
    final hasFoods = foodItems.length >= 25;

    return DataHealth(
      hasCapitalPhotos: hasCapitalPhotos,
      hasFlags: hasFlags,
      hasFoods: hasFoods,
    );
  }

  /// Mod kartı için enabled durumu
  bool isEnabled(String mode) {
    switch (mode) {
      case 'foodCountry':
        return hasFoods;
      case 'capitalPhoto':
        return hasCapitalPhotos;
      case 'cityToCountry':
      case 'capitalCountry':
        return true; // foto gerekmiyor, sadece metin
      case 'flagCountry':
        return true; // emoji fallback var
      case 'mixed':
        // Mixed gerçek çeşitlilik için en az 1 foto-bazlı mod gerektirir.
        // Flag (emoji fallback) + capitalCountry (metin) tek formatta kalır,
        // bu "mixed" deneyimi sayılmaz.
        return hasFoods || hasCapitalPhotos;
      default:
        return false;
    }
  }

  /// Eksik veri için tooltip mesajı
  String? getTooltipMessage(String mode) {
    if (isEnabled(mode)) return null;

    switch (mode) {
      case 'foodCountry':
        return 'Yemek fotoğrafları eksik (min 25)';
      case 'capitalPhoto':
        return 'Başkent fotoğrafları eksik (min 80)';
      case 'mixed':
        return 'Yeterli veri yok (min 2 mod gerekli)';
      default:
        return 'Veri eksik';
    }
  }
}
