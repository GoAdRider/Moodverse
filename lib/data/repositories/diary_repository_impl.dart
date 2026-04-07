import 'package:drift/drift.dart';

import '../../domain/entities/diary_entry_entity.dart';
import '../../domain/entities/emotion_stats_entity.dart';
import '../../domain/entities/emotion_type.dart';
import '../../domain/repositories/i_diary_repository.dart';
import '../database/app_database.dart';

/// Concrete implementation of [IDiaryRepository].
/// Lives in the data layer — knows about Drift, maps to/from domain entities.
class DiaryRepositoryImpl implements IDiaryRepository {
  const DiaryRepositoryImpl(this._db);

  final AppDatabase _db;

  // ── Mapping helpers ───────────────────────────────────────────────────────

  DiaryEntryEntity _toDomain(DiaryEntry row) {
    return DiaryEntryEntity(
      id: row.id,
      content: row.content,
      emotion: EmotionType.fromString(row.emotion),
      emotionIntensity: row.emotionIntensity,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  DiaryEntriesCompanion _toCompanion(DiaryEntryEntity entity) {
    return DiaryEntriesCompanion(
      id: entity.id != null ? Value(entity.id!) : const Value.absent(),
      content: Value(entity.content),
      emotion: Value(entity.emotion.name),
      emotionIntensity: Value(entity.emotionIntensity),
      createdAt: Value(entity.createdAt),
      updatedAt: Value(entity.updatedAt),
    );
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────

  @override
  Stream<List<DiaryEntryEntity>> watchAllEntries() {
    return _db.watchAllEntries().map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<DiaryEntryEntity>> watchEntriesByEmotion(EmotionType emotion) {
    return _db
        .watchEntriesByEmotion(emotion.name)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Stream<List<DiaryEntryEntity>> watchEntriesInRange(
    DateTime from,
    DateTime to,
  ) {
    return _db
        .watchEntriesInRange(from, to)
        .map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<DiaryEntryEntity?> getEntryById(int id) async {
    final row = await _db.getEntryById(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<int> createEntry(DiaryEntryEntity entry) {
    return _db.insertEntry(_toCompanion(entry));
  }

  @override
  Future<void> updateEntry(DiaryEntryEntity entry) {
    assert(entry.id != null, 'updateEntry requires a non-null id');
    return _db.updateEntry(_toCompanion(entry));
  }

  @override
  Future<void> deleteEntry(int id) {
    return _db.deleteEntry(id);
  }

  // ── Statistics ────────────────────────────────────────────────────────────

  @override
  Future<EmotionStatsEntity> getStats({int days = 30}) async {
    final rows = await _db.getEntriesForLastDays(days);
    final entities = rows.map(_toDomain).toList();

    final counts = <EmotionType, int>{};
    final intensitySums = <EmotionType, double>{};

    for (final e in entities) {
      counts[e.emotion] = (counts[e.emotion] ?? 0) + 1;
      intensitySums[e.emotion] =
          (intensitySums[e.emotion] ?? 0) + e.emotionIntensity;
    }

    final avgIntensities = {
      for (final entry in counts.entries)
        entry.key: intensitySums[entry.key]! / entry.value,
    };

    final dailySummaries = _buildDailySummaries(entities);
    final streak = _calculateStreak(entities);

    return EmotionStatsEntity(
      emotionCounts: counts,
      averageIntensities: avgIntensities,
      dailySummaries: dailySummaries,
      totalEntries: entities.length,
      currentStreak: streak,
    );
  }

  @override
  Future<Map<EmotionType, int>> getEmotionCounts({int days = 30}) async {
    final rows = await _db.getEntriesForLastDays(days);
    final counts = <EmotionType, int>{};
    for (final row in rows) {
      final emotion = EmotionType.fromString(row.emotion);
      counts[emotion] = (counts[emotion] ?? 0) + 1;
    }
    return counts;
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  List<DailyMoodSummary> _buildDailySummaries(
    List<DiaryEntryEntity> entries,
  ) {
    final grouped = <String, List<DiaryEntryEntity>>{};
    for (final e in entries) {
      final key =
          '${e.createdAt.year}-${e.createdAt.month}-${e.createdAt.day}';
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return grouped.entries.map((mapEntry) {
      final dayEntries = mapEntry.value;
      final emotionCount = <EmotionType, int>{};
      double intensitySum = 0;

      for (final e in dayEntries) {
        emotionCount[e.emotion] = (emotionCount[e.emotion] ?? 0) + 1;
        intensitySum += e.emotionIntensity;
      }

      final dominant = emotionCount.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;

      final parts = mapEntry.key.split('-');
      return DailyMoodSummary(
        date: DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        ),
        dominantEmotion: dominant,
        averageIntensity: intensitySum / dayEntries.length,
        entryCount: dayEntries.length,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  int _calculateStreak(List<DiaryEntryEntity> entries) {
    if (entries.isEmpty) return 0;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final writtenDays = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
      ..add(todayDate); // include today for streak calculation

    int streak = 0;
    DateTime checkDate = todayDate;

    while (writtenDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    // If today has no entry, streak starts from yesterday
    final todayHasEntry = entries.any((e) {
      final d = e.createdAt;
      return d.year == today.year && d.month == today.month && d.day == today.day;
    });

    return todayHasEntry ? streak : streak - 1;
  }
}
