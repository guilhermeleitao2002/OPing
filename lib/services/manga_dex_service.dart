import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:oping/models/chapter.dart';
import 'package:oping/models/manga.dart';

class MangaDexService {
  static const String baseUrl = 'https://api.mangadex.org';
  static const String onePieceMangaId = 'a1c7c817-4e59-43b7-9365-09675a149a6f';
  static const String _userAgent = 'OPing/1.0 (guilhermeleitao0202@gmail.com)';
  static const Duration _timeout = Duration(seconds: 10);
  static const int _chapterBatchSize = 100;

  final http.Client _client;

  MangaDexService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    try {
      final params = <String, List<String>>{
        'title': [trimmed],
        'limit': [limit.clamp(1, 100).toString()],
        'order[relevance]': ['desc'],
        'contentRating[]': ['safe', 'suggestive', 'erotica'],
        'includes[]': ['cover_art'],
      };
      final response = await _get('/manga', params);
      if (response == null) return [];

      final data = response['data'];
      if (data is! List) return [];

      final results = <Manga>[];
      for (final item in data) {
        if (item is! Map<String, dynamic>) continue;
        try {
          results.add(Manga.fromMangaDexJson(item));
        } catch (_) {
          // Skip malformed items rather than failing the whole search.
        }
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, Chapter>> fetchLatestChaptersFor(
    List<String> mangaIds,
  ) async {
    if (mangaIds.isEmpty) return {};

    final result = <String, Chapter>{};
    for (var i = 0; i < mangaIds.length; i += _chapterBatchSize) {
      final end = (i + _chapterBatchSize).clamp(0, mangaIds.length);
      final batch = mangaIds.sublist(i, end);
      final batchResult = await _fetchChapterBatch(batch);
      result.addAll(batchResult);
    }
    return result;
  }

  Future<Map<String, Chapter>> _fetchChapterBatch(List<String> mangaIds) async {
    try {
      final params = <String, List<String>>{
        'manga[]': mangaIds,
        'translatedLanguage[]': ['en'],
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

  Future<Map<String, dynamic>?> _get(
    String path,
    Map<String, List<String>> params,
  ) async {
    final query = _encodeQuery(params);
    final uri = Uri.parse('$baseUrl$path?$query');
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
