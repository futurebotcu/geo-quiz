import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/models.dart';
import '../services/settings_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/mode_labels.dart';
import '../l10n/app_localizations.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final stats = settingsProvider.userStats;

        return Scaffold(
          appBar: AppBar(
            title: Text(s.statsTitle),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.overallStats,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              S.of(context).totalGames,
                              '${stats.totalGamesPlayed}',
                              Icons.games,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatItem(
                              s.bestScoreShort,
                              stats.bestScores.values.isEmpty
                                  ? '—'
                                  : '${stats.bestScores.values.reduce((a, b) => a > b ? a : b)}%',
                              Icons.star,
                              Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...QuizMode.values
                  .where((m) => m != QuizMode.capitalFromImage)
                  .map((mode) => _buildModeCard(context, mode, stats)),
              const SizedBox(height: 16),
              _buildRecentResultsCard(context, settingsProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeCard(BuildContext context, QuizMode mode, UserStats stats) {
    final s = S.of(context);
    final bestScore = stats.getBestScore(mode);
    final averageScore = stats.getAverageScore(mode);
    final color = AppModeColors.forMode(mode);

    IconData icon;
    switch (mode) {
      case QuizMode.foodCountry:
        icon = Icons.restaurant;
        break;
      case QuizMode.capitalPhoto:
      case QuizMode.capitalFromImage:
        icon = Icons.location_city;
        break;
      case QuizMode.flagCountry:
        icon = Icons.flag;
        break;
      case QuizMode.capitalCountry:
        icon = Icons.quiz;
        break;
      case QuizMode.mixed:
        icon = Icons.shuffle;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    localizedModeName(s, mode),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      s.bestScoreShort,
                      bestScore == 0 && stats.getGamesPlayed(mode) == 0
                          ? '—'
                          : '$bestScore%',
                      Icons.star,
                      color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      s.average,
                      '${averageScore.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentResultsCard(
      BuildContext context, SettingsProvider settingsProvider) {
    final s = S.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.recentResults,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<QuizResult>>(
              future: settingsProvider.getRecentResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = snapshot.data ?? [];
                if (results.isEmpty) {
                  return Text(s.noGamesPlayed);
                }

                return Column(
                  children: results.take(5).map((result) {
                    final modeColor = AppModeColors.forMode(result.mode);
                    final modeName = localizedModeName(s, result.mode);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: modeColor,
                        child: Text(
                          '${result.score}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(modeName),
                      subtitle: Text(_formatDate(context, result.completedAt)),
                      trailing: Text(
                        '${result.percentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.brSm,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    // Locale-aware short date: EN → 4/19/2026, TR → 19.04.2026.
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale).format(date);
  }
}
