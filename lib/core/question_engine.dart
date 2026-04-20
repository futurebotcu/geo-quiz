import 'dart:math';
import 'package:flutter/foundation.dart';
import 'models.dart';
import '../utils/image_picker.dart';
import '../utils/country_localizer.dart';
import '../utils/emoji.dart' as emoji_utils;

// Kıta filtresi yardımcısı
bool _continentOk(String? filter, String? itemContinent) {
  if (filter == null || filter.isEmpty) return true; // Tümü
  if (itemContinent == null) return false;
  return itemContinent.toLowerCase() == filter.toLowerCase();
}

// Zorluk → şık üretim stratejisi
List<CountryItem> _pickDistractors({
  required List<CountryItem> pool,
  required CountryItem answer,
  required DifficultyLevel difficulty,
  required Random rng,
  int need = 3,
}) {
  // Kıta bilgisi yoksa düz seçim
  final sameContinent = pool
      .where((c) => c.continent == answer.continent && c.iso2 != answer.iso2)
      .toList();
  final diffContinent =
      pool.where((c) => c.continent != answer.continent).toList();

  List<CountryItem> bag;
  switch (difficulty) {
    case DifficultyLevel.easy:
      // Kolay: mümkünse farklı kıtalardan
      bag = diffContinent.isNotEmpty
          ? diffContinent
          : pool.where((c) => c.iso2 != answer.iso2).toList();
      break;
    case DifficultyLevel.medium:
      // Orta: karışık (hafif ağırlık aynı kıtaya)
      final mixed = <CountryItem>[];
      mixed.addAll(sameContinent.take(need * 2));
      mixed.addAll(diffContinent.take(need * 2));
      bag = mixed.where((c) => c.iso2 != answer.iso2).toList();
      break;
    case DifficultyLevel.hard:
      // Zor: mümkünse aynı kıtadan benzerler
      bag = sameContinent.isNotEmpty
          ? sameContinent
          : pool.where((c) => c.iso2 != answer.iso2).toList();
      break;
  }

  bag.shuffle(rng);
  final chosen = <CountryItem>[];
  for (final c in bag) {
    if (c.iso2 != answer.iso2) {
      chosen.add(c);
      if (chosen.length == need) break;
    }
  }
  // Yedek: yetmezse genel havuzdan doldur
  if (chosen.length < need) {
    final fallback = pool
        .where((c) => c.iso2 != answer.iso2 && !chosen.contains(c))
        .toList()
      ..shuffle(rng);
    for (final c in fallback) {
      chosen.add(c);
      if (chosen.length == need) break;
    }
  }
  return chosen;
}

class _QuestionData {
  final String questionText;
  final String correctAnswer;
  final String? imagePath;
  final String? emoji;

  _QuestionData({
    required this.questionText,
    required this.correctAnswer,
    this.imagePath,
    this.emoji,
  });
}

class QuestionEngine {
  final Random _random = Random();

  String _normAsset(String? p) {
    if (p == null || p.isEmpty) return '';
    var s = p.replaceAll('\\', '/').replaceAll('//', '/');
    s = s.replaceFirst(RegExp(r'^/+'), '');
    s = s.replaceAll(
        RegExp(r'(?:assets/)+'), 'assets/'); // assets/assets/.. önler
    if (!s.startsWith('assets/')) s = 'assets/$s';
    return s;
  }

  List<CapitalItem>? _capitalItems;
  List<FlagItem>? _flagItems;
  List<FoodItem>? _foodItems;
  List<CountryItem>? _countryItems;
  Map<String, CountryItem> _countryByIso = const {};
  Map<String, List<String>> _continentMapping = {};

  Future<void> initialize() async {
    _capitalItems = await loadCapitalManifest();
    _flagItems = await loadFlagManifest();
    _foodItems = await loadFoodManifest();
    _countryItems = await loadCountries();
    _countryByIso = {
      for (final c in _countryItems!) c.iso2.toLowerCase(): c,
    };
    // Publish the country index so UI-layer lookups (mid-quiz locale
    // switches, capitalCountry placeholder, etc.) can resolve labels
    // without depending on this engine instance.
    CountryLocalizer.setCountries(_countryItems!);
    _initializeContinentMapping();
  }

