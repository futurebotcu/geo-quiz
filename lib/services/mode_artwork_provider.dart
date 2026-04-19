// lib/services/mode_artwork_provider.dart
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../core/models.dart';
import '../utils/emoji.dart' as emoji_utils;

class ModeArtwork {
  final ImageProvider? image;
  final String? emoji; // flagCountry için
  const ModeArtwork({this.image, this.emoji});
}

class ModeArtworkProvider {
  static final _rng = Random();

  // Per-mode cache: first pick stays stable for the rest of the process so
  // mode cards do not re-randomize on every rebuild and precache actually
  // matches what renders.
  static final Map<QuizMode, Future<ModeArtwork>> _cache = {};

  static const _dirs = {
    QuizMode.foodCountry: 'assets/food_photos/',
    QuizMode.capitalPhoto: 'assets/capital_photos/',
    QuizMode.capitalCountry: 'assets/capital_photos/',
    QuizMode.mixed: 'assets/ui_banners/',
  };

  // Karma mod için birden fazla klasörden seçim
  static const _mixedDirs = <String>[
    'assets/capital_photos/',
    'assets/food_photos/',
    'assets/ui_banners/',
    'assets/ui_backgrounds/',
  ];

  /// Asset manifest'ten prefix ile başlayan tüm asset'leri çeker
  static Future<List<String>> _listAssets(String prefix) async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest.listAssets().where((key) {
        return key.startsWith(prefix) &&
            (key.endsWith('.jpg') ||
                key.endsWith('.png') ||
                key.endsWith('.jpeg'));
      }).toList();
    } catch (e) {
      debugPrint('[ModeArtworkProvider] Error reading AssetManifest: $e');
      return [];
    }
  }

  /// Mod için rastgele bir görsel/emoji seçer. İlk çağrı random seçer,
  /// sonraki çağrılar aynı Future'ı döndürür (memoization).
  static Future<ModeArtwork> pick(QuizMode mode) {
    return _cache.putIfAbsent(mode, () => _pickImpl(mode));
  }

  static Future<ModeArtwork> _pickImpl(QuizMode mode) async {
    // Bayrak modu: emoji kullan
    if (mode == QuizMode.flagCountry) {
      // Rastgele bir ülke ISO2 kodu seç (veya TR default)
      final isos = ['tr', 'us', 'fr', 'de', 'jp', 'gb', 'it', 'es', 'br', 'cn'];
      final randomIso = isos[_rng.nextInt(isos.length)];
      return ModeArtwork(emoji: emoji_utils.flagEmoji(randomIso));
    }

    // Karma modu: birden fazla klasörden karışık seçim
    if (mode == QuizMode.mixed) {
      // Tüm klasörlerden asset listelerini topla
      final lists = await Future.wait(_mixedDirs.map(_listAssets));
      final all = <String>[
        for (final l in lists) ...l,
      ];

      if (all.isEmpty) {
        // Hiçbir görsel bulunamadı, fallback
        return ModeArtwork(
          image: const AssetImage('assets/ui_backgrounds/bg_worldmap.jpg'),
        );
      }

      // Rastgele bir görsel seç
      final path = all[_rng.nextInt(all.length)];

      return ModeArtwork(
        image: ResizeImage(
          AssetImage(path),
          width: 1400, // karma mod için biraz daha büyük
          height: 900,
        ),
      );
    }

    // Diğer modlar: klasörden rastgele resim
    final dir = _dirs[mode];
    if (dir == null) {
      // Fallback
      return ModeArtwork(
        image: const AssetImage('assets/ui_backgrounds/bg_worldmap.jpg'),
      );
    }

    final list = await _listAssets(dir);
    if (list.isEmpty) {
      // Güvenli fallback
      return ModeArtwork(
        image: const AssetImage('assets/ui_backgrounds/bg_worldmap.jpg'),
      );
    }

    final path = list[_rng.nextInt(list.length)];

    // Web'de hızlı render için ResizeImage ile downscale
    final image = ResizeImage(
      AssetImage(path),
      width: 1200, // kart geniş; kalite iyi
      height: 800,
    );

    return ModeArtwork(image: image);
  }

  /// Mod için görseli önceden yükle (precache)
  static Future<void> precacheFor(BuildContext context, QuizMode mode) async {
    try {
      final art = await pick(mode);
      if (art.image != null && context.mounted) {
        await precacheImage(art.image!, context);
      }
    } catch (e) {
      debugPrint('[ModeArtworkProvider] Precache error for $mode: $e');
    }
  }
}
