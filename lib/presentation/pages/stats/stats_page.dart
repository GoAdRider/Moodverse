import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../providers/stats_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/loading_widget.dart';
import 'widgets/emotion_pie_chart.dart';
import 'widgets/weekly_mood_chart.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(emotionStatsProvider);
    final days = ref.watch(statsRangeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('stats.title'.tr()),
        actions: [
          // Range selector
          PopupMenuButton<int>(
            initialValue: days,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (d) =>
                ref.read(statsRangeProvider.notifier).state = d,
            itemBuilder: (_) => [7, 14, 30, 90]
                .map(
                  (d) => PopupMenuItem(
                    value: d,
                    child: Text('stats.last_days'.tr(args: ['$d'])),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text(
                    'stats.last_days'.tr(args: ['$days']),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down,
                      color: AppColors.primary, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => Center(child: Text('error.generic'.tr())),
        data: (stats) {
          if (stats.totalEntries == 0) {
            return const EmptyStateWidget(
              emoji: '📊',
              titleKey: 'stats.empty_title',
              subtitleKey: 'stats.empty_subtitle',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Summary cards ───────────────────────────────────────
                Row(
                  children: [
                    _StatCard(
                      label: 'stats.total_entries'.tr(),
                      value: '${stats.totalEntries}',
                      icon: Icons.book_outlined,
                    ),
                    const SizedBox(width: 12),
                    _StatCard(
                      label: 'stats.streak'.tr(),
                      value: 'stats.streak_days'
                          .tr(args: ['${stats.currentStreak}']),
                      icon: Icons.local_fire_department_outlined,
                      color: const Color(0xFFFF6B35),
                    ),
                  ],
                ),

                if (stats.dominantEmotion != null) ...[
                  const SizedBox(height: 12),
                  _StatCard(
                    label: 'stats.dominant_emotion'.tr(),
                    value:
                        '${stats.dominantEmotion!.emoji} ${stats.dominantEmotion!.translationKey.tr()}',
                    icon: Icons.mood_outlined,
                    color: stats.dominantEmotion!.color,
                    fullWidth: true,
                  ),
                ],

                const SizedBox(height: 24),

                // ── Emotion distribution ────────────────────────────────
                _SectionTitle('stats.distribution'.tr()),
                const SizedBox(height: 16),
                EmotionPieChart(counts: stats.emotionCounts),

                const SizedBox(height: 28),

                // ── Daily mood trend ────────────────────────────────────
                _SectionTitle('stats.mood_trend'.tr()),
                const SizedBox(height: 16),
                SizedBox(
                  height: 180,
                  child: WeeklyMoodChart(summaries: stats.dailySummaries),
                ),

                const SizedBox(height: 28),

                // ── Avg intensity per emotion ───────────────────────────
                _SectionTitle('stats.avg_intensity'.tr()),
                const SizedBox(height: 12),
                ...stats.averageIntensities.entries.map(
                  (e) => _IntensityRow(
                    emotion: e.key.translationKey.tr(),
                    emoji: e.key.emoji,
                    color: e.key.color,
                    avg: e.value,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.fullWidth = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }
}

class _IntensityRow extends StatelessWidget {
  const _IntensityRow({
    required this.emotion,
    required this.emoji,
    required this.color,
    required this.avg,
  });

  final String emotion;
  final String emoji;
  final Color color;
  final double avg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emotion,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: avg / 10,
                    backgroundColor: color.withOpacity(0.15),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            avg.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
