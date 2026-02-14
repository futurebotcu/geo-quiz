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

  /// Menüde/metinde kısa açıklama
  String get subtitle {
    switch (this) {
      case QuizMode.foodCountry:
        return 'Fotoğraftaki yemeğin hangi ülkeye ait olduğunu bul';
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return 'Başkent şehir fotoğraflarından tahmin et';
      case QuizMode.flagCountry:
        return 'Bayraklardan ülkeleri tanı';
      case QuizMode.capitalCountry:
        return '"Bu şehir hangi ülkenin başkentidir?"';
      case QuizMode.mixed:
        return 'Tüm modlar karışık';
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

  QuizSettings copyWith({
    QuizMode? mode,
    bool? timerEnabled,
    int? questionCount,
    DifficultyLevel? difficulty,
    String? continentFilter,
  }) {
    return QuizSettings(
      mode: mode ?? this.mode,
      timerEnabled: timerEnabled ?? this.timerEnabled,
      questionCount: questionCount ?? this.questionCount,
      difficulty: difficulty ?? this.difficulty,
      continentFilter: continentFilter ?? this.continentFilter,
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

// =============== SORU / CEVAP / SONUÇ ===============
class QuizQuestion {
  final QuizMode mode; // Mode for determining localized question text
  final String questionText; // Fallback text (not used if mode is set)
  final String correctAnswer;
  final List<String> options;
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
    required this.iso2,
    this.continent,
    this.imagePath,
    this.emoji,
    this.metadata = const {}, // Varsayılan boş map
  });

  int get correctIndex => options.indexOf(correctAnswer);
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
class UserStats {
  final int totalGamesPlayed;
  final Map<QuizMode, int> bestScores;
  final Map<QuizMode, double> averageScores;
  final List<QuizResult> recentResults;

  const UserStats({
    this.totalGamesPlayed = 0,
    this.bestScores = const {},
    this.averageScores = const {},
    this.recentResults = const [],
  });

  UserStats copyWith({
    int? totalGamesPlayed,
    Map<QuizMode, int>? bestScores,
    Map<QuizMode, double>? averageScores,
    List<QuizResult>? recentResults,
  }) {
    return UserStats(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      bestScores: bestScores ?? this.bestScores,
      averageScores: averageScores ?? this.averageScores,
      recentResults: recentResults ?? this.recentResults,
    );
  }

  int getBestScore(QuizMode mode) => bestScores[mode] ?? 0;
  double getAverageScore(QuizMode mode) => averageScores[mode] ?? 0.0;

  Map<String, dynamic> toJson() => {
        'totalGamesPlayed': totalGamesPlayed,
        'bestScores': bestScores.map((k, v) => MapEntry(k.wireName, v)),
        'averageScores': averageScores.map((k, v) => MapEntry(k.wireName, v)),
        'recentResults': recentResults.map((r) => r.toJson()).toList(),
      };

  factory UserStats.fromJson(Map<String, dynamic> json) {
    final bestScores = <QuizMode, int>{};
    final averageScores = <QuizMode, double>{};

    // Eski alan adları (geriye dönük)
    if (json.containsKey('bestScoreCapital')) {
      bestScores[QuizMode.capitalPhoto] = json['bestScoreCapital'] ?? 0;
      averageScores[QuizMode.capitalPhoto] =
          (json['averageScoreCapital']?.toDouble() ?? 0.0);
    }
    if (json.containsKey('bestScoreFlag')) {
      bestScores[QuizMode.flagCountry] = json['bestScoreFlag'] ?? 0;
      averageScores[QuizMode.flagCountry] =
          (json['averageScoreFlag']?.toDouble() ?? 0.0);
    }

    // Yeni format
    if (json['bestScores'] is Map) {
      (json['bestScores'] as Map).forEach((key, value) {
        final m = QuizModeWire.fromWire(key as String?);
        bestScores[m] = (value ?? 0) as int;
      });
    }
    if (json['averageScores'] is Map) {
      (json['averageScores'] as Map).forEach((key, value) {
        final m = QuizModeWire.fromWire(key as String?);
        averageScores[m] = (value ?? 0).toDouble();
      });
    }

    return UserStats(
      totalGamesPlayed: json['totalGamesPlayed'] ?? 0,
      bestScores: bestScores,
      averageScores: averageScores,
      recentResults: (json['recentResults'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(QuizResult.fromJson)
          .toList(),
    );
  }
}

// UI'da görünen kısa adlar (Türkçe)
extension QuizModeUi on QuizMode {
  String get displayName {
    switch (this) {
      case QuizMode.foodCountry:
        return 'Yemek → Ülke';
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        return 'Foto → Başkent';
      case QuizMode.flagCountry:
        return 'Bayrak → Ülke';
      case QuizMode.capitalCountry:
        return 'Şehir → Ülke';
      case QuizMode.mixed:
        return 'Karma';
    }
  }
}
