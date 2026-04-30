import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oping/models/chapter.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/notification_service.dart';
import 'package:oping/workers/chapter_check_worker.dart';

import 'chapter_check_worker_test.mocks.dart';

@GenerateMocks([MangaDexService, ChapterStorageService, NotificationService])
void main() {
  late MockMangaDexService mockMangaDex;
  late MockChapterStorageService mockStorage;
  late MockNotificationService mockNotifications;
  late WorkerTask worker;

  final chapter1131 = Chapter(
    id: 'uuid-1131',
    number: 1131.0,
    title: 'The World Burns',
    publishedAt: DateTime(2026, 4, 27),
    mangaDexUrl: 'https://mangadex.org/chapter/uuid-1131',
  );

  setUp(() {
    mockMangaDex = MockMangaDexService();
    mockStorage = MockChapterStorageService();
    mockNotifications = MockNotificationService();

    when(mockNotifications.initialize()).thenAnswer((_) => Future.value());

    worker = WorkerTask(
      mangaDex: mockMangaDex,
      storage: mockStorage,
      notifications: mockNotifications,
    );
  });

  test('notifies and saves when new chapter is found', () async {
    when(mockMangaDex.fetchLatestChapter()).thenAnswer((_) async => chapter1131);
    when(mockStorage.getLastSeenChapter()).thenAnswer((_) async => 1130.0);
    when(mockStorage.saveLastSeenChapter(any)).thenAnswer((_) => Future.value());
    when(mockNotifications.showNewChapterNotification(any)).thenAnswer((_) => Future.value());

    final result = await worker.execute();

    expect(result, isTrue);
    verify(mockNotifications.showNewChapterNotification(any)).called(1);
    verify(mockStorage.saveLastSeenChapter(1131.0)).called(1);
  });

  test('does not notify when chapter is unchanged', () async {
    when(mockMangaDex.fetchLatestChapter()).thenAnswer((_) async => chapter1131);
    when(mockStorage.getLastSeenChapter()).thenAnswer((_) async => 1131.0);

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockNotifications.showNewChapterNotification(any));
    verifyNever(mockStorage.saveLastSeenChapter(any));
  });

  test('returns true and skips notification when API returns null', () async {
    when(mockMangaDex.fetchLatestChapter()).thenAnswer((_) async => null);

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockNotifications.showNewChapterNotification(any));
    verifyNever(mockStorage.saveLastSeenChapter(any));
  });

  test('returns false when an unexpected exception is thrown', () async {
    when(mockMangaDex.fetchLatestChapter()).thenThrow(Exception('Unexpected'));

    final result = await worker.execute();

    expect(result, isFalse);
  });
}
