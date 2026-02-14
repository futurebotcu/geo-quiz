import 'dart:convert';
import 'package:flutter/widgets.dart';
import '../services/utf8_loader.dart';
import 'emoji.dart' as emoji_utils;

// Capital Mode - For city photos only
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

// Flag Mode - For flags with PNG/emoji fallback
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

// Food Mode - For food photos
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

// Country Data for general quiz questions
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
    final continent = j['region']?.toString() ?? '';

    // Skip invalid entries
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

// Data Loading Functions
Future<List<CapitalItem>> loadCapitalManifest() async {
  try {
    final txt = await loadUtf8Asset('data/assets_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => CapitalItem.fromJson(e)).toList();
  } catch (e) {
    print('[ASSET] Error loading capitals manifest: $e');
    return [];
  }
}

Future<List<FlagItem>> loadFlagManifest() async {
  try {
    final txt = await loadUtf8Asset('data/flags_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => FlagItem.fromJson(e)).toList();
  } catch (e) {
    print('[ASSET] Error loading flags manifest: $e');
    return [];
  }
}

Future<List<FoodItem>> loadFoodManifest() async {
  try {
    final txt = await loadUtf8Asset('data/foods_manifest.json');
    final List data = json.decode(txt);
    return data.map((e) => FoodItem.fromJson(e)).toList();
  } catch (e) {
    print('[ASSET] Error loading foods manifest: $e');
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
        // Only add valid countries with all required fields
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

// Capital Mode: webp â†’ photo â†’ placeholder (NO flags)
ImageProvider pickCapitalImage(CapitalItem it) {
  // 1) WebP varsa onu kullan (en optimize)
  if (it.webpPath != null && it.webpPath!.isNotEmpty) {
    return AssetImage(it.webpPath!);
  }

  // 2) Fotoğraf varsa onu kullan
  if (it.path.isNotEmpty) {
    return AssetImage(it.path);
  }

  // 3) Son çare: generic placeholder
  return const AssetImage('assets/placeholders/generic.png');
}

String getCapitalImageSource(CapitalItem it) {
  if (it.webpPath != null && it.webpPath!.isNotEmpty) {
    return it.webpPath!;
  }

  if (it.path.isNotEmpty) {
    return it.path;
  }

  return 'assets/placeholders/generic.png';
}

// Food Mode Image Functions
ImageProvider pickFoodImage(FoodItem item) {
  if (item.path.isNotEmpty) {
    return AssetImage(item.path);
  }
  return const AssetImage('assets/placeholders/food_placeholder.png');
}

String getFoodImageSource(FoodItem item) {
  if (item.path.isNotEmpty) {
    return item.path;
  }
  return 'assets/placeholders/food_placeholder.png';
}

// Flag emoji mapping
const Map<String, String> flagEmojis = {
  'ad': 'ğŸ‡¦ğŸ‡©',
  'ae': 'ğŸ‡¦ğŸ‡ª',
  'af': 'ğŸ‡¦ğŸ‡«',
  'ag': 'ğŸ‡¦ğŸ‡¬',
  'ai': 'ğŸ‡¦ğŸ‡®',
  'al': 'ğŸ‡¦ğŸ‡±',
  'am': 'ğŸ‡¦ğŸ‡²',
  'ao': 'ğŸ‡¦ğŸ‡´',
  'aq': 'ğŸ‡¦ğŸ‡¶',
  'ar': 'ğŸ‡¦ğŸ‡·',
  'as': 'ğŸ‡¦ğŸ‡¸',
  'at': 'ğŸ‡¦ğŸ‡¹',
  'au': 'ğŸ‡¦ğŸ‡º',
  'aw': 'ğŸ‡¦ğŸ‡¼',
  'ax': 'ğŸ‡¦ğŸ‡½',
  'az': 'ğŸ‡¦ğŸ‡¿',
  'ba': 'ğŸ‡§ğŸ‡¦',
  'bb': 'ğŸ‡§ğŸ‡§',
  'bd': 'ğŸ‡§ğŸ‡©',
  'be': 'ğŸ‡§ğŸ‡ª',
  'bf': 'ğŸ‡§ğŸ‡«',
  'bg': 'ğŸ‡§ğŸ‡¬',
  'bh': 'ğŸ‡§ğŸ‡­',
  'bi': 'ğŸ‡§ğŸ‡®',
  'bj': 'ğŸ‡§ğŸ‡¯',
  'bl': 'ğŸ‡§ğŸ‡±',
  'bm': 'ğŸ‡§ğŸ‡²',
  'bn': 'ğŸ‡§ğŸ‡³',
  'bo': 'ğŸ‡§ğŸ‡´',
  'bq': 'ğŸ‡§ğŸ‡¶',
  'br': 'ğŸ‡§ğŸ‡·',
  'bs': 'ğŸ‡§ğŸ‡¸',
  'bt': 'ğŸ‡§ğŸ‡¹',
  'bv': 'ğŸ‡§ğŸ‡»',
  'bw': 'ğŸ‡§ğŸ‡¼',
  'by': 'ğŸ‡§ğŸ‡¾',
  'bz': 'ğŸ‡§ğŸ‡¿',
  'ca': 'ğŸ‡¨ğŸ‡¦',
  'cc': 'ğŸ‡¨ğŸ‡¨',
  'cd': 'ğŸ‡¨ğŸ‡©',
  'cf': 'ğŸ‡¨ğŸ‡«',
  'cg': 'ğŸ‡¨ğŸ‡¬',
  'ch': 'ğŸ‡¨ğŸ‡­',
  'ci': 'ğŸ‡¨ğŸ‡®',
  'ck': 'ğŸ‡¨ğŸ‡°',
  'cl': 'ğŸ‡¨ğŸ‡±',
  'cm': 'ğŸ‡¨ğŸ‡²',
  'cn': 'ğŸ‡¨ğŸ‡³',
  'co': 'ğŸ‡¨ğŸ‡´',
  'cr': 'ğŸ‡¨ğŸ‡·',
  'cu': 'ğŸ‡¨ğŸ‡º',
  'cv': 'ğŸ‡¨ğŸ‡»',
  'cw': 'ğŸ‡¨ğŸ‡¼',
  'cx': 'ğŸ‡¨ğŸ‡½',
  'cy': 'ğŸ‡¨ğŸ‡¾',
  'cz': 'ğŸ‡¨ğŸ‡¿',
  'de': 'ğŸ‡©ğŸ‡ª',
  'dj': 'ğŸ‡©ğŸ‡¯',
  'dk': 'ğŸ‡©ğŸ‡°',
  'dm': 'ğŸ‡©ğŸ‡²',
  'do': 'ğŸ‡©ğŸ‡´',
  'dz': 'ğŸ‡©ğŸ‡¿',
  'ec': 'ğŸ‡ªğŸ‡¨',
  'ee': 'ğŸ‡ªğŸ‡ª',
  'eg': 'ğŸ‡ªğŸ‡¬',
  'eh': 'ğŸ‡ªğŸ‡­',
  'er': 'ğŸ‡ªğŸ‡·',
  'es': 'ğŸ‡ªğŸ‡¸',
  'et': 'ğŸ‡ªğŸ‡¹',
  'fi': 'ğŸ‡«ğŸ‡®',
  'fj': 'ğŸ‡«ğŸ‡¯',
  'fk': 'ğŸ‡«ğŸ‡°',
  'fm': 'ğŸ‡«ğŸ‡²',
  'fo': 'ğŸ‡«ğŸ‡´',
  'fr': 'ğŸ‡«ğŸ‡·',
  'ga': 'ğŸ‡¬ğŸ‡¦',
  'gb': 'ğŸ‡¬ğŸ‡§',
  'gd': 'ğŸ‡¬ğŸ‡©',
  'ge': 'ğŸ‡¬ğŸ‡ª',
  'gf': 'ğŸ‡¬ğŸ‡«',
  'gg': 'ğŸ‡¬ğŸ‡¬',
  'gh': 'ğŸ‡¬ğŸ‡­',
  'gi': 'ğŸ‡¬ğŸ‡®',
  'gl': 'ğŸ‡¬ğŸ‡±',
  'gm': 'ğŸ‡¬ğŸ‡²',
  'gn': 'ğŸ‡¬ğŸ‡³',
  'gp': 'ğŸ‡¬ğŸ‡µ',
  'gq': 'ğŸ‡¬ğŸ‡¶',
  'gr': 'ğŸ‡¬ğŸ‡·',
  'gs': 'ğŸ‡¬ğŸ‡¸',
  'gt': 'ğŸ‡¬ğŸ‡¹',
  'gu': 'ğŸ‡¬ğŸ‡º',
  'gw': 'ğŸ‡¬ğŸ‡¼',
  'gy': 'ğŸ‡¬ğŸ‡¾',
  'hk': 'ğŸ‡­ğŸ‡°',
  'hm': 'ğŸ‡­ğŸ‡²',
  'hn': 'ğŸ‡­ğŸ‡³',
  'hr': 'ğŸ‡­ğŸ‡·',
  'ht': 'ğŸ‡­ğŸ‡¹',
  'hu': 'ğŸ‡­ğŸ‡º',
  'id': 'ğŸ‡®ğŸ‡©',
  'ie': 'ğŸ‡®ğŸ‡ª',
  'il': 'ğŸ‡®ğŸ‡±',
  'im': 'ğŸ‡®ğŸ‡²',
  'in': 'ğŸ‡®ğŸ‡³',
  'io': 'ğŸ‡®ğŸ‡´',
  'iq': 'ğŸ‡®ğŸ‡¶',
  'ir': 'ğŸ‡®ğŸ‡·',
  'is': 'ğŸ‡®ğŸ‡¸',
  'it': 'ğŸ‡®ğŸ‡¹',
  'je': 'ğŸ‡¯ğŸ‡ª',
  'jm': 'ğŸ‡¯ğŸ‡²',
  'jo': 'ğŸ‡¯ğŸ‡´',
  'jp': 'ğŸ‡¯ğŸ‡µ',
  'ke': 'ğŸ‡°ğŸ‡ª',
  'kg': 'ğŸ‡°ğŸ‡¬',
  'kh': 'ğŸ‡°ğŸ‡­',
  'ki': 'ğŸ‡°ğŸ‡®',
  'km': 'ğŸ‡°ğŸ‡²',
  'kn': 'ğŸ‡°ğŸ‡³',
  'kp': 'ğŸ‡°ğŸ‡µ',
  'kr': 'ğŸ‡°ğŸ‡·',
  'kw': 'ğŸ‡°ğŸ‡¼',
  'ky': 'ğŸ‡°ğŸ‡¾',
  'kz': 'ğŸ‡°ğŸ‡¿',
  'la': 'ğŸ‡±ğŸ‡¦',
  'lb': 'ğŸ‡±ğŸ‡§',
  'lc': 'ğŸ‡±ğŸ‡¨',
  'li': 'ğŸ‡±ğŸ‡®',
  'lk': 'ğŸ‡±ğŸ‡°',
  'lr': 'ğŸ‡±ğŸ‡·',
  'ls': 'ğŸ‡±ğŸ‡¸',
  'lt': 'ğŸ‡±ğŸ‡¹',
  'lu': 'ğŸ‡±ğŸ‡º',
  'lv': 'ğŸ‡±ğŸ‡»',
  'ly': 'ğŸ‡±ğŸ‡¾',
  'ma': 'ğŸ‡²ğŸ‡¦',
  'mc': 'ğŸ‡²ğŸ‡¨',
  'md': 'ğŸ‡²ğŸ‡©',
  'me': 'ğŸ‡²ğŸ‡ª',
  'mf': 'ğŸ‡²ğŸ‡«',
  'mg': 'ğŸ‡²ğŸ‡¬',
  'mh': 'ğŸ‡²ğŸ‡­',
  'mk': 'ğŸ‡²ğŸ‡°',
  'ml': 'ğŸ‡²ğŸ‡±',
  'mm': 'ğŸ‡²ğŸ‡²',
  'mn': 'ğŸ‡²ğŸ‡³',
  'mo': 'ğŸ‡²ğŸ‡´',
  'mp': 'ğŸ‡²ğŸ‡µ',
  'mq': 'ğŸ‡²ğŸ‡¶',
  'mr': 'ğŸ‡²ğŸ‡·',
  'ms': 'ğŸ‡²ğŸ‡¸',
  'mt': 'ğŸ‡²ğŸ‡¹',
  'mu': 'ğŸ‡²ğŸ‡º',
  'mv': 'ğŸ‡²ğŸ‡»',
  'mw': 'ğŸ‡²ğŸ‡¼',
  'mx': 'ğŸ‡²ğŸ‡½',
  'my': 'ğŸ‡²ğŸ‡¾',
  'mz': 'ğŸ‡²ğŸ‡¿',
  'na': 'ğŸ‡³ğŸ‡¦',
  'nc': 'ğŸ‡³ğŸ‡¨',
  'ne': 'ğŸ‡³ğŸ‡ª',
  'nf': 'ğŸ‡³ğŸ‡«',
  'ng': 'ğŸ‡³ğŸ‡¬',
  'ni': 'ğŸ‡³ğŸ‡®',
  'nl': 'ğŸ‡³ğŸ‡±',
  'no': 'ğŸ‡³ğŸ‡´',
  'np': 'ğŸ‡³ğŸ‡µ',
  'nr': 'ğŸ‡³ğŸ‡·',
  'nu': 'ğŸ‡³ğŸ‡º',
  'nz': 'ğŸ‡³ğŸ‡¿',
  'om': 'ğŸ‡´ğŸ‡²',
  'pa': 'ğŸ‡µğŸ‡¦',
  'pe': 'ğŸ‡µğŸ‡ª',
  'pf': 'ğŸ‡µğŸ‡«',
  'pg': 'ğŸ‡µğŸ‡¬',
  'ph': 'ğŸ‡µğŸ‡­',
  'pk': 'ğŸ‡µğŸ‡°',
  'pl': 'ğŸ‡µğŸ‡±',
  'pm': 'ğŸ‡µğŸ‡²',
  'pn': 'ğŸ‡µğŸ‡³',
  'pr': 'ğŸ‡µğŸ‡·',
  'ps': 'ğŸ‡µğŸ‡¸',
  'pt': 'ğŸ‡µğŸ‡¹',
  'pw': 'ğŸ‡µğŸ‡¼',
  'py': 'ğŸ‡µğŸ‡¾',
  'qa': 'ğŸ‡¶ğŸ‡¦',
  're': 'ğŸ‡·ğŸ‡ª',
  'ro': 'ğŸ‡·ğŸ‡´',
  'rs': 'ğŸ‡·ğŸ‡¸',
  'ru': 'ğŸ‡·ğŸ‡º',
  'rw': 'ğŸ‡·ğŸ‡¼',
  'sa': 'ğŸ‡¸ğŸ‡¦',
  'sb': 'ğŸ‡¸ğŸ‡§',
  'sc': 'ğŸ‡¸ğŸ‡¨',
  'sd': 'ğŸ‡¸ğŸ‡©',
  'se': 'ğŸ‡¸ğŸ‡ª',
  'sg': 'ğŸ‡¸ğŸ‡¬',
  'sh': 'ğŸ‡¸ğŸ‡­',
  'si': 'ğŸ‡¸ğŸ‡®',
  'sj': 'ğŸ‡¸ğŸ‡¯',
  'sk': 'ğŸ‡¸ğŸ‡°',
  'sl': 'ğŸ‡¸ğŸ‡±',
  'sm': 'ğŸ‡¸ğŸ‡²',
  'sn': 'ğŸ‡¸ğŸ‡³',
  'so': 'ğŸ‡¸ğŸ‡´',
  'sr': 'ğŸ‡¸ğŸ‡·',
  'ss': 'ğŸ‡¸ğŸ‡¸',
  'st': 'ğŸ‡¸ğŸ‡¹',
  'sv': 'ğŸ‡¸ğŸ‡»',
  'sx': 'ğŸ‡¸ğŸ‡½',
  'sy': 'ğŸ‡¸ğŸ‡¾',
  'sz': 'ğŸ‡¸ğŸ‡¿',
  'tc': 'ğŸ‡¹ğŸ‡¨',
  'td': 'ğŸ‡¹ğŸ‡©',
  'tf': 'ğŸ‡¹ğŸ‡«',
  'tg': 'ğŸ‡¹ğŸ‡¬',
  'th': 'ğŸ‡¹ğŸ‡­',
  'tj': 'ğŸ‡¹ğŸ‡¯',
  'tk': 'ğŸ‡¹ğŸ‡°',
  'tl': 'ğŸ‡¹ğŸ‡±',
  'tm': 'ğŸ‡¹ğŸ‡²',
  'tn': 'ğŸ‡¹ğŸ‡³',
  'to': 'ğŸ‡¹ğŸ‡´',
  'tr': 'ğŸ‡¹ğŸ‡·',
  'tt': 'ğŸ‡¹ğŸ‡¹',
  'tv': 'ğŸ‡¹ğŸ‡»',
  'tw': 'ğŸ‡¹ğŸ‡¼',
  'tz': 'ğŸ‡¹ğŸ‡¿',
  'ua': 'ğŸ‡ºğŸ‡¦',
  'ug': 'ğŸ‡ºğŸ‡¬',
  'um': 'ğŸ‡ºğŸ‡²',
  'us': 'ğŸ‡ºğŸ‡¸',
  'uy': 'ğŸ‡ºğŸ‡¾',
  'uz': 'ğŸ‡ºğŸ‡¿',
  'va': 'ğŸ‡»ğŸ‡¦',
  'vc': 'ğŸ‡»ğŸ‡¨',
  've': 'ğŸ‡»ğŸ‡ª',
  'vg': 'ğŸ‡»ğŸ‡¬',
  'vi': 'ğŸ‡»ğŸ‡®',
  'vn': 'ğŸ‡»ğŸ‡³',
  'vu': 'ğŸ‡»ğŸ‡º',
  'wf': 'ğŸ‡¼ğŸ‡«',
  'ws': 'ğŸ‡¼ğŸ‡¸',
  'ye': 'ğŸ‡¾ğŸ‡ª',
  'yt': 'ğŸ‡¾ğŸ‡¹',
  'za': 'ğŸ‡¿ğŸ‡¦',
  'zm': 'ğŸ‡¿ğŸ‡²',
  'zw': 'ğŸ‡¿ğŸ‡¼',
};

String flagEmoji(String iso2) {
  return flagEmojis[iso2.toLowerCase()] ?? 'ğŸ³ï¸';
}

// Flag Mode Widget
Widget buildFlagDisplay(FlagItem flag) {
  if (flag.hasPngFlag) {
    return Image.asset(flag.flagAsset,
        width: 48, height: 36, fit: BoxFit.cover);
  } else {
    return Text(
      emoji_utils.flagEmoji(flag.iso2),
      style: const TextStyle(fontSize: 32),
    );
  }
}

// Utility functions for statistics
class ImageStats {
  static Future<Map<String, int>> getStats() async {
    final capitalItems = await loadCapitalManifest();

    return {
      'total': capitalItems.length,
      'withPhotos': capitalItems.where((item) => item.hasPhoto).length,
      'withWebP': capitalItems.where((item) => item.hasWebP).length,
    };
  }

  static Future<List<CapitalItem>> getMissingPhotos() async {
    final items = await loadCapitalManifest();
    return items.where((item) => !item.hasPhoto).toList();
  }

  static Future<List<CapitalItem>> getItemsWithPhotos() async {
    final items = await loadCapitalManifest();
    return items.where((item) => item.hasPhoto).toList();
  }
}
