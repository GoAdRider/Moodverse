import 'emotion_type.dart';

class EmotionStatsEntity {
  final Map<EmotionType, int> emotionCounts;
  final Map<EmotionType, double> averageIntensities;
  final List<DailyMoodSummary> dailySummaries;
  final int totalEntries;
  final int currentStreak;

  const EmotionStatsEntity({
    required this.emotionCounts,
    required this.averageIntensities,
    required this.dailySummaries,
    required this.totalEntries,
    required this.currentStreak,
  });

  EmotionType? get dominantEmotion {
    if (emotionCounts.isEmpty) return null;
    return emotionCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}

class DailyMoodSummary {
  final DateTime date;
  final EmotionType dominantEmotion;
  final double averageIntensity;
  final int entryCount;

  const DailyMoodSummary({
    required this.date,
    required this.dominantEmotion,
    required this.averageIntensity,
    required this.entryCount,
  });
}
