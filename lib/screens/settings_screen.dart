import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/models.dart';
import '../services/settings_provider.dart';
import '../services/locale_controller.dart';
import '../widgets/top_lang_toggle.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? _selectedLocale;

  @override
  void initState() {
    super.initState();
    _selectedLocale = context.read<LocaleController>().override;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        final settings = settingsProvider.settings;

        return Scaffold(
          appBar: AppBar(
            title: Text(s.settings),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const TopLangToggle(),
              const SizedBox(height: 16),
              // Language Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.language,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      RadioListTile<Locale?>(
                        title: Text(s.languageEnglish),
                        value: const Locale('en'),
                        groupValue: _selectedLocale,
                        onChanged: (v) {
                          setState(() => _selectedLocale = v);
                        },
                      ),
                      RadioListTile<Locale?>(
                        title: Text(s.languageTurkish),
                        value: const Locale('tr'),
                        groupValue: _selectedLocale,
                        onChanged: (v) {
                          setState(() => _selectedLocale = v);
                        },
                      ),
                      RadioListTile<Locale?>(
                        title: Text(s.languageSystemDefault),
                        subtitle: Text(_getSystemLocaleDesc()),
                        value: null,
                        groupValue: _selectedLocale,
                        onChanged: (v) {
                          setState(() => _selectedLocale = v);
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            await context
                                .read<LocaleController>()
                                .setLocale(_selectedLocale);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(s.save)),
                              );
                            }
                          },
                          child: Text(s.save),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Quiz Settings Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.quizSettings,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(s.timer),
                        subtitle: Text(s.timerPerQuestionDesc),
                        value: settings.timerEnabled,
                        onChanged: (value) {
                          settingsProvider.updateTimerEnabled(value);
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(s.questionCount),
                        subtitle:
                            Text(s.questionsLabel(settings.questionCount)),
                        trailing: DropdownButton<int>(
                          value: settings.questionCount,
                          items: [5, 10, 15, 20, 25].map((count) {
                            return DropdownMenuItem(
                              value: count,
                              child: Text('$count'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              settingsProvider.updateQuestionCount(value);
                            }
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(s.difficultyLevel),
                        subtitle: Text(_getDifficultyText(settings.difficulty)),
                        trailing: DropdownButton<DifficultyLevel>(
                          value: settings.difficulty,
                          items: DifficultyLevel.values.map((level) {
                            return DropdownMenuItem(
                              value: level,
                              child: Text(_getDifficultyText(level)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              settingsProvider.updateDifficulty(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // About Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.about,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.info),
                        title: Text(s.menuTitle),
                        subtitle: Text(s.appDescription),
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: Text(s.capitalMode),
                        subtitle: Text(s.capitalModeDesc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.flag),
                        title: Text(s.flagMode),
                        subtitle: Text(s.flagModeDesc),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Difficulty Levels Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.difficultyLevels,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.sentiment_satisfied,
                            color: Colors.green),
                        title: Text(s.difficultyEasy),
                        subtitle: Text(s.difficultyEasyDesc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.sentiment_neutral,
                            color: Colors.orange),
                        title: Text(s.difficultyMedium),
                        subtitle: Text(s.difficultyMediumDesc),
                      ),
                      ListTile(
                        leading: const Icon(Icons.sentiment_dissatisfied,
                            color: Colors.red),
                        title: Text(s.difficultyHard),
                        subtitle: Text(s.difficultyHardDesc),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDifficultyText(DifficultyLevel level) {
    final s = S.of(context);
    switch (level) {
      case DifficultyLevel.easy:
        return s.difficultyEasy;
      case DifficultyLevel.medium:
        return s.difficultyMedium;
      case DifficultyLevel.hard:
        return s.difficultyHard;
    }
  }

  String _getSystemLocaleDesc() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return '(${systemLocale.languageCode})';
  }
}
