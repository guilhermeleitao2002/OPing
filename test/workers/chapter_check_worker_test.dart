import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/notification_service.dart';
import 'package:oping/services/tracked_manga_service.dart';
import 'package:oping/workers/chapter_check_worker.dart';

import 'chapter_check_worker_test.mocks.dart';

@GenerateMocks([
  MangaDexService,
  ChapterStorageService,
  NotificationService,
  TrackedMangaService,
])
void main() {
  late MockMangaDexService mockMangaDex;
  late MockChapterStorageService mockStorage;
  late MockTrackedMangaService mockTracked;
  late MockNotificationService mockNotifications;
  late WorkerTask worker;

  Chapter makeChapter(String mangaId, double number) => Chapter(
        id: 'ch-$mangaId-$number',
        mangaId: mangaId,
        number: number,
        title: '',
        publishedAt: DateTime(2026, 4, 27),
        mangaDexUrl: 'https://mangadex.org/chapter/ch-$mangaId-$number',
      );

  TrackedManga makeTracked(String id, double lastSeen) => TrackedManga(
        id: id,
        title: 'Manga $id',
        lastSeenChapter: lastSeen,
      );

  setUp(() {
    mockMangaDex = MockMangaDexService();
    mockStorage = MockChapterStorageService();
    mockTracked = MockTrackedMangaService();
    mockNotifications = MockNotificationService();

    when(mockNotifications.initialize()).thenAnswer((_) => Future.value());
    when(mockStorage.markChecked()).thenAnswer((_) => Future.value());
    when(mockStorage.getPreferredLanguage()).thenAnswer((_) async => 'en');
    when(mockTracked.updateLastSeen(any, any)).thenAnswer((_) => Future.value());
    when(mockNotifications.showNewChapterNotification(any, any))
        .thenAnswer((_) => Future.value());
    when(mockNotifications.showCombinedNewChaptersNotification(any))
        .thenAnswer((_) => Future.value());

    worker = WorkerTask(
      mangaDex: mockMangaDex,
      storage: mockStorage,
      tracked: mockTracked,
      notifications: mockNotifications,
    );
  });

  test('returns true and sends no notifications when nothing is tracked',
      () async {
    when(mockTracked.getAll()).thenAnswer((_) async => []);

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockMangaDex.fetchLatestChaptersFor(any));
    verifyNever(mockNotifications.showNewChapterNotification(any, any));
    verifyNever(mockNotifications.showCombinedNewChaptersNotification(any));
    verify(mockStorage.markChecked()).called(1);
  });

  test('shows single notification and updates lastSeen for one new chapter',
      () async {
    final tracked = [makeTracked('A', 100), makeTracked('B', 5)];
    when(mockTracked.getAll()).thenAnswer((_) async => tracked);
    when(mockMangaDex.fetchLatestChaptersFor(any)).thenAnswer((_) async => {
          'A': makeChapter('A', 101),
          'B': makeChapter('B', 5),
        });

    final result = await worker.execute();

    expect(result, isTrue);
    verify(mockNotifications.showNewChapterNotification(any, any)).called(1);
    verifyNever(mockNotifications.showCombinedNewChaptersNotification(any));
    verify(mockTracked.updateLastSeen('A', 101)).called(1);
    verifyNever(mockTracked.updateLastSeen('B', any));
  });

  test('shows combined notification for multiple updates', () async {
    final tracked = [makeTracked('A', 100), makeTracked('B', 5)];
    when(mockTracked.getAll()).thenAnswer((_) async => tracked);
    when(mockMangaDex.fetchLatestChaptersFor(any)).thenAnswer((_) async => {
          'A': makeChapter('A', 101),
          'B': makeChapter('B', 6),
        });

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockNotifications.showNewChapterNotification(any, any));
    final captured = verify(
      mockNotifications.showCombinedNewChaptersNotification(captureAny),
    ).captured.single as List<MangaUpdate>;
    expect(captured.map((u) => u.manga.id), ['A', 'B']);
    verify(mockTracked.updateLastSeen('A', 101)).called(1);
    verify(mockTracked.updateLastSeen('B', 6)).called(1);
  });

  test('does not notify when no chapter is newer than stored', () async {
    final tracked = [makeTracked('A', 100)];
    when(mockTracked.getAll()).thenAnswer((_) async => tracked);
    when(mockMangaDex.fetchLatestChaptersFor(any)).thenAnswer((_) async => {
          'A': makeChapter('A', 100),
        });

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockNotifications.showNewChapterNotification(any, any));
    verifyNever(mockTracked.updateLastSeen(any, any));
    verify(mockStorage.markChecked()).called(1);
  });

  test('returns true and changes nothing when API returns empty map', () async {
    final tracked = [makeTracked('A', 100)];
    when(mockTracked.getAll()).thenAnswer((_) async => tracked);
    when(mockMangaDex.fetchLatestChaptersFor(any))
        .thenAnswer((_) async => <String, Chapter>{});

    final result = await worker.execute();

    expect(result, isTrue);
    verifyNever(mockNotifications.showNewChapterNotification(any, any));
    verifyNever(mockTracked.updateLastSeen(any, any));
    verify(mockStorage.markChecked()).called(1);
  });

  test('returns false on unexpected exception', () async {
    when(mockTracked.getAll()).thenThrow(Exception('boom'));
    expect(await worker.execute(), isFalse);
  });
}
