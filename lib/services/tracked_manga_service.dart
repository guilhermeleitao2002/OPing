import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:oping/models/manga.dart';

class TrackedManga {
  final String id;
  final String title;
  final String? coverUrl;
  final double lastSeenChapter;

  const TrackedManga({
    required this.id,
    required this.title,
    this.coverUrl,
    required this.lastSeenChapter,
  });

  TrackedManga copyWith({
    String? title,
    String? coverUrl,
    double? lastSeenChapter,
  }) =>
      TrackedManga(
        id: id,
        title: title ?? this.title,
        coverUrl: coverUrl ?? this.coverUrl,
        lastSeenChapter: lastSeenChapter ?? this.lastSeenChapter,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'coverUrl': coverUrl,
        'lastSeenChapter': lastSeenChapter,
      };

  factory TrackedManga.fromJson(Map<String, dynamic> json) => TrackedManga(
        id: json['id'] as String,
        title: json['title'] as String,
        coverUrl: json['coverUrl'] as String?,
        lastSeenChapter: (json['lastSeenChapter'] as num?)?.toDouble() ?? 0.0,
      );

  factory TrackedManga.fromManga(Manga manga, {double lastSeenChapter = 0.0}) =>
      TrackedManga(
        id: manga.id,
        title: manga.title,
        coverUrl: manga.coverUrl,
        lastSeenChapter: lastSeenChapter,
      );
}

class TrackedMangaService {
  static const String storageKey = 'tracked_manga';

  Future<List<TrackedManga>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(TrackedManga.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isTracked(String mangaId) async {
    final all = await getAll();
    return all.any((m) => m.id == mangaId);
  }

  Future<void> add(Manga manga) async {
    final all = await getAll();
    if (all.any((m) => m.id == manga.id)) return;
    all.add(TrackedManga.fromManga(manga));
    await _saveAll(all);
  }

  Future<void> remove(String mangaId) async {
    final all = await getAll();
    all.removeWhere((m) => m.id == mangaId);
    await _saveAll(all);
  }

  Future<void> updateLastSeen(String mangaId, double chapterNumber) async {
    final all = await getAll();
    final index = all.indexWhere((m) => m.id == mangaId);
    if (index == -1) return;
    all[index] = all[index].copyWith(lastSeenChapter: chapterNumber);
    await _saveAll(all);
  }

  Future<void> initializeIfMissing() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(storageKey)) return;
    await prefs.setString(storageKey, jsonEncode(<Map<String, dynamic>>[]));
  }

  Future<void> _saveAll(List<TrackedManga> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      storageKey,
      jsonEncode(list.map((m) => m.toJson()).toList()),
    );
  }
}