  /// countries.json tek kaynak: her CountryItem.continent değerine göre
  /// iso2 listesi inşa edilir. Bu map hem `_getContinent` hem de
  /// `getCountriesInContinent` için kullanılır.
  void _initializeContinentMapping() {
    final map = <String, List<String>>{};
    for (final c in _countryItems ?? const <CountryItem>[]) {
      final cont = c.continent.isEmpty ? 'Unknown' : c.continent;
      (map[cont] ??= <String>[]).add(c.iso2.toLowerCase());
    }
    _continentMapping = map;
  }

  String _getContinent(String iso2) {
    for (final entry in _continentMapping.entries) {
      if (entry.value.contains(iso2.toLowerCase())) {
        return entry.key;
      }
    }
    return 'Unknown';
  }

  CountryItem? _countryByIso2(String iso2) =>
      _countryByIso[iso2.toLowerCase()];

  Future<List<QuizQuestion>> generateQuestions(
    QuizSettings settings, {
    String languageCode = 'en',
  }) async {
    if (kDebugMode) {
      debugPrint(
          '[QG] mode=${settings.mode.wireName} count=${settings.questionCount} diff=${settings.difficulty} lang=$languageCode');
    }

    if (_capitalItems == null ||
        _flagItems == null ||
        _foodItems == null ||
        _countryItems == null) {
      await initialize();
    }

    if (settings.mode == QuizMode.mixed) {
      return _generateMixedQuestions(
        settings.questionCount,
        settings.difficulty,
        settings.continentFilter,
        languageCode,
      );
    }

    final questions = <QuizQuestion>[];
    final usedCountries = <String>{};

    List<dynamic> availableItems = _getAvailableItemsForMode(settings.mode);

    // Kıta filtrelemesi uygula
    final continentFilter = settings.continentFilter;
    if (continentFilter != null && continentFilter.isNotEmpty) {
      availableItems = availableItems.where((item) {
        final iso2 = _getIso2FromItem(item);
        final continent = _getContinent(iso2);
        return _continentOk(continentFilter, continent);
      }).toList();
      if (kDebugMode) debugPrint('[QG] ${settings.mode.wireName} continent-filtered=$continentFilter pool=${availableItems.length}');
    } else {
      if (kDebugMode) debugPrint('[QG] ${settings.mode.wireName} pool=${availableItems.length}');
    }

    availableItems.shuffle(_random);

    for (int i = 0;
        i < settings.questionCount && i < availableItems.length;
        i++) {
      final item = availableItems[i];
      final iso2 = _getIso2FromItem(item);

      if (usedCountries.contains(iso2)) continue;
      usedCountries.add(iso2);

      final question = await _generateSingleQuestion(
          item, settings.mode, settings.difficulty, languageCode);
      if (question != null) {
        questions.add(question);
        if (kDebugMode) debugPrint('[QG] Q${questions.length}: correct="${question.correctAnswer}" options=${question.options} image=${question.imagePath} iso=${question.iso2}');
      }
    }

    return questions;
  }

  List<dynamic> _getAvailableItemsForMode(QuizMode mode) {
    switch (mode) {
      case QuizMode.foodCountry:
        return _foodItems!;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return _capitalItems!.where((item) => item.hasPhoto).toList();
      case QuizMode.flagCountry:
        return _flagItems!;
      case QuizMode.capitalCountry:
        return _countryItems!;
      case QuizMode.mixed:
        return []; // Handled separately
    }
  }

  String _getIso2FromItem(dynamic item) {
    if (item is CapitalItem) return item.iso2;
    if (item is FlagItem) return item.iso2;
    if (item is FoodItem) return item.iso2;
    if (item is CountryItem) return item.iso2;
    return '';
  }

