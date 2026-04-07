import 'package:drift/drift.dart';

/// Drift table definition for diary entries.
/// Drift code-gen will produce the [DiaryEntry] data class and
/// [DiaryEntriesTable] companion from this class.
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get content => text()();

  /// Stored as the [EmotionType.name] string (e.g. 'happy', 'sad').
  TextColumn get emotion => text()();

  /// Intensity on a 1–10 scale.
  IntColumn get emotionIntensity =>
      integer().withDefault(const Constant(5)).named('emotion_intensity')();

  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
}
