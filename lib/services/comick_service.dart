import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:oping/models/chapter.dart';
import 'package:oping/models/chapter_pages.dart';
import 'package:oping/models/chapter_source.dart';

class ComickService {
  static const String _base = 'https://api.comick.fun';
  static const String _imgBase = 'https://meo.comick.pictures';
  static const String _userAgent = 'OPing/1.0 (guilhermeleitao0202@gmail.com)';
  static const Duration _timeout = Duration(seconds: 10);

  // Session-level cache: mangaTitle.toLowerCase() → ({hid, slug}) or null
  final _comicCache = <String, ({String hid, String slug})?>{};

  final http.Client _client;

  ComickService({http.Client? client}) : _client = client ?? http.Client();

  // Returns the ComicK HID for a manga, looked up by title. Null on error/no match.
  Future<({String hid, String slug})?> findComic(String mangaTitle) async {
    final key = mangaTitle.toLowerCase().trim();
    if (_comicCache.containsKey(key)) return _comicCache[key];
    try {
      final uri = Uri.parse('$_base/search?q=${Uri.encodeQueryComponent(key)}&limit=5&type=comic');
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200) {
        _comicCache[key] = null;
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! List || decoded.isEmpty) {
        _comicCache[key] = null;
        return null;
      }
      final first = decoded[0] as Map<String, dynamic>;
      final hid = first['hid'] as String?;
      final slug = (first['slug'] as String?) ?? '-';
      if (hid == null) {
        _comicCache[key] = null;
        return null;
      }
      final result = (hid: hid, slug: slug);
      _comicCache[key] = result;
      return result;
    } catch (_) {
      return null;
    }
  }

  Future<({List<Chapter> chapters, int total})?> fetchChapterList(
    String comicHid, {
    String slug = '-',
    required String mangaId,
    int page = 1,
    int limit = 100,
    String language = 'en',
  }) async {
    try {
      final lang = _toComickLang(language);
      final uri = Uri.parse(
        '$_base/comic/$comicHid/chapters'
        '?lang=$lang&limit=$limit&page=$page&chap-order=1',
      );
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final total = (decoded['total'] as num?)?.toInt() ?? 0;
      final rawChapters = decoded['chapters'] as List<dynamic>?;
      if (rawChapters == null) return null;
      final chapters = <Chapter>[];
      for (final item in rawChapters) {
        if (item is! Map<String, dynamic>) continue;
        try {
          chapters.add(_parseChapter(item, mangaId: mangaId, slug: slug, lang: lang));
        } catch (_) {}
      }
      return (chapters: chapters, total: total);
    } catch (_) {
      return null;
    }
  }

  Future<ChapterPages?> fetchChapterPages(String chapterHid) async {
    try {
      final uri = Uri.parse('$_base/chapter/$chapterHid');
      final response = await _client
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final chapter = decoded['chapter'] as Map<String, dynamic>?;
      if (chapter == null) return null;
      final images = chapter['images'] as List<dynamic>?;
      if (images == null) return null;
      final urls = images
          .whereType<Map<String, dynamic>>()
          .map((img) => '$_imgBase/${img['b2key']}')
          .where((url) => url.isNotEmpty)
          .toList();
      return ChapterPages.fromAbsoluteUrls(urls);
    } catch (_) {
      return null;
    }
  }

  Chapter _parseChapter(
    Map<String, dynamic> item, {
    required String mangaId,
    required String slug,
    required String lang,
  }) {
    final hid = item['hid'] as String;
    final chap = item['chap'] as String? ?? '0';
    final title = (item['title'] as String?) ?? '';
    final updatedAt = item['updated_at'] as String? ?? item['created_at'] as String?;
    final publishedAt =
        updatedAt != null ? DateTime.tryParse(updatedAt) ?? DateTime.now() : DateTime.now();

    return Chapter(
      id: hid,
      mangaId: mangaId,
      number: double.tryParse(chap) ?? 0.0,
      title: title,
      publishedAt: publishedAt,
      mangaDexUrl: 'https://comick.io/comic/$slug/$hid-chapter-$chap-$lang',
      externalUrl: null,
      source: ChapterSource.comick,
    );
  }

  static String _toComickLang(String mangaDexCode) => switch (mangaDexCode) {
        'es-la' => 'es',
        'pt-br' => 'pt',
        _ => mangaDexCode,
      };
}
