import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/app_info.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_tokens.dart';
import '../widgets/language_flag_button.dart';
import '../widgets/language_picker.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.settings),
        actions: const [LanguageFlagButton()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: s.language,
            child: const LanguagePickerList(),
          ),
          AppSpacing.vLg,
          _SupportCard(),
          AppSpacing.vLg,
          _AboutCard(),
        ],
      ),
    );
  }
}

/// Shared card shell used by the three Settings sections. Keeps spacing,
/// clipping and the title treatment consistent so the screen reads as a
/// single polished surface rather than a list of mismatched widgets.
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          child,
          AppSpacing.vSm,
        ],
      ),
    );
  }
}

class _SupportCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _SectionCard(
      title: s.support,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              s.supportIntro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.85),
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(s.contactEmail),
            subtitle: const Text(AppInfo.supportEmail),
            trailing: const Icon(Icons.arrow_outward_rounded, size: 18),
            onTap: () => _openMail(context),
          ),
        ],
      ),
    );
  }

  Future<void> _openMail(BuildContext context) async {
    final subject = Uri.encodeComponent(
      'Geo Quiz Support (v${AppInfo.displayVersion})',
    );
    final uri = Uri.parse('mailto:${AppInfo.supportEmail}?subject=$subject');
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) {
        _showEmailFallback(context);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Support mailto failed: $e');
      if (context.mounted) _showEmailFallback(context);
    }
  }

  void _showEmailFallback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppInfo.supportEmail),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return _SectionCard(
      title: s.about,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.public_rounded),
            title: Text(s.appName),
            subtitle: Text(s.appDescription),
          ),
          ListTile(
            leading: const Icon(Icons.tag_rounded),
            title: Text(s.version),
            subtitle: Text(AppInfo.displayVersion),
          ),
        ],
      ),
    );
  }
}
