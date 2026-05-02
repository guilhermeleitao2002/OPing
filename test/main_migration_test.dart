import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oping/main.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/tracked_manga_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeds One Piece when legacy chapter number is present', () async {
    SharedPreferences.setMockInitialValues({
      'last_seen_chapter_number': 1131.0,
    });

    await migrateLegacyOnePieceSubscription();

    final tracked = await TrackedMangaService().getAll();
    expect(tracked, hasLength(1));
    expect(tracked.first.id, MangaDexService.onePieceMangaId);
    expect(tracked.first.title, 'One Piece');
    expect(tracked.first.lastSeenChapter, 1131.0);
  });

  test('writes empty list on fresh install', () async {
    SharedPreferences.setMockInitialValues({});

    await migrateLegacyOnePieceSubscription();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(TrackedMangaService.storageKey), '[]');
    expect(await TrackedMangaService().getAll(), isEmpty);
  });

  test('is a no-op when tracked_manga key already exists', () async {
    SharedPreferences.setMockInitialValues({
      TrackedMangaService.storageKey:
          '[{"id":"x","title":"X","coverUrl":null,"lastSeenChapter":3.0}]',
      'last_seen_chapter_number': 999.0,
    });

    await migrateLegacyOnePieceSubscription();

    final tracked = await TrackedMangaService().getAll();
    expect(tracked, hasLength(1));
    expect(tracked.first.id, 'x');
    expect(tracked.first.lastSeenChapter, 3.0);
  });
}
