import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/services/tracked_manga_service.dart';

class MangaUpdate {
  final TrackedManga manga;
  final Chapter chapter;
  const MangaUpdate({required this.manga, required this.chapter});
}

class NotificationService {
  static const int combinedNotificationId = 2001;
  static const String channelId = 'oping_new_chapters';
  static const String channelName = 'New manga chapters';
  static const String _channelDescription =
      'Notifies when a new chapter is available for any tracked manga.';

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNewChapterNotification(
    TrackedManga manga,
    Chapter chapter,
  ) async {
    final chapterLabel = _formatChapterNumber(chapter.number);
    final body = chapter.title.isNotEmpty
        ? 'Chapter $chapterLabel: ${chapter.title}'
        : 'Chapter $chapterLabel is out!';

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _notificationIdForManga(manga.id),
      'New chapter: ${manga.title}',
      body,
      details,
    );
  }

  Future<void> showCombinedNewChaptersNotification(
    List<MangaUpdate> updates,
  ) async {
    if (updates.isEmpty) return;
    if (updates.length == 1) {
      return showNewChapterNotification(updates.first.manga, updates.first.chapter);
    }

    final entries = updates
        .map((u) => '${u.manga.title} #${_formatChapterNumber(u.chapter.number)}')
        .toList();
    final preview = entries.take(3).join(', ');
    final remaining = entries.length - 3;
    final body = remaining > 0 ? '$preview, +$remaining more' : preview;
    final bigText = entries.join('\n');

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      styleInformation: BigTextStyleInformation(
        bigText,
        contentTitle: '${updates.length} manga updated',
      ),
    );
    final details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      combinedNotificationId,
      '${updates.length} manga updated',
      body,
      details,
    );
  }

  static int _notificationIdForManga(String mangaId) =>
      mangaId.hashCode & 0x7fffffff;

  static String _formatChapterNumber(double number) {
    if (number == number.truncateToDouble()) {
      return number.toInt().toString();
    }
    return number.toString();
  }
}
