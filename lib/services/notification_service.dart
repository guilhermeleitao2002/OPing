import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:oping/models/chapter.dart';

class NotificationService {
  static const int _chapterNotificationId = 1001;
  static const String _channelId = 'oping_new_chapter';
  static const String _channelName = 'New One Piece Chapter';

  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Notifies when a new One Piece chapter is available',
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> showNewChapterNotification(Chapter chapter) async {
    final body = chapter.title.isNotEmpty
        ? 'Chapter ${chapter.number} is out: ${chapter.title}'
        : 'Chapter ${chapter.number} is out!';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifies when a new One Piece chapter is available',
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      _chapterNotificationId,
      'New One Piece Chapter! \u{1F3F4}',
      body,
      details,
    );
  }
}
