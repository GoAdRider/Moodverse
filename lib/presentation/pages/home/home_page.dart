import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/diary_providers.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../diary_form/diary_form_page.dart';
import '../settings/settings_page.dart';
import '../stats/stats_page.dart';
import 'widgets/diary_card_widget.dart';
import 'widgets/emotion_filter_widget.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(filteredDiaryEntriesProvider);
    final filter = ref.watch(emotionFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('home.title'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart_rounded),
            tooltip: 'nav.stats'.tr(),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StatsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'nav.settings'.tr(),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Emotion filter bar ──────────────────────────────────────────
          const SizedBox(height: 8),
          const EmotionFilterWidget(),
          const SizedBox(height: 8),

          // ── Entry list ──────────────────────────────────────────────────
          Expanded(
            child: entriesAsync.when(
              loading: () => const LoadingWidget(),
              error: (e, _) => Center(child: Text('error.generic'.tr())),
              data: (entries) {
                if (entries.isEmpty) {
                  return EmptyStateWidget(
                    emoji: filter == null ? '📔' : filter.emoji,
                    titleKey: filter == null
                        ? 'home.empty_title'
                        : 'home.empty_filtered_title',
                    subtitleKey: filter == null
                        ? 'home.empty_subtitle'
                        : null,
                    action: filter == null
                        ? ElevatedButton.icon(
                            onPressed: () => _openNewEntry(context),
                            icon: const Icon(Icons.add),
                            label: Text('home.write_first'.tr()),
                          )
                        : TextButton(
                            onPressed: () => ref
                                .read(emotionFilterProvider.notifier)
                                .state = null,
                            child: Text('filter.clear'.tr()),
                          ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    ref.invalidate(filteredDiaryEntriesProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: entries.length,
                    itemBuilder: (_, i) =>
                        DiaryCardWidget(entry: entries[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openNewEntry(context),
        icon: const Icon(Icons.edit_outlined),
        label: Text('home.write_btn'.tr()),
      ),
    );
  }

  void _openNewEntry(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DiaryFormPage()),
    );
  }
}
