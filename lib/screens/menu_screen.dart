// lib/screens/menu_screen.dart
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

import '../core/models.dart';
import '../core/question_engine.dart';
import '../services/settings_provider.dart';
import '../services/mode_artwork_provider.dart';
import '../theme/app_tokens.dart';
import '../utils/data_health.dart';
import '../utils/image_picker.dart';
import 'quiz_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import '../widgets/header_carousel.dart';
import '../widgets/language_flag_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // Each carousel slide is a real-content photo linked to a concrete quiz mode.
  // Tapping a slide opens that mode's start-sheet (same behaviour as mode card).
  // Images are picked randomly from the bundled asset pool per app launch
  // (no new assets — zero bundle cost). Fallbacks used before async pick lands.
  List<String> _carouselImages = const <String>[
    'assets/food_photos/tr_baklava.jpg',
    'assets/capital_photos/FR_paris.jpg',
    'assets/capital_photos/JP_tokyo.jpg',
  ];
  static const _carouselModes = <QuizMode>[
    QuizMode.foodCountry,
    QuizMode.capitalPhoto,
    QuizMode.mixed,
  ];

  // Probe once; rebuilds (e.g. from LocaleController) must not re-run it.
  late final Future<DataHealth> _healthFuture = DataHealth.probe();

  void _openModeFromCarousel(QuizMode mode) {
    final s = S.of(context);
    final (String title, String subtitle, IconData icon, Color color) =
        switch (mode) {
      QuizMode.foodCountry => (
          s.modeFoodCountry,
          s.modeFoodCountryDesc,
          Icons.restaurant,
          Colors.orange,
        ),
      QuizMode.capitalPhoto || QuizMode.capitalFromImage => (
          s.modeCapitalPhoto,
          s.modeCapitalPhotoDesc,
          Icons.location_city,
          Colors.blue,
        ),
      QuizMode.flagCountry => (
          s.modeFlagCountry,
          s.modeFlagCountryDesc,
          Icons.flag,
          Colors.green,
        ),
      QuizMode.capitalCountry => (
          s.modeCapitalCountry,
          s.modeCapitalCountryDesc,
          Icons.public,
          Colors.purple,
        ),
      QuizMode.mixed => (
          s.modeMixed,
          s.modeMixedDesc,
          Icons.shuffle,
          Colors.teal,
        ),
    };
    _openQuizStartSheet(
      context,
      mode,
      title,
      subtitle,
      icon,
      color,
      'carousel-${mode.wireName}',
    );
  }

  @override
  void initState() {
    super.initState();
    // İlk 4 modu precache et (performans optimizasyonu)
    Future.microtask(() {
      if (mounted) {
        ModeArtworkProvider.precacheFor(context, QuizMode.foodCountry);
        ModeArtworkProvider.precacheFor(context, QuizMode.capitalPhoto);
        ModeArtworkProvider.precacheFor(context, QuizMode.flagCountry);
        ModeArtworkProvider.precacheFor(context, QuizMode.mixed);
      }
    });
    _pickCarouselSlides();
  }

  /// Randomize carousel slides from the already-bundled asset pool.
  /// Zero bundle cost — only reshuffles what is shipped.
  Future<void> _pickCarouselSlides() async {
    try {
      final foods = await loadFoodManifest();
      final capitals =
          (await loadCapitalManifest()).where((c) => c.hasPhoto).toList();
      if (foods.isEmpty || capitals.length < 2) return;
      final rng = Random();
      final food = foods[rng.nextInt(foods.length)];
      final c1 = capitals[rng.nextInt(capitals.length)];
      CapitalItem c2;
      do {
        c2 = capitals[rng.nextInt(capitals.length)];
      } while (c2.iso2 == c1.iso2);
      if (!mounted) return;
      setState(() {
        _carouselImages = [food.path, c1.path, c2.path];
      });
    } catch (_) {
      // fallback list stays in place
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.menuTitle),
        actions: [
            const LanguageFlagButton(),
            if (kDebugMode)
              IconButton(
                tooltip: s.debugCount,
                icon: const Icon(Icons.bug_report),
                onPressed: () async {
                  debugPrint('Karakter testi: ÇÖŞĞÜİ çöşğüı');
                  final engine = QuestionEngine();
                  await engine.initialize();
                  final counts = await engine.getAvailableItemsCount();
                  debugPrint('[COUNT] $counts');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Counts: $counts')),
                    );
                  }
                },
              ),
            IconButton(
              tooltip: s.statistics,
              icon: const Icon(Icons.insights),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              ),
            ),
            IconButton(
              tooltip: s.settings,
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: FutureBuilder<DataHealth>(
            future: _healthFuture,
            builder: (context, snapshot) {
              final health = snapshot.data;

              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  HeaderCarousel(
                    images: _carouselImages,
                    onItemTap: (i) => _openModeFromCarousel(_carouselModes[i]),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık + mini açıklama
                        Text(
                          s.modeSelect,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          s.modeDescription,
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodySmall?.color),
                        ),
                        const SizedBox(height: 16),

                        // Grid menü - Responsive (2 sütun geniş / 1 sütun dar)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth >= 600 ? 2 : 1;
                            final childAspectRatio =
                                constraints.maxWidth >= 600 ? 0.98 : 1.5;

                            return GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: childAspectRatio,
                              children: [
                                _ModeCard(
                                  mode: QuizMode.foodCountry,
                                  title: s.modeFoodCountry,
                                  subtitle: s.modeFoodCountryDesc,
                                  icon: Icons.restaurant,
                                  color: AppModeColors.foodCountry,
                                  enabled:
                                      health?.isEnabled('foodCountry') ?? true,
                                  tooltipMessage:
                                      health?.getTooltipMessage('foodCountry'),
                                ),
                                _ModeCard(
                                  mode: QuizMode.capitalPhoto,
                                  title: s.modeCapitalPhoto,
                                  subtitle: s.modeCapitalPhotoDesc,
                                  icon: Icons.location_city,
                                  color: AppModeColors.capitalPhoto,
                                  enabled:
                                      health?.isEnabled('capitalPhoto') ?? true,
                                  tooltipMessage:
                                      health?.getTooltipMessage('capitalPhoto'),
                                ),
                                _ModeCard(
                                  mode: QuizMode.flagCountry,
                                  title: s.modeFlagCountry,
                                  subtitle: s.modeFlagCountryDesc,
                                  icon: Icons.flag,
                                  color: AppModeColors.flagCountry,
                                  enabled:
                                      health?.isEnabled('flagCountry') ?? true,
                                  tooltipMessage:
                                      health?.getTooltipMessage('flagCountry'),
                                ),
                                _ModeCard(
                                  mode: QuizMode.capitalCountry,
                                  title: s.modeCapitalCountry,
                                  subtitle: s.modeCapitalCountryDesc,
                                  icon: Icons.public,
                                  color: AppModeColors.capitalCountry,
                                  enabled:
                                      health?.isEnabled('capitalCountry') ??
                                          true,
                                  tooltipMessage: health
                                      ?.getTooltipMessage('capitalCountry'),
                                ),
                                _ModeCard(
                                  mode: QuizMode.mixed,
                                  title: s.modeMixed,
                                  subtitle: s.modeMixedDesc,
                                  icon: Icons.shuffle,
                                  color: AppModeColors.mixed,
                                  enabled: health?.isEnabled('mixed') ?? true,
                                  tooltipMessage:
                                      health?.getTooltipMessage('mixed'),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 4),

                        // Küçük ipucu satırı
                        Row(
                          children: [
                            const Icon(Icons.lightbulb, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                s.hintText,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
    );
  }
}

class _ModeCard extends StatefulWidget {
  final QuizMode mode;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool enabled;
  final String? tooltipMessage;

  const _ModeCard({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.enabled = true,
    this.tooltipMessage,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final mode = widget.mode;
    final title = widget.title;
    final subtitle = widget.subtitle;
    final icon = widget.icon;
    final color = widget.color;
    final enabled = widget.enabled;
    final tooltipMessage = widget.tooltipMessage;
    final heroTag = 'mode-hero-${mode.wireName}';

    return FutureBuilder<ModeArtwork>(
      future: ModeArtworkProvider.pick(mode),
      builder: (context, snapshot) {
        final art = snapshot.data;

        // Micro scale-down on press gives the large card a tactile response
        // beyond the ripple. 0.98 is enough to feel, not enough to jiggle.
        Widget card = AnimatedScale(
          scale: _pressed && enabled ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 85),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.all(AppRadius.rXl),
              onTap: enabled
                  ? () => _openQuizStartSheet(
                      context, mode, title, subtitle, icon, color, heroTag)
                  : null,
              onHighlightChanged:
                  enabled ? (h) => setState(() => _pressed = h) : null,
              // Mode-colored ripple — refined alphas so press reads but the
              // card doesn't get "paint-dipped".
              splashColor: color.withValues(alpha: 0.10),
              highlightColor: color.withValues(alpha: 0.05),
              child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(AppRadius.rXl),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
                border: Border.all(
                  color: enabled
                      ? theme.dividerColor.withValues(alpha: 0.3)
                      : theme.dividerColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(AppRadius.rXl),
                child: Stack(
                  children: [
                    // Arka plan görseli veya emoji
                    Positioned.fill(
                      child: _buildBackground(art, enabled),
                    ),
                    // Karartma gradient
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.7),
                              Colors.black.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // İçerik
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconBadge(
                              icon: icon,
                              color: enabled ? color : Colors.grey.shade400),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                              color:
                                  enabled ? Colors.white : Colors.grey.shade300,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.25,
                                color: enabled
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (!enabled && tooltipMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: AppRadius.brSm,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.info_outline,
                                      size: 14, color: Colors.orange.shade800),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      s.missingData,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.orange.shade800,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Text(
                                  s.start,
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Icon(Icons.arrow_forward_rounded,
                                    size: 18, color: Colors.white),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ),
        );

        // Tooltip sadece disabled kartlara
        if (!enabled && tooltipMessage != null) {
          card = Tooltip(
            message: tooltipMessage,
            child: card,
          );
        }

        return Hero(
          tag: heroTag,
          flightShuttleBuilder: (ctx, anim, dir, from, to) {
            return ScaleTransition(
              scale: anim.drive(Tween(begin: 0.95, end: 1.0)),
              child: to.widget,
            );
          },
          child: card,
        );
      },
    );
  }

  Widget _buildBackground(ModeArtwork? art, bool enabled) {
    if (art?.emoji != null) {
      // Emoji arka plan (bayrak modu)
      return Container(
        color: Colors.grey.shade900,
        child: Center(
          child: Opacity(
            opacity: enabled ? 1.0 : 0.4,
            child: Text(
              art!.emoji!,
              style: const TextStyle(fontSize: 120),
            ),
          ),
        ),
      );
    } else if (art?.image != null) {
      // Görsel arka plan
      return Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: Image(
          image: art!.image!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey.shade800,
              child: const Center(
                child: Icon(Icons.image_not_supported,
                    color: Colors.white54, size: 48),
              ),
            );
          },
        ),
      );
    } else {
      // Fallback: düz renk
      return Container(
        color: enabled ? widget.color.withValues(alpha: 0.2) : Colors.grey.shade700,
      );
    }
  }
}

// Top-level so the header carousel (outside _ModeCard) can also open the
// same configuration sheet for a given mode.
void _openQuizStartSheet(
  BuildContext context,
  QuizMode mode,
  String title,
  String subtitle,
  IconData icon,
  Color color,
  String heroTag,
) {
    final s = S.of(context);
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final settings = settingsProvider.settings;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        DifficultyLevel tmpDifficulty = settings.difficulty;
        bool tmpTimer = settings.timerEnabled;
        int tmpCount = settings.questionCount;
        String? tmpContinent = settings.continentFilter;

        final continents = <(String, String?)>[
          (s.continentAll, null),
          (s.continentEurope, 'Europe'),
          (s.continentAsia, 'Asia'),
          (s.continentAfrica, 'Africa'),
          (s.continentNorthAmerica, 'North America'),
          (s.continentSouthAmerica, 'South America'),
          (s.continentOceania, 'Oceania'),
        ];

        // Accent override: sheet içindeki tüm Material bileşenleri
        // (ChoiceChip selected, Switch, FilledButton "Başlat") mod rengine
        // boyanır. Üstteki _IconBadge rengiyle senkron bir "bu modun sayfası"
        // hissi veriyor.
        final baseTheme = Theme.of(ctx);
        final baseScheme = baseTheme.colorScheme;
        final modAccentTheme = baseTheme.copyWith(
          colorScheme: baseScheme.copyWith(
            primary: color,
            onPrimary: Colors.white,
            primaryContainer: color.withValues(alpha: 0.15),
            onPrimaryContainer: color,
          ),
          chipTheme: baseTheme.chipTheme.copyWith(
            selectedColor: color.withValues(alpha: 0.15),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.brMd),
            ),
          ),
        );

        return Theme(
          data: modAccentTheme,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              // Split layout: scrollable config up top, fixed CTA at the
              // bottom. Drag handle is provided by `showDragHandle: true`
              // so we don't draw one manually.
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Hero başlık
                          Row(
                            children: [
                              Hero(
                                  tag: heroTag,
                                  child: _IconBadge(icon: icon, color: color)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      subtitle,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Zorluk seçimi
                          _Section(
                            title: s.difficulty,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: DifficultyLevel.values.map((d) {
                                final selected = d == tmpDifficulty;
                                return ChoiceChip(
                                  selected: selected,
                                  label: Text(_difficultyText(d, s)),
                                  onSelected: (_) =>
                                      setState(() => tmpDifficulty = d),
                                );
                              }).toList(),
                            ),
                          ),

                          // Soru sayısı
                          _Section(
                            title: s.questionCount,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [5, 10, 15, 20].map((n) {
                                final selected = n == tmpCount;
                                return ChoiceChip(
                                  selected: selected,
                                  label: Text('$n'),
                                  onSelected: (_) =>
                                      setState(() => tmpCount = n),
                                );
                              }).toList(),
                            ),
                          ),

                          // Süre (timer) anahtarı
                          _Section(
                            title: s.timer,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(s.timerEnabled),
                              subtitle: Text(s.countdownPerQuestion),
                              value: tmpTimer,
                              onChanged: (v) => setState(() => tmpTimer = v),
                            ),
                          ),

                          // Kıta filtresi
                          _Section(
                            title: s.continentFilter,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: continents.map((continent) {
                                final selected = tmpContinent == continent.$2;
                                return ChoiceChip(
                                  label: Text(
                                    continent.$1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  selected: selected,
                                  onSelected: (_) => setState(
                                      () => tmpContinent = continent.$2),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Pinned CTA bar. showModalBottomSheet(useSafeArea: true)
                  // wraps the sheet in SafeArea(bottom: false) — so the
                  // bottom system inset (gesture/home indicator) is NOT
                  // consumed by the framework. We explicitly consume it
                  // here so the button never sits under the gesture bar.
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: baseScheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: Text(s.start),
                        onPressed: () async {
                          // Atomic: 1 disk write + 1 notifyListeners.
                          await settingsProvider.updateQuizConfig(
                            difficulty: tmpDifficulty,
                            questionCount: tmpCount,
                            timerEnabled: tmpTimer,
                            continentFilter: tmpContinent,
                          );

                          final startSettings =
                              settingsProvider.settings.copyWith(mode: mode);

                          if (context.mounted) {
                            Navigator.pop(ctx); // sheet kapat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    QuizScreen(settings: startSettings),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBadge({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.brMd,
      ),
      padding: const EdgeInsets.all(10),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: t.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

String _difficultyText(DifficultyLevel d, S s) {
  switch (d) {
    case DifficultyLevel.easy:
      return s.difficultyEasy;
    case DifficultyLevel.medium:
      return s.difficultyMedium;
    case DifficultyLevel.hard:
      return s.difficultyHard;
  }
}
