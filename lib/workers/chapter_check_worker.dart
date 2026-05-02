import 'package:workmanager/workmanager.dart';

import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/notification_service.dart';
import 'package:oping/services/tracked_manga_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == WorkerTask.taskName) {
      return WorkerTask().execute();
    }
    return true;
  });
}

class WorkerTask {
  static const String taskName = 'one_piece_chapter_check';

  final MangaDexService _mangaDex;
  final ChapterStorageService _storage;
  final TrackedMangaService _tracked;
  final NotificationService _notifications;

  WorkerTask({
    MangaDexService? mangaDex,
    ChapterStorageService? storage,
    TrackedMangaService? tracked,
    NotificationService? notifications,
  })  : _mangaDex = mangaDex ?? MangaDexService(),
        _storage = storage ?? ChapterStorageService(),
        _tracked = tracked ?? TrackedMangaService(),
        _notifications = notifications ?? NotificationService();

  Future<bool> execute() async {
    try {
      await _notifications.initialize();

      final tracked = await _tracked.getAll();
      if (tracked.isEmpty) {
        await _storage.markChecked();
        return true;
      }

      final language = await _storage.getPreferredLanguage();
      final latestById = await _mangaDex.fetchLatestChaptersFor(
        tracked.map((m) => m.id).toList(),
        language: language,
      );

      final updates = <MangaUpdate>[];
      for (final manga in tracked) {
        final latest = latestById[manga.id];
        if (latest == null) continue;
        if (latest.number > manga.lastSeenChapter) {
          updates.add(MangaUpdate(manga: manga, chapter: latest));
        }
      }

      if (updates.isNotEmpty) {
        if (updates.length == 1) {
          await _notifications.showNewChapterNotification(
            updates.first.manga,
            updates.first.chapter,
          );
        } else {
          await _notifications.showCombinedNewChaptersNotification(updates);
        }

        for (final update in updates) {
          await _tracked.updateLastSeen(update.manga.id, update.chapter.number);
        }
      }

      await _storage.markChecked();
      return true;
    } catch (_) {
      return false;
    }
  }
}
