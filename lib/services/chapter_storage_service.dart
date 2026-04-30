import 'package:shared_preferences/shared_preferences.dart';

class ChapterStorageService {
  static const String _lastChapterKey = 'last_seen_chapter_number';
  static const String _lastCheckedKey = 'last_checked_timestamp';

  Future<double> getLastSeenChapter() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_lastChapterKey) ?? 0.0;
  }

  Future<void> saveLastSeenChapter(double chapterNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_lastChapterKey, chapterNumber);
    await prefs.setString(_lastCheckedKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastChecked() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_lastCheckedKey);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }
}
