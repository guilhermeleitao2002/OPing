class Manga {
  final String id;
  final String title;
  final String? coverUrl;

  const Manga({
    required this.id,
    required this.title,
    this.coverUrl,
  });

  factory Manga.fromMangaDexJson(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final attrs = item['attributes'] as Map<String, dynamic>;
    final title = _resolveTitle(attrs);
    final coverUrl = _resolveCoverUrl(id, item['relationships'] as List<dynamic>?);

    return Manga(id: id, title: title, coverUrl: coverUrl);
  }

  static String _resolveTitle(Map<String, dynamic> attrs) {
    final titleMap = attrs['title'] as Map<String, dynamic>?;
    if (titleMap != null) {
      final en = titleMap['en'];
      if (en is String && en.isNotEmpty) return en;
    }
    final altTitles = attrs['altTitles'];
    if (altTitles is List) {
      for (final entry in altTitles) {
        if (entry is Map<String, dynamic>) {
          final en = entry['en'];
          if (en is String && en.isNotEmpty) return en;
        }
      }
    }
    if (titleMap != null) {
      for (final value in titleMap.values) {
        if (value is String && value.isNotEmpty) return value;
      }
    }
    return 'Untitled';
  }

  static String? _resolveCoverUrl(String mangaId, List<dynamic>? relationships) {
    if (relationships == null) return null;
    for (final rel in relationships) {
      if (rel is! Map<String, dynamic>) continue;
      if (rel['type'] != 'cover_art') continue;
      final attrs = rel['attributes'];
      if (attrs is! Map<String, dynamic>) continue;
      final fileName = attrs['fileName'];
      if (fileName is String && fileName.isNotEmpty) {
        return 'https://uploads.mangadex.org/covers/$mangaId/$fileName.512.jpg';
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverUrl': coverUrl,
      };

  factory Manga.fromJson(Map<String, dynamic> json) => Manga(
        id: json['id'] as String,
        title: json['title'] as String,
        coverUrl: json['coverUrl'] as String?,
      );
}
