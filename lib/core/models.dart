// lib/core/models.dart

// =============== MODLAR ===============
enum QuizMode {
  foodCountry, // 1) Yemek foto → Ülke
  capitalPhoto, // 2) Şehir foto → Başkent
  flagCountry, // 3) Bayrak → Ülke
  capitalCountry, // 4) "Bu şehir hangi ülkenin başkentidir?"
  mixed, // 5) Karma
  capitalFromImage, // Eski isim (projede vardı) — capitalPhoto ile aynı anlam
}

// Mod yardımcıları (isim eşitleme + açıklama metinleri)
extension QuizModeWire on QuizMode {
  /// Kaydetme/okuma için tek tip (normalize) isim.
  /// `capitalFromImage` → "capitalPhoto" olarak yazılır.
  String get wireName {
    switch (this) {
      case QuizMode.foodCountry:
        return 'foodCountry';
      case QuizMode.capitalPhoto:
        return 'capitalPhoto';
      case QuizMode.flagCountry:
        return 'flagCountry';
      case QuizMode.capitalCountry:
        return 'capitalCountry';
      case QuizMode.mixed:
        return 'mixed';
      case QuizMode.capitalFromImage:
        return 'capitalPhoto'; // eski ad tek tipe döner
    }
  }

  /// capitalPhoto ile capitalFromImage aynı kategori
  bool get isCapitalPhoto =>
      this == QuizMode.capitalPhoto || this == QuizMode.capitalFromImage;

  /// Metinden (eski/yeni) bir QuizMode üretir.
  static QuizMode fromWire(String? s) {
    final v = (s ?? '').trim();
    switch (v) {
      case 'food':
      case 'foodCountry':
        return QuizMode.foodCountry;

      case 'capital':
      case 'capitalPhoto':
      case 'capital_from_image':
      case 'capitalFromImage':
        return QuizMode.capitalPhoto; // normalize ederek dön

      case 'flag':
      case 'flagCountry':
        return QuizMode.flagCountry;

      case 'capitalCountry':
      case 'capitalToCountry': // eski olasılık
      case 'cityToCountry': // olası varyasyon
        return QuizMode.capitalCountry;

      case 'mixed':
        return QuizMode.mixed;

      default:
        return QuizMode.foodCountry;
    }
  }
}

// =============== ZORLUK ===============
enum DifficultyLevel { easy, medium, hard }

// =============== AYARLAR ===============
class QuizSettings {
  final QuizMode mode;
  final bool timerEnabled;
  final int questionCount;
  final DifficultyLevel difficulty;
  final String? continentFilter;

  const QuizSettings({
    required this.mode,
    this.timerEnabled = false,
    this.questionCount = 10,
    this.difficulty = DifficultyLevel.medium,
    this.continentFilter,
  });

  // Sentinel used to distinguish "not provided" from "explicitly null"
  // for nullable fields (continentFilter: null means "no filter").
  static const Object _kUnset = Object();

  QuizSettings copyWith({
    QuizMode? mode,
    bool? timerEnabled,
    int? questionCount,
    DifficultyLevel? difficulty,
    Object? continentFilter = _kUnset,
  }) {
    final String? resolvedContinent = identical(continentFilter, _kUnset)
        ? this.continentFilter
        : continentFilter as String?;
    return QuizSettings(
      mode: mode ?? this.mode,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      continentFilter: resolvedContinent,
    );
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.wireName, // normalize isimle yaz
        'timerEnabled': timerEnabled,
        'questionCount': questionCount,
        'difficulty': difficulty.name,
        'continentFilter': continentFilter,
      };

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    final mode = QuizModeWire.fromWire(json['mode']);
    return QuizSettings(
      mode: mode,
      timerEnabled: json['timerEnabled'] ?? false,
      questionCount: json['questionCount'] ?? 10,
      difficulty: DifficultyLevel.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => DifficultyLevel.medium,
      ),
      continentFilter: json['continentFilter'],
    );
  }
}

/// What the answer options represent. Drives how the quiz screen maps an
/// option's `iso2` to a localized label at render time.
enum OptionKind { country, capital }

// =============== SORU / CEVAP / SONUÇ ===============
class QuizQuestion {
  final QuizMode mode; // Mode for determining localized question text
  final String questionText; // Fallback text (not used if mode is set)
  final String correctAnswer;
  final List<String> options;
  // Parallel ISO-2 codes for each entry in [options]. Used for mid-quiz
  // locale changes: the UI re-renders option text via a locale-aware
  // lookup, and answer correctness is checked against [iso2] directly.
  final List<String> optionIso2s;
  final OptionKind optionKind;
  final String? imagePath;
  final String? emoji;
  final String iso2;
  final String? continent; // bazı modlarda boş olabilir
  final Map<String, dynamic> metadata; // Ek bilgiler (dishName, etc.)

  const QuizQuestion({
    required this.mode,
    required this.questionText,
    required this.correctAnswer,
    required this.options,
    required this.optionIso2s,
    required this.optionKind,
    required this.iso2,
    this.continent,
    this.imagePath,
    this.emoji,
    this.metadata = const {}, // Varsayılan boş map
  });

  /// Prefer [correctOptionIndex] — it's iso2-based and survives runtime
  /// re-localization of option text. Kept for backward compatibility.
  int get correctIndex => options.indexOf(correctAnswer);

  /// Index of the correct option computed via iso2 equality. Safe to use
  /// after option labels have been re-resolved to a new locale.
  int get correctOptionIndex {
    final idx = optionIso2s.indexWhere(
        (i) => i.toLowerCase() == iso2.toLowerCase());
    return idx >= 0 ? idx : correctIndex;
  }
}

