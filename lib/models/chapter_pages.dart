class ChapterPages {
  final String baseUrl;
  final String hash;
  final List<String> data;
  final List<String> dataSaver;

  const ChapterPages({
    required this.baseUrl,
    required this.hash,
    required this.data,
    required this.dataSaver,
  });

  factory ChapterPages.fromJson(Map<String, dynamic> json) {
    final chapter = json['chapter'] as Map<String, dynamic>;
    return ChapterPages(
      baseUrl: json['baseUrl'] as String,
      hash: chapter['hash'] as String,
      data: List<String>.from(chapter['data'] as List),
      dataSaver: List<String>.from(chapter['dataSaver'] as List),
    );
  }

  // For sources that provide complete image URLs (e.g. ComicK).
  factory ChapterPages.fromAbsoluteUrls(List<String> urls) => ChapterPages(
        baseUrl: '',
        hash: '',
        data: List<String>.from(urls),
        dataSaver: List<String>.from(urls),
      );

  int get count => data.length;

  String pageUrl(int index, {bool dataSaver = false}) {
    final item = dataSaver && this.dataSaver.length > index
        ? this.dataSaver[index]
        : data[index];
    if (item.startsWith('http')) return item;
    final dir = dataSaver ? 'data-saver' : 'data';
    return '$baseUrl/$dir/$hash/$item';
  }
}