  Future<List<QuizQuestion>> _generateMixedQuestions(
    int count,
    DifficultyLevel difficulty,
    String? continentFilter,
    String languageCode,
  ) async {
    final questions = <QuizQuestion>[];
    final usedCountries = <String>{};
    final modes = [
      QuizMode.foodCountry,
      QuizMode.capitalPhoto, // (legacy capitalFromImage yerine bu)
      QuizMode.flagCountry,
      QuizMode.capitalCountry,
    ];

    for (int i = 0; i < count; i++) {
      final mode = modes[i % modes.length];
      var availableItems = _getAvailableItemsForMode(mode);

      // Kıta filtrelemesi uygula
      if (continentFilter != null && continentFilter.isNotEmpty) {
        availableItems = availableItems.where((item) {
          final iso2 = _getIso2FromItem(item);
          final continent = _getContinent(iso2);
          return _continentOk(continentFilter, continent);
        }).toList();
      }

      if (availableItems.isEmpty) continue;

      availableItems.shuffle(_random);

      for (final item in availableItems) {
        final iso2 = _getIso2FromItem(item);
        if (!usedCountries.contains(iso2)) {
          usedCountries.add(iso2);
          final question = await _generateSingleQuestion(
              item, mode, difficulty, languageCode);
          if (question != null) {
            questions.add(question);
            break;
          }
        }
      }
    }

    questions.shuffle(_random);
    if (kDebugMode) debugPrint('[QG] mixed generated=${questions.length}');
    return questions;
  }

  Future<QuizQuestion?> _generateSingleQuestion(
    dynamic item,
    QuizMode mode,
    DifficultyLevel difficulty,
    String languageCode,
  ) async {
    final iso2 = _getIso2FromItem(item);
    final continent = _getContinent(iso2);

    final questionData = _getQuestionDataForMode(item, mode, languageCode);
    if (questionData == null) return null;

    final distractorPairs = await _generateDistractorsWithIso(
      questionData.correctAnswer,
      continent,
      mode,
      difficulty,
      languageCode,
      iso2,
    );

    if (distractorPairs.length < 3) return null;

    // Combine correct + distractors, keeping option text and iso2 in sync.
    final pairs = <({String text, String iso2})>[
      (text: questionData.correctAnswer, iso2: iso2),
      ...distractorPairs.take(3),
    ];
    final indices = List<int>.generate(pairs.length, (i) => i)
      ..shuffle(_random);
    final shuffledOptions = [for (final i in indices) pairs[i].text];
    final shuffledIso2s = [for (final i in indices) pairs[i].iso2];

    // Add metadata for specific question types
    final Map<String, dynamic> metadata = {};
    if (mode == QuizMode.foodCountry && item is FoodItem) {
      metadata['dishName'] = item.dish;
    }
    if (mode == QuizMode.capitalCountry && item is CountryItem) {
      // Frozen quiz-start capital — the UI prefers a live lookup via
      // CountryLocalizer for mid-quiz locale switches, but keeps this as
      // a fallback.
      metadata['capital'] = item.capitalFor(languageCode);
    }

    final optionKind = (mode == QuizMode.capitalPhoto ||
            mode == QuizMode.capitalFromImage)
        ? OptionKind.capital
        : OptionKind.country;

    return QuizQuestion(
      mode: mode,
      questionText: questionData.questionText,
      correctAnswer: questionData.correctAnswer,
      options: shuffledOptions,
      optionIso2s: shuffledIso2s,
      optionKind: optionKind,
      iso2: iso2,
      continent: continent,
      imagePath: questionData.imagePath,
      emoji: questionData.emoji,
      metadata: metadata,
    );
  }

