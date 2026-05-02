import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:oping/models/chapter.dart';
import 'package:oping/models/chapter_pages.dart';
import 'package:oping/models/manga.dart';

enum MangaSortOrder { relevance, mostFollowed, highestRated, recentUpload, newest }

extension MangaSortOrderParams on MangaSortOrder {
  Map<String, List<String>> get queryParams => switch (this) {
        MangaSortOrder.relevance    => {'order[relevance]': ['desc']},
        MangaSortOrder.mostFollowed => {'order[followedCount]': ['desc']},
        MangaSortOrder.highestRated => {'order[rating]': ['desc']},
        MangaSortOrder.recentUpload => {'order[latestUploadedChapter]': ['desc']},
        MangaSortOrder.newest       => {'order[createdAt]': ['desc']},
      };
}

class MangaDexService {
  static const String baseUrl = 'https://api.mangadex.org';
  static const String onePieceMangaId = 'a1c7c817-4e59-43b7-9365-09675a149a6f';
  static const String _userAgent = 'OPing/1.0 (guilhermeleitao0202@gmail.com)';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _chapterBatchSize = 100;

  final http.Client _client;

  MangaDexService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Manga>> searchManga(
    String query, {
    int limit = 20,
    MangaSortOrder sort = MangaSortOrder.relevance,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    try {
      final params = <String, List<String>>{
        'title': [trimmed],
        'limit': [limit.clamp(1, 100).toString()],
        ...sort.queryParams,
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
        'includes[]': ['cover_art'],
      };
      final response = await _get('/manga', params);
      if (response == null) return [];

      final data = response['data'];
      if (data is! List) return [];

      return _parseMangaList(data);
    } catch (_) {
      return [];
    }
  }

  Future<List<Manga>> fetchPopularManga({
    int limit = 18,
    MangaSortOrder sort = MangaSortOrder.mostFollowed,
  }) async {
    try {
      final params = <String, List<String>>{
        'limit': [limit.clamp(1, 100).toString()],
        ...sort.queryParams,
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
        'includes[]': ['cover_art'],
        'hasAvailableChapters': ['true'],
      };
      final response = await _get('/manga', params);
      if (response == null) return [];

      final data = response['data'];
      if (data is! List) return [];

      return _parseMangaList(data);
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, Chapter>> fetchLatestChaptersFor(
    List<String> mangaIds, {
    String language = 'en',
  }) async {
    if (mangaIds.isEmpty) return {};

    final result = <String, Chapter>{};
    for (var i = 0; i < mangaIds.length; i += _chapterBatchSize) {
      final end = (i + _chapterBatchSize).clamp(0, mangaIds.length);
      final batch = mangaIds.sublist(i, end);
      final batchResult = await _fetchChapterBatch(batch, language: language);
      result.addAll(batchResult);
    }
    return result;
  }

  Future<Map<String, Chapter>> _fetchChapterBatch(
    List<String> mangaIds, {
    String language = 'en',
  }) async {
    try {
      final params = <String, List<String>>{
        'manga[]': mangaIds,
        'translatedLanguage[]': [language],
        'order[chapter]': ['desc'],
        'contentRating[]': ['safe', 'suggestive'],
        'limit': ['100'],
      };
      final response = await _get('/chapter', params);
      if (response == null) return {};

      final data = response['data'];
      if (data is! List) return {};

      final latest = <String, Chapter>{};
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        try {
          final chapter = Chapter.fromChapterJsonItem(item);
          if (chapter.mangaId.isEmpty) continue;
          final existing = latest[chapter.mangaId];
          if (existing == null || chapter.number > existing.number) {
            latest[chapter.mangaId] = chapter;
          }
        } catch (_) {
          // Skip malformed items rather than failing the entire batch.
        }
      }
      return latest;
    } catch (_) {
      return {};
    }
  }

  Future<List<String>> fetchAvailableLanguages(String mangaId) async {
    try {
      final response = await _get('/manga/$mangaId', {});
      if (response == null) return [];
      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) return [];
      final attrs = data['attributes'] as Map<String, dynamic>?;
      if (attrs == null) return [];
      final langs = attrs['availableTranslatedLanguages'] as List<dynamic>?;
      if (langs == null) return [];
      return langs.whereType<String>().toList();
    } catch (_) {
      return [];
    }
  }

  /// Returns `null` on network/API error so callers can distinguish error
  /// from a genuinely empty chapter list.
  Future<({List<Chapter> chapters, int total})?> fetchChapterList(
    String mangaId, {
    int offset = 0,
    int limit = 100,
    String language = 'en',
  }) async {
    try {
      final params = <String, List<String>>{
        'translatedLanguage[]': [language],
        'order[chapter]': ['desc'],
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
        'limit': [limit.clamp(1, 100).toString()],
        'offset': [offset.toString()],
      };
      final response = await _get('/manga/$mangaId/feed', params);
      if (response == null) return null;
      final data = response['data'];
      if (data is! List) return null;
      final total = (response['total'] as num?)?.toInt() ?? 0;
      final chapters = <Chapter>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        try {
          chapters.add(Chapter.fromChapterJsonItem(item, fallbackMangaId: mangaId));
        } catch (_) {}
      }
      return (chapters: chapters, total: total);
    } catch (_) {
      return null;
    }
  }

  Future<ChapterPages?> fetchChapterPages(String chapterId) async {
    try {
      final uri = Uri.parse('$baseUrl/at-home/server/$chapterId');
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      return ChapterPages.fromJson(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<void> reportPageLoad({
    required String url,
    required bool success,
    int bytes = 0,
    int duration = 0,
    bool cached = false,
  }) async {
    try {
      await _client
          .post(
            Uri.parse('https://api.mangadex.network/report'),
            headers: {
              'Content-Type': 'application/json',
              'User-Agent': _userAgent,
            },
            body: jsonEncode({
              'url': url,
              'success': success,
              'bytes': bytes,
              'duration': duration,
              'cached': cached,
            }),
          )
          .timeout(const Duration(seconds: 5));
    } catch (_) {
      // Best-effort; never fail the caller.
    }
  }

  List<Manga> _parseMangaList(List<dynamic> data) {
    final results = <Manga>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      try {
        results.add(Manga.fromMangaDexJson(item));
      } catch (_) {}
    }
    return results;
  }

  Future<Map<String, dynamic>?> _get(
    String path,
    Map<String, List<String>> params,
  ) async {
    final query = _encodeQuery(params);
    final uri = Uri.parse(query.isEmpty ? '$baseUrl$path' : '$baseUrl$path?$query');
    final response = await _client
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(_timeout);
    if (response.statusCode != 200) return null;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  String _encodeQuery(Map<String, List<String>> params) {
    final parts = <String>[];
    params.forEach((key, values) {
      for (final v in values) {
        parts.add('${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent(v)}');
      }
    });
    return parts.join('&');
  }
}