class QuizAnswer {
  final int questionIndex;
  final int selectedIndex;
  final bool isCorrect;
  final DateTime timestamp;

  const QuizAnswer({
    required this.questionIndex,
    required this.selectedIndex,
    required this.isCorrect,
    required this.timestamp,
  });
}

class QuizResult {
  final List<QuizAnswer> answers;
  final int score;
  final int totalQuestions;
  final Duration totalTime;
  final QuizMode mode;
  final DateTime completedAt;

  const QuizResult({
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.totalTime,
    required this.mode,
    required this.completedAt,
  });

  double get percentage => (score / totalQuestions) * 100;

  Map<String, dynamic> toJson() => {
        'score': score,
        'totalQuestions': totalQuestions,
        'totalTimeMs': totalTime.inMilliseconds,
        'mode': mode.wireName, // normalize isimle yaz
        'completedAt': completedAt.toIso8601String(),
        'percentage': percentage,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      answers: const [], // detay istenirse ayrı saklanır
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      totalTime: Duration(milliseconds: json['totalTimeMs']),
      mode: QuizModeWire.fromWire(json['mode']),
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}

// =============== İSTATİSTİK ===============
/// Kullanıcı istatistikleri.
///
/// `bestScores` ve `averageScores` artık **yüzde** cinsindendir (0-100):
/// - `bestScores[mode]` — o modda alınmış en yüksek yüzde (int, 0-100).
/// - `averageScores[mode]` — o modun tüm zamanlar ortalaması (double, 0-100).
/// - `gamesPerMode[mode]` — o modda oynanmış oyun sayısı (true lifetime count).
class UserStats {
  final int totalGamesPlayed;
  final Map<QuizMode, int> bestScores; // yüzde 0-100
  final Map<QuizMode, double> averageScores; // yüzde 0-100
  final Map<QuizMode, int> gamesPerMode;
  final List<QuizResult> recentResults;

  const UserStats({
    this.totalGamesPlayed = 0,
    this.bestScores = const {},
    this.averageScores = const {},
    this.gamesPerMode = const {},
    this.recentResults = const [],
  });

  UserStats copyWith({
    int? totalGamesPlayed,
    Map<QuizMode, int>? bestScores,
    Map<QuizMode, double>? averageScores,
    Map<QuizMode, int>? gamesPerMode,
    List<QuizResult>? recentResults,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      bestScores: bestScores ?? this.bestScores,
      averageScores: averageScores ?? this.averageScores,
      gamesPerMode: gamesPerMode ?? this.gamesPerMode,
      recentResults: recentResults ?? this.recentResults,
    );
  }

  int getBestScore(QuizMode mode) => bestScores[mode] ?? 0;
  double getAverageScore(QuizMode mode) => averageScores[mode] ?? 0.0;
  int getGamesPlayed(QuizMode mode) => gamesPerMode[mode] ?? 0;

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'bestScores': bestScores.map((k, v) => MapEntry(k.wireName, v)),
        'averageScores': averageScores.map((k, v) => MapEntry(k.wireName, v)),
        'gamesPerMode': gamesPerMode.map((k, v) => MapEntry(k.wireName, v)),
        'recentResults': recentResults.map((r) => r.toJson()).toList(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final recentResults = (json['recentResults'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(QuizResult.fromJson)
        .toList();

    // Yeni şema: gamesPerMode varsa, alanları olduğu gibi yükle.
    if (json['gamesPerMode'] is Map) {
      final bestScores = <QuizMode, int>{};
      final averageScores = <QuizMode, double>{};
      final gamesPerMode = <QuizMode, int>{};

      if (json['bestScores'] is Map) {
        (json['bestScores'] as Map).forEach((key, value) {
          bestScores[QuizModeWire.fromWire(key as String?)] =
              (value ?? 0) as int;
        });
      }
      if (json['averageScores'] is Map) {
        (json['averageScores'] as Map).forEach((key, value) {
          averageScores[QuizModeWire.fromWire(key as String?)] =
              (value ?? 0).toDouble();
        });
      }
      (json['gamesPerMode'] as Map).forEach((key, value) {
        gamesPerMode[QuizModeWire.fromWire(key as String?)] =
            (value ?? 0) as int;
      });

      return UserStats(
        totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
        bestScores: bestScores,
        averageScores: averageScores,
        gamesPerMode: gamesPerMode,
        recentResults: recentResults,
      );
    }

    // Eski şema migration: bestScores/averageScores mutlak skor anlamındaydı
    // veya çok eski `bestScoreCapital` düzeyindeydi. recentResults üzerinden
    // yeniden hesaplayarak yüzde semantiğine dönüştür.
    final bestScores = <QuizMode, int>{};
    final averageScores = <QuizMode, double>{};
    final gamesPerMode = <QuizMode, int>{};

    for (final r in recentResults) {
      final pct = r.percentage.round();
      final curBest = bestScores[r.mode] ?? 0;
      if (pct > curBest) bestScores[r.mode] = pct;
      gamesPerMode[r.mode] = (gamesPerMode[r.mode] ?? 0) + 1;
    }
    for (final mode in gamesPerMode.keys) {
      final modeResults = recentResults.where((r) => r.mode == mode);
      if (modeResults.isNotEmpty) {
        averageScores[mode] =
            modeResults.map((r) => r.percentage).reduce((a, b) => a + b) /
                modeResults.length;
      }
    }

    return UserStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      bestScores: bestScores,
      averageScores: averageScores,
      gamesPerMode: gamesPerMode,
      recentResults: recentResults,
    );
  }
}