  _QuestionData? _getQuestionDataForMode(
    dynamic item,
    QuizMode mode,
    String languageCode,
  ) {
    switch (mode) {
      case QuizMode.foodCountry:
        final foodItem = item as FoodItem;
        // Food manifest's `country` field is raw Turkish. Resolve the country
        // name via iso2 → CountryItem so the answer matches the active
        // locale; fall back to the raw string if lookup fails.
        final country = _countryByIso2(foodItem.iso2);
        final correct = country != null
            ? country.nameFor(languageCode)
            : foodItem.country;
        return _QuestionData(
          questionText: 'Bu yemek hangi ülkeye ait?',
          correctAnswer: correct,
          imagePath: getFoodImageSource(foodItem),
        );

      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        final capitalItem = item as CapitalItem;
        // Capital manifest's `capital` is raw English. Resolve via iso2 so
        // the answer text matches the active locale.
        final country = _countryByIso2(capitalItem.iso2);
        final correct = country != null
            ? country.capitalFor(languageCode)
            : capitalItem.capital;
        return _QuestionData(
          questionText: 'Fotoğrafta hangi başkent var?',
          correctAnswer: correct,
          imagePath: getCapitalImageSource(capitalItem),
        );

      case QuizMode.flagCountry:
        final flagItem = item as FlagItem;
        final country = _countryByIso2(flagItem.iso2);
        final countryName = country?.nameFor(languageCode) ?? '';
        if (countryName.isEmpty) {
          if (kDebugMode) debugPrint('[QG] flagCountry: No country name found for ${flagItem.iso2}');
          return null;
        }
        final pathFromManifest = flagItem.hasPngFlag ? flagItem.flagAsset : '';
        final normalizedPath =
            pathFromManifest.isNotEmpty ? _normAsset(pathFromManifest) : null;
        return _QuestionData(
          questionText: 'Bu bayrak hangi ülkeye aittir?',
          correctAnswer: countryName,
          imagePath: normalizedPath,
          emoji: flagItem.useEmoji
              ? emoji_utils.flagEmoji(flagItem.iso2)
              : null,
        );

      case QuizMode.capitalCountry:
        final countryItem = item as CountryItem;
        final localizedName = countryItem.nameFor(languageCode);
        final localizedCapital = countryItem.capitalFor(languageCode);
        if (localizedName.isEmpty || localizedCapital.isEmpty) {
          if (kDebugMode) debugPrint('[QG] capitalCountry: Invalid data for ${countryItem.iso2}');
          return null;
        }
        // Başkent fotosu varsa iliştir (aynı iso2 capital manifest'inde).
        // Foto yoksa imagePath null kalır ve UI text-only fallback'e düşer.
        String? capitalPhotoPath;
        if (_capitalItems != null) {
          for (final c in _capitalItems!) {
            if (c.iso2.toLowerCase() == countryItem.iso2.toLowerCase() &&
                c.hasPhoto) {
              capitalPhotoPath = getCapitalImageSource(c);
              break;
            }
          }
        }
        return _QuestionData(
          questionText: '$localizedCapital şehri hangi ülkenin başkentidir?',
          correctAnswer: localizedName,
          imagePath: capitalPhotoPath,
        );

      case QuizMode.mixed:
        return null; // Should not reach here
    }
  }

  Future<List<({String text, String iso2})>> _generateDistractorsWithIso(
    String correctAnswer,
    String continent,
    QuizMode mode,
    DifficultyLevel difficulty,
    String languageCode,
    String correctIso2,
  ) async {
    if (_countryItems == null) {
      return _generateSimpleDistractorsWithIso(
          correctAnswer, correctIso2, mode, languageCode);
    }

    final answerIso2 = correctIso2.isNotEmpty
        ? correctIso2
        : _findIso2ForAnswer(correctAnswer, mode, languageCode);
    if (answerIso2.isEmpty) {
      return _generateSimpleDistractorsWithIso(
          correctAnswer, correctIso2, mode, languageCode);
    }

    final correctCountry = _countryByIso2(answerIso2) ??
        CountryItem(
          iso2: answerIso2,
          names: {'en': correctAnswer},
          capitals: const {},
          continent: continent,
        );

    final chosenCountries = _pickDistractors(
      pool: _countryItems!,
      answer: correctCountry,
      difficulty: difficulty,
      rng: _random,
      need: 3,
    );

    final pairs = <({String text, String iso2})>[];
    for (final country in chosenCountries) {
      final answer = _convertCountryToAnswer(country, mode, languageCode);
      if (answer.isNotEmpty &&
          answer != correctAnswer &&
          country.iso2.toLowerCase() != answerIso2.toLowerCase()) {
        pairs.add((text: answer, iso2: country.iso2));
      }
    }

    if (pairs.length < 3) {
      final fallback = await _generateSimpleDistractorsWithIso(
          correctAnswer, correctIso2, mode, languageCode);
      for (final f in fallback) {
        if (pairs.length >= 3) break;
        if (pairs.any((p) =>
            p.iso2.toLowerCase() == f.iso2.toLowerCase())) {
          continue;
        }
        pairs.add(f);
      }
    }

    return pairs.take(3).toList();
  }

