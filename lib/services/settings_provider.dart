import 'package:flutter/foundation.dart';
import '../core/models.dart';
import 'storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  QuizSettings _settings = const QuizSettings(mode: QuizMode.foodCountry);
  UserStats _userStats = const UserStats();
  bool _isLoading = false;

  QuizSettings get settings => _settings;
  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;

  final StorageService _storage = StorageService.instance;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storage.initialize();
      _settings = await _storage.loadSettings();
      _userStats = await _storage.loadUserStats();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSettings(QuizSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();

    try {
      await _storage.saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateQuizMode(QuizMode mode) async {
    final newSettings = _settings.copyWith(mode: mode);
    await updateSettings(newSettings);
  }

  Future<void> updateTimerEnabled(bool enabled) async {
    final newSettings = _settings.copyWith(timerEnabled: enabled);
    await updateSettings(newSettings);
  }

  Future<void> updateQuestionCount(int count) async {
    final newSettings = _settings.copyWith(questionCount: count);
    await updateSettings(newSettings);
  }

  Future<void> updateDifficulty(DifficultyLevel difficulty) async {
    final newSettings = _settings.copyWith(difficulty: difficulty);
    await updateSettings(newSettings);
  }

  Future<void> updateContinentFilter(String? continentFilter) async {
    final newSettings = _settings.copyWith(continentFilter: continentFilter);
    await updateSettings(newSettings);
  }

  // Sentinel allows callers to omit nullable params without clobbering them.
  static const Object _kUnset = Object();

  /// Atomically update multiple quiz configuration fields with a single
  /// disk write and a single notifyListeners. Omitted params remain unchanged.
  /// Pass `continentFilter: null` to explicitly clear the filter.
  Future<void> updateQuizConfig({
    QuizMode? mode,
    DifficultyLevel? difficulty,
    int? questionCount,
    bool? timerEnabled,
    Object? continentFilter = _kUnset,
  }) async {
    final newSettings = _settings.copyWith(
      mode: mode,
      difficulty: difficulty,
      questionCount: questionCount,
      timerEnabled: timerEnabled,
      continentFilter: continentFilter,
    );
    _settings = newSettings;
    notifyListeners();
    try {
      await _storage.saveSettings(newSettings);
    } catch (e) {
      debugPrint('Error saving settings (atomic): $e');
    }
  }

  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _storage.saveQuizResult(result);
      _userStats = await _storage.loadUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }
  }

  Future<List<QuizResult>> getRecentResults() async {
    try {
      return await _storage.loadRecentResults();
    } catch (e) {
      debugPrint('Error loading recent results: $e');
      return [];
    }
  }

  Future<void> refreshStats() async {
    try {
      _userStats = await _storage.loadUserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing stats: $e');
    }
  }

  Future<void> clearAllData() async {
    try {
      await _storage.clearAllData();
      _settings = const QuizSettings(mode: QuizMode.foodCountry);
      _userStats = const UserStats();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  Future<Map<String, dynamic>> exportData() async {
    try {
      return await _storage.exportData();
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return {};
    }
  }

  Future<void> importData(Map<String, dynamic> data) async {
    try {
      await _storage.importData(data);
      await initialize(); // Reload everything
    } catch (e) {
      debugPrint('Error importing data: $e');
    }
  }

  // Helper methods for common statistics
  int get totalGamesPlayed => _userStats.totalGamesPlayed;

  /// En yüksek mod-yüzdesi (0-100). Modlar arası TOPLAM değil, MAX.
  int get bestScoreOverall {
    final values = _userStats.bestScores.values;
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a > b ? a : b);
  }

  /// Tüm modların oyun-ağırlıklı lifetime ortalama yüzdesi (0-100).
  double get overallAverageScore {
    final gamesPerMode = _userStats.gamesPerMode;
    final averageScores = _userStats.averageScores;
    if (gamesPerMode.isEmpty) return 0.0;
    double totalPct = 0.0;
    int totalCount = 0;
    for (final entry in gamesPerMode.entries) {
      final count = entry.value;
      final avg = averageScores[entry.key] ?? 0.0;
      totalPct += avg * count;
      totalCount += count;
    }
    return totalCount == 0 ? 0.0 : totalPct / totalCount;
  }

  // Get performance for current mode
  int getBestScoreForMode(QuizMode mode) {
    return _userStats.getBestScore(mode);
  }

  double getAverageScoreForMode(QuizMode mode) {
    return _userStats.getAverageScore(mode);
  }

  // Check if this is a new best score (percentage semantics)
  bool isNewBestScore(QuizResult result) {
    final currentBest = getBestScoreForMode(result.mode);
    return result.percentage.round() > currentBest;
  }

  // Get performance trend (simplified)
  String getPerformanceTrend(QuizMode mode) {
    final recent =
        _userStats.recentResults.where((r) => r.mode == mode).take(5).toList();

    if (recent.length < 2) return 'Not enough data';

    final recentAverage =
        recent.map((r) => r.percentage).reduce((a, b) => a + b) / recent.length;
    final overallAverage = getAverageScoreForMode(mode);

    if (recentAverage > overallAverage + 5) return 'Improving';
    if (recentAverage < overallAverage - 5) return 'Declining';
    return 'Stable';
  }
}
