import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'app_locale';

const supportedLocales = [
  Locale('en'),
  Locale('ko'),
  Locale('ja'),
  Locale('zh'),
];

/// Keeps the currently selected [Locale] in memory and persists it to prefs.
/// The UI calls [LocaleNotifier.setLocale] and also forwards the change to
/// `easy_localization` via `context.setLocale()` — see [SettingsPage].
class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    // Sync-load the saved locale; async initialisation handled by [localeInitProvider].
    return const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocaleKey, locale.languageCode);
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLocaleKey);
    if (code != null) {
      state = Locale(code);
    }
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

/// Loads the persisted locale once at app start.
final localeInitProvider = FutureProvider<void>((ref) async {
  await ref.read(localeProvider.notifier).loadSaved();
});
