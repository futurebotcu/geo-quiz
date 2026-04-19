import 'dart:math';
import 'package:flutter/foundation.dart';
import 'models.dart';
import '../utils/image_picker.dart';
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
  Map<String, List<String>> _continentMapping = {};

  Future<void> initialize() async {
    _capitalItems = await loadCapitalManifest();
    _flagItems = await loadFlagManifest();
    _foodItems = await loadFoodManifest();
    _countryItems = await loadCountries();
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

  Future<List<QuizQuestion>> generateQuestions(
    QuizSettings settings,
  ) async {
    if (kDebugMode) debugPrint('[QG] mode=${settings.mode.wireName} count=${settings.questionCount} diff=${settings.difficulty}');

    if (_capitalItems == null ||
        _flagItems == null ||
        _foodItems == null ||
        _countryItems == null) {
      await initialize();
    }

    if (settings.mode == QuizMode.mixed) {
      return _generateMixedQuestions(settings.questionCount,
          settings.difficulty, settings.continentFilter);
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
          item, settings.mode, settings.difficulty);
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
      int count, DifficultyLevel difficulty, String? continentFilter) async {
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
          final question =
              await _generateSingleQuestion(item, mode, difficulty);
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
  ) async {
    final iso2 = _getIso2FromItem(item);
    final continent = _getContinent(iso2);

    final questionData = _getQuestionDataForMode(item, mode);
    if (questionData == null) return null;

    final distractors = await _generateDistractors(
      questionData.correctAnswer,
      continent,
      mode,
      difficulty,
    );

    if (distractors.length < 3) return null;

    final options = [questionData.correctAnswer, ...distractors.take(3)];
    options.shuffle(_random);

    // Add metadata for specific question types
    final Map<String, dynamic> metadata = {};
    if (mode == QuizMode.foodCountry && item is FoodItem) {
      metadata['dishName'] = item.dish;
    }
    if (mode == QuizMode.capitalCountry && item is CountryItem) {
      metadata['capital'] = item.capital;
    }

    return QuizQuestion(
      mode: mode,
      questionText: questionData.questionText,
      correctAnswer: questionData.correctAnswer,
      options: options,
      iso2: iso2,
      continent: continent,
      imagePath: questionData.imagePath,
      emoji: questionData.emoji,
      metadata: metadata,
    );
  }

  _QuestionData? _getQuestionDataForMode(dynamic item, QuizMode mode) {
    switch (mode) {
      case QuizMode.foodCountry:
        final foodItem = item as FoodItem;
        return _QuestionData(
          questionText: 'Bu yemek hangi ülkeye ait?',
          correctAnswer: foodItem.country,
          imagePath: getFoodImageSource(foodItem),
        );

      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        final capitalItem = item as CapitalItem;
        return _QuestionData(
          questionText: 'Fotoğrafta hangi başkent var?',
          correctAnswer: capitalItem.capital,
          imagePath: getCapitalImageSource(capitalItem),
        );

      case QuizMode.flagCountry:
        final flagItem = item as FlagItem;
        final countryName = _getCountryName(flagItem.iso2);
        if (countryName == 'Unknown' || countryName.isEmpty) {
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
        if (countryItem.capital.isEmpty || countryItem.name.isEmpty) {
          if (kDebugMode) debugPrint('[QG] capitalCountry: Invalid data for ${countryItem.iso2}');
          return null;
        }
        return _QuestionData(
          questionText:
              '${countryItem.capital} şehri hangi ülkenin başkentidir?',
          correctAnswer: countryItem.name,
        );

      case QuizMode.mixed:
        return null; // Should not reach here
    }
  }

  String _getCountryName(String iso2) {
    final countryItem = _countryItems!.firstWhere(
      (country) => country.iso2.toLowerCase() == iso2.toLowerCase(),
      orElse: () =>
          CountryItem(iso2: iso2, name: 'Unknown', capital: '', continent: ''),
    );
    return countryItem.name;
  }

  Future<List<String>> _generateDistractors(
    String correctAnswer,
    String continent,
    QuizMode mode,
    DifficultyLevel difficulty,
  ) async {
    // Doğru cevabın ülke bilgisini bul
    final correctIso2 = _findIso2ForAnswer(correctAnswer, mode);
    if (correctIso2.isEmpty || _countryItems == null) {
      // Fallback: eski basit mantık
      return _generateSimpleDistractors(correctAnswer, mode);
    }

    final correctCountry = _countryItems!.firstWhere(
      (c) => c.iso2.toLowerCase() == correctIso2.toLowerCase(),
      orElse: () => CountryItem(
          iso2: correctIso2,
          name: correctAnswer,
          capital: '',
          continent: continent),
    );

    // Yeni akıllı distractor seçimi
    final chosenCountries = _pickDistractors(
      pool: _countryItems!,
      answer: correctCountry,
      difficulty: difficulty,
      rng: _random,
      need: 3,
    );

    // Ülkeleri cevap formatına çevir
    final distractors = <String>[];
    for (final country in chosenCountries) {
      final answer = _convertCountryToAnswer(country, mode);
      if (answer.isNotEmpty && answer != correctAnswer) {
        distractors.add(answer);
      }
    }

    // Yeterli distractor yoksa fallback
    if (distractors.length < 3) {
      final fallback = await _generateSimpleDistractors(correctAnswer, mode);
      distractors.addAll(fallback.take(3 - distractors.length));
    }

    return distractors.take(3).toList();
  }

  // Ülkeyi mod formatına çevir (eski mantığın tersini yap)
  String _convertCountryToAnswer(CountryItem country, QuizMode mode) {
    switch (mode) {
      case QuizMode.foodCountry:
      case QuizMode.flagCountry:
      case QuizMode.capitalCountry:
        return country.name;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return country.capital;
      case QuizMode.mixed:
        return country.name; // Mixed'de genelde ülke adı
    }
  }

  // Basit fallback distractor üretimi
  Future<List<String>> _generateSimpleDistractors(
      String correctAnswer, QuizMode mode) async {
    List<String> possibleAnswers = [];

    switch (mode) {
      case QuizMode.foodCountry:
        possibleAnswers =
            _foodItems!.map((item) => item.country).toSet().toList();
        break;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        possibleAnswers = _capitalItems!
            .where((item) => item.capital.isNotEmpty)
            .map((item) => item.capital)
            .toList();
        break;
      case QuizMode.flagCountry:
      case QuizMode.capitalCountry:
        possibleAnswers = _countryItems!.map((item) => item.name).toList();
        break;
      case QuizMode.mixed:
        possibleAnswers = _countryItems!.map((item) => item.name).toList();
        break;
    }

    possibleAnswers
        .removeWhere((answer) => answer == correctAnswer || answer.isEmpty);
    possibleAnswers.shuffle(_random);

    return possibleAnswers.take(3).toList();
  }

  String _findIso2ForAnswer(String answer, QuizMode mode) {
    switch (mode) {
      case QuizMode.foodCountry:
        final foodItem = _foodItems!.firstWhere(
          (item) => item.country == answer,
          orElse: () => FoodItem(iso2: '', country: '', dish: '', path: ''),
        );
        return foodItem.iso2;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        final capitalItem = _capitalItems!.firstWhere(
          (item) => item.capital == answer,
          orElse: () => CapitalItem(
              iso2: '',
              country: '',
              capital: '',
              path: '',
              filename: '',
              width: 0,
              height: 0),
        );
        return capitalItem.iso2;
      case QuizMode.flagCountry:
      case QuizMode.capitalCountry:
        final countryItem = _countryItems!.firstWhere(
          (item) => item.name == answer,
          orElse: () =>
              CountryItem(iso2: '', name: '', capital: '', continent: ''),
        );
        return countryItem.iso2;
      case QuizMode.mixed:
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
