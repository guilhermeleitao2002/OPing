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

  int get count => data.length;

  String pageUrl(int index, {bool dataSaver = false}) {
    if (dataSaver && this.dataSaver.length > index) {
      return '$baseUrl/data-saver/$hash/${this.dataSaver[index]}';
    }
    return '$baseUrl/data/$hash/${data[index]}';
  }
}
