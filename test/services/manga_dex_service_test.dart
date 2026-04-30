import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oping/models/chapter.dart';
import 'package:oping/services/manga_dex_service.dart';

import 'manga_dex_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late MangaDexService service;

  setUp(() {
    mockClient = MockClient();
    service = MangaDexService(client: mockClient);
  });

  final validResponse = jsonEncode({
    'data': [
      {
        'id': 'test-uuid-123',
        'attributes': {
          'chapter': '1131',
          'title': 'The World Burns',
          'publishAt': '2026-04-27T07:00:00+00:00',
          'translatedLanguage': 'en',
        },
      }
    ]
  });

  test('returns Chapter on HTTP 200 with valid JSON', () async {
    when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response(validResponse, 200),
    );

    final chapter = await service.fetchLatestChapter();

    expect(chapter, isNotNull);
    expect(chapter!.number, 1131.0);
    expect(chapter.title, 'The World Burns');
    expect(chapter.id, 'test-uuid-123');
    expect(chapter.mangaDexUrl, 'https://mangadex.org/chapter/test-uuid-123');
  });

  test('returns null on HTTP 500', () async {
    when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response('Internal Server Error', 500),
    );

    final chapter = await service.fetchLatestChapter();
    expect(chapter, isNull);
  });

  test('returns null on malformed JSON', () async {
    when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response('not json at all', 200),
    );

    final chapter = await service.fetchLatestChapter();
    expect(chapter, isNull);
  });

  test('returns null on empty data array', () async {
    when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
      (_) async => http.Response(jsonEncode({'data': []}), 200),
    );

    final chapter = await service.fetchLatestChapter();
    expect(chapter, isNull);
  });

  test('returns null on network exception', () async {
    when(mockClient.get(any, headers: anyNamed('headers'))).thenThrow(
      Exception('No internet'),
    );

    final chapter = await service.fetchLatestChapter();
    expect(chapter, isNull);
  });

  group('Chapter.isNewerThan', () {
    test('returns true when chapter number is higher', () {
      final chapter = Chapter(
        id: 'x',
        number: 1131.0,
        title: '',
        publishedAt: DateTime.now(),
        mangaDexUrl: '',
      );
      expect(chapter.isNewerThan(1130.0), isTrue);
    });

    test('returns false when chapter number is equal', () {
      final chapter = Chapter(
        id: 'x',
        number: 1131.0,
        title: '',
        publishedAt: DateTime.now(),
        mangaDexUrl: '',
      );
      expect(chapter.isNewerThan(1131.0), isFalse);
    });
  });
}
