import 'dart:convert';
import '../models/country.dart';
import 'capital_image_service.dart';
import 'utf8_loader.dart';

class CountryRepository {
  static final CountryRepository _i = CountryRepository._();
  factory CountryRepository() => _i;
  CountryRepository._();

  List<Country>? _cache;
  Map<String, Map<String, dynamic>>? _capitalsData;

  Future<Map<String, Map<String, dynamic>>> _loadCapitalsData() async {
    if (_capitalsData != null) return _capitalsData!;

    try {
      final raw = await loadUtf8Asset('assets/capitals.json');
      final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
      _capitalsData = {
        for (final item in list)
          (item['iso2'] as String? ?? '').toUpperCase(): item
      };
    } catch (e) {
      // If capitals.json doesn't exist or fails to load, use empty map
      _capitalsData = <String, Map<String, dynamic>>{};
    }

    return _capitalsData!;
  }

  Future<List<Country>> getAll() async {
    if (_cache != null) return _cache!;

    final raw = await loadUtf8Asset('data/countries.json');
    final list = (json.decode(raw) as List).cast<Map<String, dynamic>>();
    final capitalsData = await _loadCapitalsData();
    final imageService = CapitalImageService();

    _cache = await Future.wait(list.map((countryJson) async {
      final iso2 = (countryJson['iso2'] as String? ?? '').toUpperCase();
      final capitalSlug = countryJson['slugCapital'] as String? ?? '';
      final capitalData = capitalsData[iso2];

      // Check for local capital photo asset
      final capitalAssetPath =
          await imageService.getCapitalPhotoPath(iso2, capitalSlug);

      // Merge capital image data if available
      if (capitalData != null) {
        countryJson = {
          ...countryJson,
          'capitalImageUrl': capitalData['imageUrl'],
          'capitalCredit': capitalData['credit'],
        };
      }

      // Add capital asset path if photo exists locally
      if (capitalAssetPath != null) {
        countryJson = {
          ...countryJson,
          'capitalAssetPath': capitalAssetPath,
        };
      }

      return Country.fromJson(countryJson);
    }));

    return _cache!;
  }

  Future<int> count() async => (await getAll()).length;

  Future<Country?> findByIso2(String iso2) async {
    final up = iso2.toUpperCase();
    final countries = await getAll();
    for (final country in countries) {
      if (country.iso2.toUpperCase() == up) {
        return country;
      }
    }
    return null;
  }

  void clearCache() {
    _cache = null;
    _capitalsData = null;
  }
}
