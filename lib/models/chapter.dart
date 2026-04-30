class Chapter {
  final String id;
  final double number;
  final String title;
  final DateTime publishedAt;
  final String mangaDexUrl;

  const Chapter({
    required this.id,
    required this.number,
    required this.title,
    required this.publishedAt,
    required this.mangaDexUrl,
  });

  factory Chapter.fromMangaDexJson(Map<String, dynamic> json) {
    final data = json['data'] as List<dynamic>;
    final item = data.first as Map<String, dynamic>;
    final attrs = item['attributes'] as Map<String, dynamic>;
    final id = item['id'] as String;
    final chapterStr = attrs['chapter'] as String? ?? '0';
    final title = attrs['title'] as String? ?? '';
    final publishedAt = DateTime.parse(attrs['publishAt'] as String);

    return Chapter(
      id: id,
      number: double.tryParse(chapterStr) ?? 0.0,
      title: title,
      publishedAt: publishedAt,
      mangaDexUrl: 'https://mangadex.org/chapter/$id',
    );
  }

  bool isNewerThan(double storedChapterNumber) => number > storedChapterNumber;

  String get formattedTitle =>
      title.isNotEmpty ? 'Chapter $number: $title' : 'Chapter $number';
}
