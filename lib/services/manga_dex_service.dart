import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oping/models/chapter.dart';

class MangaDexService {
  static const String _baseUrl = 'https://api.mangadex.org';
  static const String _onePieceMangaId = 'a1c7c817-4e59-43b7-9365-09675a149a6f';

  final http.Client _client;

  MangaDexService({http.Client? client}) : _client = client ?? http.Client();

  Future<Chapter?> fetchLatestChapter() async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/manga/$_onePieceMangaId/feed'
        '?translatedLanguage[]=en'
        '&order[chapter]=desc'
        '&limit=1'
        '&contentRating[]=safe'
        '&contentRating[]=suggestive',
      );

      final response = await _client.get(
        uri,
        headers: {'User-Agent': 'OPing/1.0 (guilhermeleitao0202@gmail.com)'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final data = json['data'] as List<dynamic>?;
      if (data == null || data.isEmpty) return null;

      return Chapter.fromMangaDexJson(json);
    } catch (_) {
      return null;
    }
  }
}
