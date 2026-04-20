import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../services/utf8_loader.dart';

// Capital Mode — city photos
class CapitalItem {
  final String iso2, country, capital, path;
  final String? webpPath;
  final int width, height;
  final String filename;

  CapitalItem({
    required this.iso2,
    required this.country,
    required this.capital,
    required this.path,
    required this.filename,
    required this.width,
    required this.height,
    this.webpPath,
  });

  factory CapitalItem.fromJson(Map<String, dynamic> j) => CapitalItem(
        iso2: j['iso2'],
        country: j['country'],
        capital: j['capital'],
        path: j['path'] ?? '',
        filename: j['filename'] ?? '',
        width: j['width'] ?? 0,
        height: j['height'] ?? 0,
        webpPath: j['webp_path'],
      );

  Map<String, dynamic> toJson() => {
        'iso2': iso2,
        'country': country,
        'capital': capital,
        'path': path,
        'filename': filename,
        'width': width,
        'height': height,
        'webp_path': webpPath,
      };

  bool get hasPhoto => path.isNotEmpty;
  bool get hasWebP => webpPath != null && webpPath!.isNotEmpty;
}

// Flag Mode — PNG or emoji fallback
class FlagItem {
  final String iso2;
  final String flagAsset;
  final String fallback; // "png" or "emoji"

  FlagItem({
    required this.iso2,
    required this.flagAsset,
    required this.fallback,
  });

  factory FlagItem.fromJson(Map<String, dynamic> j) => FlagItem(
        iso2: j['iso2'],
        flagAsset: j['flag_asset'] ?? '',
        fallback: j['fallback'] ?? 'emoji',
      );

  bool get hasPngFlag => flagAsset.isNotEmpty && fallback == 'png';
  bool get useEmoji => fallback == 'emoji' || flagAsset.isEmpty;
}

// Food Mode — food photos
class FoodItem {
  final String iso2;
  final String country;
  final String dish;
  final String path;

  FoodItem({
    required this.iso2,
    required this.country,
    required this.dish,
    required this.path,
  });

  factory FoodItem.fromJson(Map<String, dynamic> j) => FoodItem(
        iso2: j['iso2'],
        country: j['country'],
        dish: j['dish'],
        path: j['path'],
      );

  Map<String, dynamic> toJson() => {
        'iso2': iso2,
        'country': country,
        'dish': dish,
        'path': path,
      };
}

// Country — general quiz data.
//
// The raw dataset (`data/countries.json`) ships `countryXX` / `capitalXX`
// pairs for every supported language (en, tr + 10 more). We keep a map of
// all labels in-memory and expose `nameFor(lang)` / `capitalFor(lang)` so
// the quiz engine can render answer options in the user's selected
// language. English is the universal fallback when a label is missing.
class CountryItem {
  static const List<String> supportedLangs = <String>[
    'en', 'tr', 'de', 'fr', 'es', 'it', 'pt', 'ru', 'ja', 'zh', 'ar', 'ko',
  ];

  final String iso2;
  final Map<String, String> names;
  final Map<String, String> capitals;
  final String continent;

  CountryItem({
    required this.iso2,
    required this.names,
    required this.capitals,
    required this.continent,
  });

  /// Backwards-compatible default: Turkish with English fallback.
  /// Prefer [nameFor] in new code — this getter is kept for tests and
  /// stats screens that don't know the active locale.
  String get name => names['tr'] ?? names['en'] ?? '';
  String get capital => capitals['tr'] ?? capitals['en'] ?? '';

  /// For convenience — used by distractor generation when it needs a stable
  /// English reference.
  String get nameEN => names['en'] ?? '';
  String get nameTR => names['tr'] ?? '';
  String get capitalEN => capitals['en'] ?? '';
  String get capitalTR => capitals['tr'] ?? '';

  String nameFor(String languageCode) {
    final v = names[languageCode];
    if (v != null && v.isNotEmpty) return v;
    return names['en'] ?? '';
  }

