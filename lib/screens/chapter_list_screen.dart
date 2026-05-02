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
  static const int _pageSize = 100;

  final _mangaDex = MangaDexService();
  final _scrollController = ScrollController();

  final List<Chapter> _chapters = [];
  int _total = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasInitialError = false;

  bool get _hasMore => _chapters.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _hasInitialError = false;
      _chapters.clear();
      _total = 0;
    });
    final result = await _mangaDex.fetchChapterList(
        widget.manga.id,
        offset: 0,
        limit: _pageSize);
    if (!mounted) return;
    if (result == null) {
      setState(() { _isInitialLoading = false; _hasInitialError = true; });
    } else {
      setState(() {
        _isInitialLoading = false;
        _chapters.addAll(result.chapters);
        _total = result.total;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    final result = await _mangaDex.fetchChapterList(
        widget.manga.id,
        offset: _chapters.length,
        limit: _pageSize);
    if (!mounted) return;
    setState(() {
      _isLoadingMore = false;
      if (result != null) {
        _chapters.addAll(result.chapters);
        _total = result.total;
      }
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
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasInitialError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text('Failed to load chapters.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonal(
                    onPressed: _loadInitial, child: const Text('Retry')),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _openInBrowser,
                  icon: const Icon(Icons.open_in_browser, size: 16),
                  label: const Text('MangaDex'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_chapters.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 48,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text('No English chapters found on MangaDex.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text('The manga may use a different language or host chapters externally.',
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outlineVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('View on MangaDex'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _chapters.length + 1, // +1 for header (or footer loading)
      itemBuilder: (_, i) {
        if (i == 0) return _buildHeader(theme);
        final idx = i - 1;
        if (idx < _chapters.length) {
          return _ChapterTile(
            chapter: _chapters[idx],
            mangaTitle: widget.manga.title,
          );
        }
        // Footer: loading indicator or end-of-list
        return _isLoadingMore
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.library_books_rounded,
              size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$_total English ${_total == 1 ? 'chapter' : 'chapters'}',
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
      trailing: chapter.isExternal
          ? Icon(Icons.open_in_new_rounded,
              size: 16, color: theme.colorScheme.outlineVariant)
          : const Icon(Icons.chevron_right),
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
