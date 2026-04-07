import '../entities/diary_entry_entity.dart';
import '../entities/emotion_stats_entity.dart';
import '../entities/emotion_type.dart';

/// Abstract repository contract — implemented in the data layer.
/// The domain layer has zero knowledge of Drift, SQLite, or any storage detail.
abstract interface class IDiaryRepository {
  // ── CRUD ─────────────────────────────────────────────────────────────────

  /// Streams all entries ordered by createdAt DESC.
  Stream<List<DiaryEntryEntity>> watchAllEntries();

  /// Streams entries filtered by [emotion].
  Stream<List<DiaryEntryEntity>> watchEntriesByEmotion(EmotionType emotion);

  /// Streams entries whose [createdAt] falls within [from]..[to].
  Stream<List<DiaryEntryEntity>> watchEntriesInRange(
    DateTime from,
    DateTime to,
  );

  /// Returns a single entry by [id], or null if not found.
  Future<DiaryEntryEntity?> getEntryById(int id);

  /// Persists a new entry and returns its assigned id.
  Future<int> createEntry(DiaryEntryEntity entry);

  /// Updates an existing entry. Throws if [entry.id] is null.
  Future<void> updateEntry(DiaryEntryEntity entry);

  /// Permanently deletes the entry with [id].
  Future<void> deleteEntry(int id);

  // ── Statistics ────────────────────────────────────────────────────────────

  /// Returns aggregated statistics for the last [days] days.
  Future<EmotionStatsEntity> getStats({int days = 30});

  /// Returns per-emotion entry counts for [days] days.
  Future<Map<EmotionType, int>> getEmotionCounts({int days = 30});
}
