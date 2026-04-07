import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/diary_table.dart';

part 'app_database.g.dart';

/// Single Drift database for the application.
///
/// Run `dart run build_runner build --delete-conflicting-outputs`
/// to generate [app_database.g.dart].
@DriftDatabase(tables: [DiaryEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? _defaultExecutor());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _defaultExecutor() {
    return driftDatabase(name: 'emotion_diary');
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  Stream<List<DiaryEntry>> watchAllEntries() {
    return (select(diaryEntries)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<DiaryEntry>> watchEntriesByEmotion(String emotionName) {
    return (select(diaryEntries)
          ..where((t) => t.emotion.equals(emotionName))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<DiaryEntry>> watchEntriesInRange(DateTime from, DateTime to) {
    return (select(diaryEntries)
          ..where(
            (t) => t.createdAt.isBetweenValues(from, to),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<DiaryEntry?> getEntryById(int id) {
    return (select(diaryEntries)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertEntry(DiaryEntriesCompanion entry) {
    return into(diaryEntries).insert(entry);
  }

  Future<void> updateEntry(DiaryEntriesCompanion entry) async {
    await (update(diaryEntries)..where((t) => t.id.equals(entry.id.value)))
        .write(entry);
  }

  Future<void> deleteEntry(int id) async {
    await (delete(diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  /// Returns all entries within the last [days] days.
  Future<List<DiaryEntry>> getEntriesForLastDays(int days) {
    final from = DateTime.now().subtract(Duration(days: days));
    return (select(diaryEntries)
          ..where((t) => t.createdAt.isBiggerOrEqualValue(from))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }
}
