import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/emotion_stats_entity.dart';
import 'app_providers.dart';

/// Controls the look-back window (days) for statistics.
final statsRangeProvider = StateProvider<int>((ref) => 30);

/// Fetches aggregated statistics for the selected range.
/// Automatically re-fetches when [statsRangeProvider] changes.
final emotionStatsProvider = FutureProvider<EmotionStatsEntity>((ref) {
  final repo = ref.watch(diaryRepositoryProvider);
  final days = ref.watch(statsRangeProvider);
  return repo.getStats(days: days);
});
