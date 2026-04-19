import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models.dart';

class StorageService {
  static const String _settingsKey = 'quiz_settings';
  static const String _userStatsKey = 'user_stats';
  static const String _recentResultsKey = 'recent_results';
  // Same key LocaleController uses directly (app_locale_code).
  // Kept in sync so exportData/importData can roundtrip the user's locale.
  static const String _localeKey = 'app_locale_code';

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  /// Reset singleton for testing — forces re-initialization of SharedPreferences.
  @visibleForTesting
  static void resetForTesting() {
    _instance?._prefs = null;
    _instance = null;
  }

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Settings
  Future<void> saveSettings(QuizSettings settings) async {
    await initialize();
    final json = jsonEncode(settings.toJson());
    await _prefs!.setString(_settingsKey, json);
  }

  Future<QuizSettings> loadSettings() async {
    await initialize();
    final json = _prefs!.getString(_settingsKey);
    if (json == null) {
      return const QuizSettings(mode: QuizMode.foodCountry);
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return QuizSettings.fromJson(data);
    } catch (e) {
      return const QuizSettings(mode: QuizMode.foodCountry);
    }
  }

  // User Stats
  Future<void> saveUserStats(UserStats stats) async {
    await initialize();
    final json = jsonEncode(stats.toJson());
    await _prefs!.setString(_userStatsKey, json);
  }

  Future<UserStats> loadUserStats() async {
    await initialize();
    final json = _prefs!.getString(_userStatsKey);
    if (json == null) {
      return const UserStats();
    }

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return UserStats.fromJson(data);
    } catch (e) {
      return const UserStats();
    }
  }

  // Quiz Results
  Future<void> saveQuizResult(QuizResult result) async {
    await initialize();

    // Load existing results
    final results = await loadRecentResults();

    // Add new result at the beginning
    final updatedResults = [result, ...results];

    // Keep only the last 20 results
    final limitedResults = updatedResults.take(20).toList();

    // Save back to storage
    final json = jsonEncode(limitedResults.map((r) => r.toJson()).toList());
    await _prefs!.setString(_recentResultsKey, json);

    // Update user stats
    await _updateUserStats(result);
  }

  Future<List<QuizResult>> loadRecentResults() async {
    await initialize();
    final json = _prefs!.getString(_recentResultsKey);
    if (json == null) {
      return [];
    }

    try {
      final List<dynamic> data = jsonDecode(json);
      return data.map((item) => QuizResult.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _updateUserStats(QuizResult result) async {
    final currentStats = await loadUserStats();
    final recentResults = await loadRecentResults();

    final totalGames = currentStats.totalGamesPlayed + 1;

    final bestScores = Map<QuizMode, int>.from(currentStats.bestScores);
    final averageScores =
        Map<QuizMode, double>.from(currentStats.averageScores);
    final gamesPerMode =
        Map<QuizMode, int>.from(currentStats.gamesPerMode);

    final pct = result.percentage; // 0.0 - 100.0
    final pctRounded = pct.round();

    // Best score: en yüksek yüzde (0-100 int)
    final currentBest = bestScores[result.mode] ?? 0;
    if (pctRounded > currentBest) {
      bestScores[result.mode] = pctRounded;
    }

    // Lifetime average: incremental formula ((oldAvg * oldCount) + pct) / newCount
    final oldCount = gamesPerMode[result.mode] ?? 0;
    final oldAvg = averageScores[result.mode] ?? 0.0;
    final newCount = oldCount + 1;
    final newAvg = ((oldAvg * oldCount) + pct) / newCount;
    averageScores[result.mode] = newAvg;
    gamesPerMode[result.mode] = newCount;

    final updatedStats = UserStats(
      totalGamesPlayed: totalGames,
      bestScores: bestScores,
      averageScores: averageScores,
      gamesPerMode: gamesPerMode,
      recentResults: recentResults,
    );

    await saveUserStats(updatedStats);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await initialize();
    await _prefs!.remove(_settingsKey);
    await _prefs!.remove(_userStatsKey);
    await _prefs!.remove(_recentResultsKey);
  }

  // Export data for backup
  Future<Map<String, dynamic>> exportData() async {
    await initialize();

    return {
      'settings': _prefs!.getString(_settingsKey),
      'userStats': _prefs!.getString(_userStatsKey),
      'recentResults': _prefs!.getString(_recentResultsKey),
      'appLocale': _prefs!.getString(_localeKey),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from backup. Each payload is validated by round-tripping
  /// through the corresponding model; invalid payloads throw
  /// [FormatException] before touching storage so the failure is atomic.
  Future<void> importData(Map<String, dynamic> data) async {
    await initialize();

    final settings = data['settings'];
    if (settings is String) {
      try {
        final parsed = jsonDecode(settings) as Map<String, dynamic>;
        QuizSettings.fromJson(parsed); // validate
      } catch (e) {
        throw FormatException('Invalid settings payload: $e');
      }
      await _prefs!.setString(_settingsKey, settings);
    }

    final userStats = data['userStats'];
    if (userStats is String) {
      try {
        final parsed = jsonDecode(userStats) as Map<String, dynamic>;
        UserStats.fromJson(parsed); // validate
      } catch (e) {
        throw FormatException('Invalid userStats payload: $e');
      }
      await _prefs!.setString(_userStatsKey, userStats);
    }

    final recentResults = data['recentResults'];
    if (recentResults is String) {
      try {
        final parsed = jsonDecode(recentResults) as List;
        for (final item in parsed) {
          if (item is Map<String, dynamic>) {
            QuizResult.fromJson(item); // validate
          }
        }
      } catch (e) {
        throw FormatException('Invalid recentResults payload: $e');
      }
      await _prefs!.setString(_recentResultsKey, recentResults);
    }

    final locale = data['appLocale'];
    if (locale is String) {
      // Accept supported language codes; empty string clears the override.
      const supported = {'en', 'tr', ''};
      if (supported.contains(locale)) {
        if (locale.isEmpty) {
          await _prefs!.remove(_localeKey);
        } else {
          await _prefs!.setString(_localeKey, locale);
        }
      }
      // Unknown locale: ignored silently (permissive).
    }
  }
}
