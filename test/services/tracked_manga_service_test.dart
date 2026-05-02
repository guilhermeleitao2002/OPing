import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:oping/models/manga.dart';
import 'package:oping/services/tracked_manga_service.dart';

void main() {
  late TrackedMangaService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = TrackedMangaService();
  });

  test('returns empty list before any data has been written', () async {
    expect(await service.getAll(), isEmpty);
  });

  test('add inserts a new tracked entry with lastSeenChapter 0', () async {
    await service.add(const Manga(id: 'a', title: 'Alpha'));
    final all = await service.getAll();
    expect(all, hasLength(1));
    expect(all.first.id, 'a');
    expect(all.first.title, 'Alpha');
    expect(all.first.lastSeenChapter, 0.0);
  });

  test('add is idempotent for the same id', () async {
    await service.add(const Manga(id: 'a', title: 'Alpha'));
    await service.add(const Manga(id: 'a', title: 'Alpha (renamed)'));
    final all = await service.getAll();
    expect(all, hasLength(1));
    expect(all.first.title, 'Alpha');
  });

  test('updateLastSeen writes new chapter number', () async {
    await service.add(const Manga(id: 'a', title: 'Alpha'));
    await service.updateLastSeen('a', 42.5);
    final all = await service.getAll();
    expect(all.first.lastSeenChapter, 42.5);
  });

  test('updateLastSeen no-ops when manga is not tracked', () async {
    await service.updateLastSeen('ghost', 1.0);
    expect(await service.getAll(), isEmpty);
  });

  test('remove deletes a tracked entry', () async {
    await service.add(const Manga(id: 'a', title: 'Alpha'));
    await service.add(const Manga(id: 'b', title: 'Beta'));
    await service.remove('a');
    final all = await service.getAll();
    expect(all.map((m) => m.id), ['b']);
  });

  test('isTracked reflects current state', () async {
    expect(await service.isTracked('a'), isFalse);
    await service.add(const Manga(id: 'a', title: 'Alpha'));
    expect(await service.isTracked('a'), isTrue);
  });

  test('initializeIfMissing writes empty list only when key absent', () async {
    await service.initializeIfMissing();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(TrackedMangaService.storageKey), '[]');

    await service.add(const Manga(id: 'a', title: 'Alpha'));
    await service.initializeIfMissing();
    expect(await service.getAll(), hasLength(1));
  });

  test('returns empty list when stored JSON is corrupt', () async {
    SharedPreferences.setMockInitialValues({
      TrackedMangaService.storageKey: 'not json',
    });
    expect(await service.getAll(), isEmpty);
  });
}
