import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_controller.dart';
import 'language_picker.dart';

/// Small pill displayed in an [AppBar] `actions` slot. Shows the currently
/// effective language as a Unicode flag emoji. Tapping opens the language
/// picker bottom sheet.
///
/// The flag is a UI hint, not a country claim — see [AppLocales.supported].
class LanguageFlagButton extends StatelessWidget {
  const LanguageFlagButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocaleController>();
    final meta = controller.effective(context);
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showLanguagePickerSheet(context),
          child: Tooltip(
            message: meta.nativeName,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(meta.flag, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    meta.code.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
