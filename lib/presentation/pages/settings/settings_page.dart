import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/locale_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  static const _languageOptions = [
    (locale: Locale('en'), labelKey: 'language.en', flag: '🇺🇸'),
    (locale: Locale('ko'), labelKey: 'language.ko', flag: '🇰🇷'),
    (locale: Locale('ja'), labelKey: 'language.ja', flag: '🇯🇵'),
    (locale: Locale('zh'), labelKey: 'language.zh', flag: '🇨🇳'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Language section ──────────────────────────────────────────
          _SectionHeader('settings.language'.tr()),
          Card(
            child: Column(
              children: _languageOptions.asMap().entries.map((e) {
                final option = e.value;
                final isLast = e.key == _languageOptions.length - 1;
                final isSelected =
                    currentLocale.languageCode == option.locale.languageCode;

                return Column(
                  children: [
                    ListTile(
                      leading: Text(
                        option.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(option.labelKey.tr()),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
                      onTap: () => _changeLocale(context, ref, option.locale),
                    ),
                    if (!isLast)
                      const Divider(
                        height: 1,
                        indent: 56,
                        color: AppColors.divider,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // ── App info section ──────────────────────────────────────────
          _SectionHeader('settings.about'.tr()),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.textSecondary),
                  title: Text('settings.version'.tr()),
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 1, indent: 56, color: AppColors.divider),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppColors.textSecondary),
                  title: Text('settings.privacy_note'.tr()),
                  subtitle: Text(
                    'settings.privacy_detail'.tr(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Changes the locale in both Riverpod state and easy_localization.
  void _changeLocale(BuildContext context, WidgetRef ref, Locale locale) {
    context.setLocale(locale); // Updates easy_localization (rebuilds tr() calls)
    ref.read(localeProvider.notifier).setLocale(locale); // Persists to prefs
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
