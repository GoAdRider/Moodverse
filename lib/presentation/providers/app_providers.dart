import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../data/repositories/diary_repository_impl.dart';
import '../../domain/repositories/i_diary_repository.dart';

/// Singleton database instance shared across all providers.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// The canonical repository provider. All features access data through this.
final diaryRepositoryProvider = Provider<IDiaryRepository>((ref) {
  return DiaryRepositoryImpl(ref.watch(databaseProvider));
});