  String capitalFor(String languageCode) {
    final v = capitals[languageCode];
    if (v != null && v.isNotEmpty) return v;
    return capitals['en'] ?? '';
  }

  factory CountryItem.fromJson(Map<String, dynamic> j) {
    final iso2 = j['iso2']?.toString() ?? '';
    final names = <String, String>{};
    final capitals = <String, String>{};
    for (final lang in supportedLangs) {
      final up = lang.toUpperCase();
      final cn = j['country$up']?.toString();
      final cap = j['capital$up']?.toString();
      if (cn != null && cn.isNotEmpty) names[lang] = cn;
      if (cap != null && cap.isNotEmpty) capitals[lang] = cap;
    }
    final region = j['region']?.toString() ?? '';
    final subregion = j['subregion']?.toString() ?? '';
    final continent = deriveContinent(region, subregion);

    if (iso2.isEmpty || names.isEmpty || capitals.isEmpty) {
      debugPrint(
          '[CountryItem] Skipping invalid entry: iso2=$iso2 names=${names.keys} capitals=${capitals.keys}');
    }

    return CountryItem(
      iso2: iso2,
      names: names,
      capitals: capitals,
      continent: continent,
    );
  }
}

/// 6-continent model: Europe, Asia, Africa, North America, South America,
/// Oceania. countries.json stores the 5-region split with "Americas" as one
/// region; we split it via subregion ("South" → South America, otherwise
/// North America which covers Northern America / Central America / Caribbean).
String deriveContinent(String region, String subregion) {
  final r = region.toLowerCase();
  if (r == 'americas') {
    return subregion.toLowerCase().contains('south')
        ? 'South America'
        : 'North America';
  }
  return region.isEmpty ? 'Unknown' : region;
}

// ------ Loaders ------

Future<List<CapitalItem>> loadCapitalManifest() async {
  try {
    final txt = await loadUtf8Asset('data/assets_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => CapitalItem.fromJson(e)).toList();
  } catch (e) {
    debugPrint('[ASSET] Error loading capitals manifest: $e');
    return [];
  }
}

Future<List<FlagItem>> loadFlagManifest() async {
  try {
    final txt = await loadUtf8Asset('data/flags_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => FlagItem.fromJson(e)).toList();
  } catch (e) {
    debugPrint('[ASSET] Error loading flags manifest: $e');
    return [];
  }
}

Future<List<FoodItem>> loadFoodManifest() async {
  try {
    final txt = await loadUtf8Asset('data/foods_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => FoodItem.fromJson(e)).toList();
  } catch (e) {
    debugPrint('[ASSET] Error loading foods manifest: $e');
    return [];
  }
}

Future<List<CountryItem>> loadCountries() async {
  try {
    final txt = await loadUtf8Asset('data/countries.json');
    final List data = json.decode(txt);
    final countries = <CountryItem>[];

    for (final item in data) {
      try {
        final country = CountryItem.fromJson(item);
        if (country.iso2.isNotEmpty &&
            country.name.isNotEmpty &&
            country.capital.isNotEmpty) {
          countries.add(country);
        }
      } catch (e) {
        debugPrint('[ASSET][ERR] Failed to parse country item: $e');
        continue;
      }
    }

    debugPrint('[ASSET] Loaded ${countries.length} valid countries');
    return countries;
  } catch (e) {
    debugPrint('[ASSET][ERR] Error loading countries: $e');
    return [];
  }
}

// ------ Image source helpers ------

String getCapitalImageSource(CapitalItem it) {
  if (it.webpPath != null && it.webpPath!.isNotEmpty) {
    return it.webpPath!;
  }
  if (it.path.isNotEmpty) {
    return it.path;
  }
  return 'assets/placeholders/generic.png';
}

String getFoodImageSource(FoodItem item) {
  if (item.path.isNotEmpty) {
    return item.path;
  }
  return 'assets/placeholders/food_placeholder.png';
}
