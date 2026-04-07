import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/providers/locale_provider.dart';

/// Root application widget.
///
/// - [ProviderScope] at the top supplies Riverpod to the entire tree.
/// - [EasyLocalization] (added in main.dart) provides the localisation layer.
/// - [_LocaleSyncWidget] bridges Riverpod locale state → EasyLocalization so
///   that locale is always consistent between the two systems.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LocaleSyncWidget();
  }
}

class _LocaleSyncWidget extends ConsumerWidget {
  const _LocaleSyncWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Load persisted locale once at startup.
    ref.watch(localeInitProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'app.title'.tr(),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: EasyLocalization.of(context)!.locale,
      supportedLocales: EasyLocalization.of(context)!.supportedLocales,
      localizationsDelegates: EasyLocalization.of(context)!.delegates,
      home: const HomePage(),
    );
  }
}
