import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oping/models/chapter_source.dart';
import 'package:oping/services/comick_service.dart';

import 'comick_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late ComickService service;

  setUp(() {
    mockClient = MockClient();
    service = ComickService(client: mockClient);
  });

  group('findComic', () {
    test('returns hid and slug from first result on 200', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode([
            {'hid': 'abc123', 'slug': 'one-piece', 'title': 'One Piece'},
            {'hid': 'def456', 'slug': 'other', 'title': 'Other'},
          ]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final result = await service.findComic('One Piece');

      expect(result, isNotNull);
      expect(result!.hid, 'abc123');
      expect(result.slug, 'one-piece');
    });

    test('returns null on empty results array', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(jsonEncode([]), 200),
      );

      expect(await service.findComic('Unknown Manga'), isNull);
    });

    test('returns null on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.findComic('test'), isNull);
    });

    test('returns null on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('No internet'));
      expect(await service.findComic('test'), isNull);
    });

    test('caches result and avoids second network call', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode([{'hid': 'abc', 'slug': 'slug', 'title': 'Test'}]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      await service.findComic('Test Manga');
      await service.findComic('test manga'); // same title, different case

      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);
    });
  });

  group('fetchChapterList', () {
    Map<String, dynamic> chapterItem({
      required String hid,
      required String chap,
      String title = '',
      String lang = 'en',
      String updatedAt = '2026-04-27T07:00:00Z',
    }) =>
        {
          'id': 123,
          'hid': hid,
          'chap': chap,
          'title': title,
          'lang': lang,
          'updated_at': updatedAt,
        };

    test('parses chapter fields correctly', () async {
      final body = jsonEncode({
        'chapters': [
          chapterItem(hid: 'ch1', chap: '100', title: 'The Fight'),
          chapterItem(hid: 'ch2', chap: '101'),
        ],
        'total': 200,
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200),
      );

      final result = await service.fetchChapterList(
        'hid123',
        mangaId: 'manga-uuid',
        language: 'en',
      );

      expect(result, isNotNull);
      expect(result!.total, 200);
      expect(result.chapters, hasLength(2));
      expect(result.chapters[0].id, 'ch1');
      expect(result.chapters[0].number, 100.0);
      expect(result.chapters[0].title, 'The Fight');
      expect(result.chapters[0].mangaId, 'manga-uuid');
      expect(result.chapters[0].source, ChapterSource.comick);
    });

    test('maps es-la to es in the request URL', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'chapters': [], 'total': 0}),
          200,
        ),
      );

      await service.fetchChapterList('hid123', mangaId: 'm', language: 'es-la');

      final uri = verify(
        mockClient.get(captureAny, headers: anyNamed('headers')),
      ).captured.first as Uri;
      expect(uri.toString(), contains('lang=es'));
      expect(uri.toString(), isNot(contains('lang=es-la')));
    });

    test('maps pt-br to pt in the request URL', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(
          jsonEncode({'chapters': [], 'total': 0}),
          200,
        ),
      );

      await service.fetchChapterList('hid123', mangaId: 'm', language: 'pt-br');

      final uri = verify(
        mockClient.get(captureAny, headers: anyNamed('headers')),
      ).captured.first as Uri;
      expect(uri.toString(), contains('lang=pt'));
      expect(uri.toString(), isNot(contains('lang=pt-br')));
    });

    test('returns null on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.fetchChapterList('hid', mangaId: 'm'), isNull);
    });

    test('returns null on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('timeout'));
      expect(await service.fetchChapterList('hid', mangaId: 'm'), isNull);
    });
  });

  group('fetchChapterPages', () {
    test('builds absolute image URLs from b2key', () async {
      final body = jsonEncode({
        'chapter': {
          'hid': 'ch1',
          'images': [
            {'b2key': 'path/to/001.jpg', 'h': 1200, 'w': 850},
            {'b2key': 'path/to/002.jpg', 'h': 1200, 'w': 850},
          ],
        },
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200),
      );

      final pages = await service.fetchChapterPages('ch1');

      expect(pages, isNotNull);
      expect(pages!.count, 2);
      expect(pages.pageUrl(0), 'https://meo.comick.pictures/path/to/001.jpg');
      expect(pages.pageUrl(1), 'https://meo.comick.pictures/path/to/002.jpg');
    });

    test('returns null on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.fetchChapterPages('ch1'), isNull);
    });

    test('returns null on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('timeout'));
      expect(await service.fetchChapterPages('ch1'), isNull);
    });
  });
}
