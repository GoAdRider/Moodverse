import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/diary_entry_entity.dart';
import '../../domain/entities/emotion_type.dart';
import 'app_providers.dart';

// ── Filter state ──────────────────────────────────────────────────────────────

/// Currently active emotion filter; null means "show all".
final emotionFilterProvider = StateProvider<EmotionType?>((ref) => null);

// ── Diary list stream ─────────────────────────────────────────────────────────

/// Reactively streams diary entries, respecting the active filter.
/// UI widgets simply call `ref.watch(filteredDiaryEntriesProvider)` —
/// no business logic leaks into the widget tree.
final filteredDiaryEntriesProvider =
    StreamProvider<List<DiaryEntryEntity>>((ref) {
  final repo = ref.watch(diaryRepositoryProvider);
  final filter = ref.watch(emotionFilterProvider);

  return filter == null
      ? repo.watchAllEntries()
      : repo.watchEntriesByEmotion(filter);
});

// ── Single entry ──────────────────────────────────────────────────────────────

final diaryEntryByIdProvider =
    FutureProvider.family<DiaryEntryEntity?, int>((ref, id) {
  return ref.watch(diaryRepositoryProvider).getEntryById(id);
});

// ── Mutation notifier ─────────────────────────────────────────────────────────

/// Encapsulates all write operations. The UI never touches the repository
/// directly — it calls methods on this notifier.
class DiaryMutationNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> create({
    required String content,
    required EmotionType emotion,
    required int intensity,
  }) async {
    final now = DateTime.now();
    final entry = DiaryEntryEntity(
      content: content,
      emotion: emotion,
      emotionIntensity: intensity,
      createdAt: now,
      updatedAt: now,
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(diaryRepositoryProvider).createEntry(entry),
    );
  }

  Future<void> update(DiaryEntryEntity entry) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(diaryRepositoryProvider).updateEntry(
            entry.copyWith(updatedAt: DateTime.now()),
          ),
    );
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(diaryRepositoryProvider).deleteEntry(id),
    );
  }
}

final diaryMutationProvider =
    AsyncNotifierProvider<DiaryMutationNotifier, void>(
  DiaryMutationNotifier.new,
);
