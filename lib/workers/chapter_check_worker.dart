import 'package:workmanager/workmanager.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/notification_service.dart';

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
  final NotificationService _notifications;

  WorkerTask({
    MangaDexService? mangaDex,
    ChapterStorageService? storage,
    NotificationService? notifications,
  })  : _mangaDex = mangaDex ?? MangaDexService(),
        _storage = storage ?? ChapterStorageService(),
        _notifications = notifications ?? NotificationService();

  Future<bool> execute() async {
    try {
      await _notifications.initialize();

      final latestChapter = await _mangaDex.fetchLatestChapter();
      if (latestChapter == null) return true;

      final storedNumber = await _storage.getLastSeenChapter();
      if (latestChapter.isNewerThan(storedNumber)) {
        await _notifications.showNewChapterNotification(latestChapter);
        await _storage.saveLastSeenChapter(latestChapter.number);
      }

      return true;
    } catch (_) {
      return false;
    }
  }
}
