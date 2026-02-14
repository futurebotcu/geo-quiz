import 'dart:convert';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/models.dart';

class StorageService {
  static const String _settingsKey = 'quiz_settings';
  static const String _userStatsKey = 'user_stats';
  static const String _recentResultsKey = 'recent_results';

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

    // Calculate new statistics
    final totalGames = currentStats.totalGamesPlayed + 1;

    // Calculate statistics for all modes
    final Map<QuizMode, int> bestScores = Map.from(currentStats.bestScores);
    final Map<QuizMode, double> averageScores =
        Map.from(currentStats.averageScores);

    // Update best score for this mode
    final currentBest = bestScores[result.mode] ?? 0;
    if (result.score > currentBest) {
      bestScores[result.mode] = result.score;
    }

    // Update average for this mode
    final modeResults = recentResults.where((r) => r.mode == result.mode);
    if (modeResults.isNotEmpty) {
      final average =
          modeResults.map((r) => r.percentage).reduce((a, b) => a + b) /
              modeResults.length;
      averageScores[result.mode] = average;
    }

    final updatedStats = UserStats(
      totalGamesPlayed: totalGames,
      bestScores: bestScores,
      averageScores: averageScores,
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
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  // Import data from backup
  Future<void> importData(Map<String, dynamic> data) async {
    await initialize();

    if (data['settings'] != null) {
      await _prefs!.setString(_settingsKey, data['settings']);
    }

    if (data['userStats'] != null) {
      await _prefs!.setString(_userStatsKey, data['userStats']);
    }

    if (data['recentResults'] != null) {
      await _prefs!.setString(_recentResultsKey, data['recentResults']);
    }
  }
}
