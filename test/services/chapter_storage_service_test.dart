import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oping/services/chapter_storage_service.dart';

void main() {
  late ChapterStorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = ChapterStorageService();
  });

  group('getLastChecked / markChecked', () {
    test('returns null when never marked', () async {
      expect(await service.getLastChecked(), isNull);
    });

    test('returns a timestamp close to now after markChecked', () async {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      await service.markChecked();
      final after = DateTime.now().add(const Duration(seconds: 1));

      final result = await service.getLastChecked();
      expect(result, isNotNull);
      expect(result!.isAfter(before), isTrue);
      expect(result.isBefore(after), isTrue);
    });
  });

  group('polling toggle', () {
    test('defaults to enabled', () async {
      expect(await service.getPollingEnabled(), isTrue);
    });

    test('persists user toggle', () async {
      await service.savePollingEnabled(false);
      expect(await service.getPollingEnabled(), isFalse);
      await service.savePollingEnabled(true);
      expect(await service.getPollingEnabled(), isTrue);
    });
  });
}
