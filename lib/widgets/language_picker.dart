import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/app_locales.dart';
import '../services/locale_controller.dart';
import '../theme/app_tokens.dart';

/// Inline list of all 12 supported languages + a "System default" row at the
/// top. Selection auto-applies (no Save button) — matches the instant-apply
/// behaviour used elsewhere in the app.
class LanguagePickerList extends StatelessWidget {
  /// Called after a successful selection. Useful for closing a bottom sheet.
  final VoidCallback? onSelected;

  const LanguagePickerList({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final s = S.of(context);
    final theme = Theme.of(context);
    final override = controller.override;

    Widget row({
      required Widget leading,
      required String title,
      String? subtitle,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              SizedBox(width: 32, child: Center(child: leading)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withValues(alpha: 0.75),
                        ),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_rounded,
                    color: theme.colorScheme.primary, size: 22),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // System default — always first.
        row(
          leading: Icon(Icons.phone_iphone_rounded,
              size: 22, color: theme.colorScheme.primary),
          title: s.languageSystemDefault,
          subtitle: _systemSubtitle(context),
          selected: override == null,
          onTap: () async {
            await controller.useSystemDefault();
            onSelected?.call();
          },
        ),
        const Divider(height: 1),
        // 12 supported languages.
        ...AppLocales.supported.map((meta) {
          final selected = override?.languageCode == meta.code;
          final showEnglishLabel = meta.englishName != meta.nativeName;
          return row(
            leading: Text(meta.flag, style: const TextStyle(fontSize: 22)),
            title: meta.nativeName,
            subtitle: showEnglishLabel ? meta.englishName : null,
            selected: selected,
            onTap: () async {
              await controller.setLocale(meta.locale);
              onSelected?.call();
            },
          );
        }),
      ],
    );
  }

  String _systemSubtitle(BuildContext context) {
    final system = WidgetsBinding.instance.platformDispatcher.locale;
    final resolved = AppLocales.resolveForSystem(system);
    // Show the language the system will fall through to.
    return '${resolved.flag}  ${resolved.nativeName}';
  }
}

/// Modal bottom sheet wrapper around [LanguagePickerList]. Used by the
/// top-right flag button.
Future<void> showLanguagePickerSheet(BuildContext context) {
  final s = S.of(context);
  return showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(
                    s.language,
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 8),
                child: LanguagePickerList(
                  onSelected: () => Navigator.pop(ctx),
                ),
              ),
            ),
            AppSpacing.vSm,
          ],
        ),
      );
    },
  );
}