  // Ülkeyi mod formatına çevir (locale-aware)
  String _convertCountryToAnswer(
      CountryItem country, QuizMode mode, String languageCode) {
    switch (mode) {
      case QuizMode.foodCountry:
      case QuizMode.flagCountry:
      case QuizMode.capitalCountry:
        return country.nameFor(languageCode);
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return country.capitalFor(languageCode);
      case QuizMode.mixed:
        return country.nameFor(languageCode);
    }
  }

  // Basit fallback distractor üretimi (locale-aware, iso2-paired).
  Future<List<({String text, String iso2})>> _generateSimpleDistractorsWithIso(
      String correctAnswer,
      String correctIso2,
      QuizMode mode,
      String languageCode) async {
    final out = <({String text, String iso2})>[];
    final items = List<CountryItem>.from(_countryItems ?? const [])
      ..shuffle(_random);
    for (final c in items) {
      if (out.length >= 3) break;
      if (c.iso2.toLowerCase() == correctIso2.toLowerCase()) continue;
      final text = _convertCountryToAnswer(c, mode, languageCode);
      if (text.isEmpty || text == correctAnswer) continue;
      if (out.any((p) => p.iso2.toLowerCase() == c.iso2.toLowerCase())) {
        continue;
      }
      out.add((text: text, iso2: c.iso2));
    }
    return out;
  }

  // Localized answer string → iso2. Only used as a safety net when the
  // caller didn't pass an iso2 (shouldn't happen under the new flow, but
  // kept for robustness).
  String _findIso2ForAnswer(
      String answer, QuizMode mode, String languageCode) {
    bool matchesCountry(CountryItem c) {
      return c.nameFor(languageCode) == answer ||
          c.nameEN == answer ||
          c.nameTR == answer;
    }

    bool matchesCapital(CountryItem c) {
      return c.capitalFor(languageCode) == answer ||
          c.capitalEN == answer ||
          c.capitalTR == answer;
    }

    switch (mode) {
      case QuizMode.foodCountry:
      case QuizMode.flagCountry:
      case QuizMode.capitalCountry:
      case QuizMode.mixed:
        for (final c in _countryItems ?? const <CountryItem>[]) {
          if (matchesCountry(c)) return c.iso2;
        }
        return '';
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        for (final c in _countryItems ?? const <CountryItem>[]) {
          if (matchesCapital(c)) return c.iso2;
        }
        return '';
    }
  }

  List<String> getContinents() {
    return _continentMapping.keys.toList();
  }

  List<String> getCountriesInContinent(String continent) {
    return _continentMapping[continent] ?? [];
  }

  Future<Map<String, int>> getAvailableItemsCount() async {
    if (_capitalItems == null ||
        _flagItems == null ||
        _foodItems == null ||
        _countryItems == null) {
      await initialize();
    }

    final capitalCount = _capitalItems!.where((item) => item.hasPhoto).length;
    final flagCount = _flagItems!.length;
    final foodCount = _foodItems!.length;
    final countryCount = _countryItems!.length;

    return {
      'foodCountry': foodCount,
      'capitalPhoto': capitalCount,
      'flagCountry': flagCount,
      'capitalCountry': countryCount,
      'total': _countryItems!.length,
    };
  }
}
