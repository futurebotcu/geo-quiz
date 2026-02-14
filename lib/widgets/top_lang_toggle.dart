import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/locale_controller.dart';

/// Language toggle widget (TR | EN | SYS) displayed at the top of screens
class TopLangToggle extends StatelessWidget {
  const TopLangToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleController>(
      builder: (context, controller, _) {
        final current = controller.override?.languageCode ?? '';

        Widget pill(String code, String label) {
          final active = (code == '' && current == '') || (code == current);
          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              controller.setLocale(code.isEmpty ? null : Locale(code));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? Colors.black.withOpacity(0.08)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active ? Colors.black38 : Colors.black26,
                  width: active ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  color: active ? Colors.black87 : Colors.black54,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                pill('tr', 'TR'),
                const SizedBox(width: 8),
                pill('en', 'EN'),
                const SizedBox(width: 8),
                pill('', 'SYS'),
              ],
            ),
          ),
        );
      },
    );
  }
}
