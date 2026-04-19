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

// Country — general quiz data
class CountryItem {
  final String iso2;
  final String name;
  final String capital;
  final String continent;

  CountryItem({
    required this.iso2,
    required this.name,
    required this.capital,
    required this.continent,
  });

  factory CountryItem.fromJson(Map<String, dynamic> j) {
    final iso2 = j['iso2']?.toString() ?? '';
    final name = j['countryTR']?.toString() ?? j['countryEN']?.toString() ?? '';
    final capital =
        j['capitalTR']?.toString() ?? j['capitalEN']?.toString() ?? '';
    final region = j['region']?.toString() ?? '';
    final subregion = j['subregion']?.toString() ?? '';
    final continent = deriveContinent(region, subregion);

    if (iso2.isEmpty || name.isEmpty || capital.isEmpty) {
      debugPrint(
          '[CountryItem] Skipping invalid entry: iso2=$iso2 name=$name capital=$capital');
    }

    return CountryItem(
      iso2: iso2,
      name: name,
      capital: capital,
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
