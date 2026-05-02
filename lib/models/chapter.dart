class Chapter {
  final String id;
  final String mangaId;
  final double number;
  final String title;
  final DateTime publishedAt;
  final String mangaDexUrl;
  final String? externalUrl;

  const Chapter({
    required this.id,
    required this.mangaId,
    required this.number,
    required this.title,
    required this.publishedAt,
    required this.mangaDexUrl,
    this.externalUrl,
  });

  bool get isExternal => externalUrl != null;

  factory Chapter.fromMangaDexJson(Map<String, dynamic> json, {String? mangaId}) {
    final data = json['data'] as List<dynamic>;
    final item = data.first as Map<String, dynamic>;
    return Chapter.fromChapterJsonItem(item, fallbackMangaId: mangaId);
  }

  factory Chapter.fromChapterJsonItem(
    Map<String, dynamic> item, {
    String? fallbackMangaId,
  }) {
    final attrs = item['attributes'] as Map<String, dynamic>;
    final id = item['id'] as String;
    final chapterStr = attrs['chapter'] as String? ?? '0';
    final title = attrs['title'] as String? ?? '';
    final publishedAt = DateTime.parse(attrs['publishAt'] as String);
    final mangaId = _resolveMangaId(item['relationships']) ?? fallbackMangaId ?? '';

    final rawExternal = attrs['externalUrl'] as String?;

    return Chapter(
      id: id,
      mangaId: mangaId,
      number: double.tryParse(chapterStr) ?? 0.0,
      title: title,
      publishedAt: publishedAt,
      mangaDexUrl: 'https://mangadex.org/chapter/$id',
      externalUrl: (rawExternal?.isNotEmpty ?? false) ? rawExternal : null,
    );
  }

  static String? _resolveMangaId(dynamic relationships) {
    if (relationships is! List) return null;
    for (final rel in relationships) {
      if (rel is Map<String, dynamic> && rel['type'] == 'manga') {
        final id = rel['id'];
        if (id is String) return id;
      }
    }
    return null;
  }

  bool isNewerThan(double storedChapterNumber) => number > storedChapterNumber;

  String get formattedTitle =>
      title.isNotEmpty ? 'Chapter $number: $title' : 'Chapter $number';
}
