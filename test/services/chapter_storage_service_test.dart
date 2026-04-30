import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oping/services/chapter_storage_service.dart';

void main() {
  late ChapterStorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ChapterStorageService();
  });

  group('getLastSeenChapter', () {
    test('returns 0.0 when no chapter has been stored', () async {
      final result = await service.getLastSeenChapter();
      expect(result, 0.0);
    });

    test('returns stored chapter number after save', () async {
      await service.saveLastSeenChapter(1131.0);
      final result = await service.getLastSeenChapter();
      expect(result, 1131.0);
    });

    test('handles decimal chapter numbers', () async {
      await service.saveLastSeenChapter(1130.5);
      final result = await service.getLastSeenChapter();
      expect(result, 1130.5);
    });

    test('overwrites previous value on repeated saves', () async {
      await service.saveLastSeenChapter(1130.0);
      await service.saveLastSeenChapter(1131.0);
      final result = await service.getLastSeenChapter();
      expect(result, 1131.0);
    });
  });

  group('getLastChecked', () {
    test('returns null when never saved', () async {
      final result = await service.getLastChecked();
      expect(result, isNull);
    });

    test('returns a timestamp close to now after save', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await service.saveLastSeenChapter(1131.0);
      final after = DateTime.now().add(const Duration(seconds: 1));

      final result = await service.getLastChecked();
      expect(result, isNotNull);
      expect(result!.isAfter(before), isTrue);
      expect(result.isBefore(after), isTrue);
    });
  });
}
