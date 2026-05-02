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

  group('searchManga', () {
    final searchResponse = jsonEncode({
      'data': [
        {
          'id': 'manga-1',
          'attributes': {
            'title': {'en': 'One Piece'},
            'altTitles': <Map<String, dynamic>>[],
          },
          'relationships': [
            {
              'id': 'cover-1',
              'type': 'cover_art',
              'attributes': {'fileName': 'cover.jpg'},
            }
          ],
        },
        {
          'id': 'manga-2',
          'attributes': {
            'title': {'ja': 'チェンソーマン'},
            'altTitles': [
              {'en': 'Chainsaw Man'}
            ],
          },
          'relationships': <Map<String, dynamic>>[],
        }
      ]
    });

    test('returns parsed manga list with cover URLs on 200', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(searchResponse, 200, headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      final results = await service.searchManga('one piece');

      expect(results, hasLength(2));
      expect(results[0].id, 'manga-1');
      expect(results[0].title, 'One Piece');
      expect(results[0].coverUrl,
          'https://uploads.mangadex.org/covers/manga-1/cover.jpg.512.jpg');
      expect(results[1].title, 'Chainsaw Man');
      expect(results[1].coverUrl, isNull);
    });

    test('returns empty list on empty query without hitting the network',
        () async {
      final results = await service.searchManga('   ');
      expect(results, isEmpty);
      verifyNever(mockClient.get(any, headers: anyNamed('headers')));
    });

    test('returns empty list on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.searchManga('x'), isEmpty);
    });

    test('returns empty list on malformed JSON', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('not json', 200),
      );
      expect(await service.searchManga('x'), isEmpty);
    });

    test('returns empty list on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('No internet'));
      expect(await service.searchManga('x'), isEmpty);
    });

    test('forwards sort order to the query string', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(searchResponse, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      await service.searchManga('one piece', sort: MangaSortOrder.highestRated);

      final captured = verify(mockClient.get(captureAny, headers: anyNamed('headers')))
          .captured
          .first as Uri;
      expect(captured.toString(), contains('rating'));
      expect(captured.toString(), isNot(contains('relevance')));
    });
  });

  group('fetchLatestChaptersFor', () {
    Map<String, dynamic> chapterItem({
      required String id,
      required String mangaId,
      required String chapter,
      String title = '',
    }) {
      return {
        'id': id,
        'attributes': {
          'chapter': chapter,
          'title': title,
          'publishAt': '2026-04-27T07:00:00+00:00',
          'translatedLanguage': 'en',
        },
        'relationships': [
          {'id': mangaId, 'type': 'manga'}
        ],
      };
    }

    test('groups chapters by manga and picks highest chapter number', () async {
      final body = jsonEncode({
        'data': [
          chapterItem(id: 'c1', mangaId: 'A', chapter: '100'),
          chapterItem(id: 'c2', mangaId: 'A', chapter: '101'),
          chapterItem(id: 'c3', mangaId: 'B', chapter: '5'),
        ],
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200),
      );

      final result = await service.fetchLatestChaptersFor(['A', 'B']);

      expect(result.keys, containsAll(['A', 'B']));
      expect(result['A']!.number, 101.0);
      expect(result['A']!.id, 'c2');
      expect(result['B']!.number, 5.0);
    });

    test('returns empty map on empty input without hitting the network',
        () async {
      final result = await service.fetchLatestChaptersFor([]);
      expect(result, isEmpty);
      verifyNever(mockClient.get(any, headers: anyNamed('headers')));
    });

    test('returns empty map on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.fetchLatestChaptersFor(['A']), isEmpty);
    });

    test('returns empty map on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('No internet'));
      expect(await service.fetchLatestChaptersFor(['A']), isEmpty);
    });

    test('skips chapters with no manga relationship', () async {
      final body = jsonEncode({
        'data': [
          {
            'id': 'orphan',
            'attributes': {
              'chapter': '1',
              'title': '',
              'publishAt': '2026-04-27T07:00:00+00:00',
            },
            'relationships': <Map<String, dynamic>>[],
          },
          chapterItem(id: 'c1', mangaId: 'A', chapter: '10'),
        ],
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200),
      );

      final result = await service.fetchLatestChaptersFor(['A']);
      expect(result.keys, ['A']);
      expect(result['A']!.number, 10.0);
    });
  });

  group('fetchPopularManga', () {
    final popularResponse = jsonEncode({
      'data': [
        {
          'id': 'manga-1',
          'attributes': {
            'title': {'en': 'One Piece'},
            'altTitles': <Map<String, dynamic>>[],
          },
          'relationships': [
            {
              'id': 'cover-1',
              'type': 'cover_art',
              'attributes': {'fileName': 'cover.jpg'},
            }
          ],
        },
      ]
    });

    test('returns parsed list on 200', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(popularResponse, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      final results = await service.fetchPopularManga();

      expect(results, hasLength(1));
      expect(results[0].id, 'manga-1');
      expect(results[0].title, 'One Piece');
      expect(results[0].coverUrl,
          'https://uploads.mangadex.org/covers/manga-1/cover.jpg.512.jpg');
    });

    test('returns empty list on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.fetchPopularManga(), isEmpty);
    });

    test('returns empty list on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('No internet'));
      expect(await service.fetchPopularManga(), isEmpty);
    });

    test('request uses followedCount order without a title param', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(popularResponse, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      await service.fetchPopularManga();

      final captured = verify(mockClient.get(captureAny, headers: anyNamed('headers')))
          .captured
          .first as Uri;
      expect(captured.toString(), contains('followedCount'));
      expect(captured.toString(), isNot(contains('title=')));
    });
  });

  group('fetchAvailableLanguages', () {
    test('returns language codes from availableTranslatedLanguages', () async {
      final body = jsonEncode({
        'data': {
          'id': 'manga-1',
          'type': 'manga',
          'attributes': {
            'availableTranslatedLanguages': ['en', 'fr', 'pt-br'],
          },
        },
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      final result = await service.fetchAvailableLanguages('manga-1');
      expect(result, ['en', 'fr', 'pt-br']);
    });

    test('returns empty list on HTTP 500', () async {
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response('boom', 500),
      );
      expect(await service.fetchAvailableLanguages('manga-1'), isEmpty);
    });

    test('returns empty list on network exception', () async {
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenThrow(Exception('No internet'));
      expect(await service.fetchAvailableLanguages('manga-1'), isEmpty);
    });

    test('does not include title query param in request URL', () async {
      final body = jsonEncode({
        'data': {
          'id': 'manga-1',
          'type': 'manga',
          'attributes': {'availableTranslatedLanguages': <String>[]},
        },
      });
      when(mockClient.get(any, headers: anyNamed('headers'))).thenAnswer(
        (_) async => http.Response(body, 200,
            headers: {'content-type': 'application/json; charset=utf-8'}),
      );

      await service.fetchAvailableLanguages('manga-1');

      final captured = verify(mockClient.get(captureAny, headers: anyNamed('headers')))
          .captured
          .first as Uri;
      expect(captured.path, contains('manga-1'));
      expect(captured.query, isEmpty);
    });
  });

  group('Chapter.isNewerThan', () {
    test('returns true when chapter number is higher', () {
      final chapter = Chapter(
        id: 'x',
        mangaId: 'm',
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
        mangaId: 'm',
        number: 1131.0,
        title: '',
        publishedAt: DateTime.now(),
        mangaDexUrl: '',
      );
      expect(chapter.isNewerThan(1131.0), isFalse);
    });
  });
}
