import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/screens/chapter_reader_screen.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/tracked_manga_service.dart';

class ChapterListScreen extends StatefulWidget {
  final TrackedManga manga;

  const ChapterListScreen({super.key, required this.manga});

  @override
  State<ChapterListScreen> createState() => _ChapterListScreenState();
}

class _ChapterListScreenState extends State<ChapterListScreen> {
  final _mangaDex = MangaDexService();
  List<Chapter>? _chapters;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() { _chapters = null; _hasError = false; });
    final chapters = await _mangaDex.fetchChapterList(widget.manga.id);
    if (!mounted) return;
    setState(() {
      _chapters = chapters;
      _hasError = chapters.isEmpty;
    });
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse('https://mangadex.org/title/${widget.manga.id}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in MangaDex',
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_chapters == null && !_hasError) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text('No English chapters found.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton.tonal(
                onPressed: _loadChapters, child: const Text('Retry')),
          ],
        ),
      );
    }

    final chapters = _chapters!;
    return ListView.builder(
      itemCount: chapters.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildHeader(theme, chapters.length);
        return _ChapterTile(
          chapter: chapters[i - 1],
          mangaTitle: widget.manga.title,
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.library_books_rounded,
              size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            'Latest $count English chapters',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final Chapter chapter;
  final String mangaTitle;

  const _ChapterTile({required this.chapter, required this.mangaTitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      title: Text(
        chapter.title.isNotEmpty
            ? 'Ch. ${_fmt(chapter.number)}: ${chapter.title}'
            : 'Chapter ${_fmt(chapter.number)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(chapter.publishedAt),
        style: theme.textTheme.bodySmall,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ChapterReaderScreen(
          chapter: chapter,
          mangaTitle: mangaTitle,
        ),
      )),
    );
  }

  static String _fmt(double n) =>
      n == n.truncateToDouble() ? n.toInt().toString() : n.toString();

  static String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
