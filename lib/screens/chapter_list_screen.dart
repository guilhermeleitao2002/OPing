import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oping/models/app_language.dart';
import 'package:oping/models/chapter.dart';
import 'package:oping/models/chapter_source.dart';
import 'package:oping/screens/chapter_reader_screen.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/comick_service.dart';
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
  final _comick = ComickService();
  final _storage = ChapterStorageService();
  final _scrollController = ScrollController();

  final List<Chapter> _chapters = [];
  int _total = 0;
  bool _isInitialLoading = true;
  bool _isLoadingMore = false;
  bool _hasInitialError = false;

  String _preferredLanguage = 'en';
  String? _overrideLanguage;
  // Cached once per screen session; not re-fetched on chip selection.
  List<String> _availableLanguages = [];

  ({String hid, String slug})? _comickInfo;
  int _comickPage = 1;
  ChapterSource _activeSource = ChapterSource.mangadex;

  String get _effectiveLanguage => _overrideLanguage ?? _preferredLanguage;
  bool get _hasMore => _chapters.length < _total;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    _preferredLanguage = await _storage.getPreferredLanguage();
    _loadInitial();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  /// [clearAvailable]: pass true to flush the cached available-language list
  /// (used by the Retry button after a hard error).
  Future<void> _loadInitial({bool clearAvailable = false}) async {
    setState(() {
      _isInitialLoading = true;
      _hasInitialError = false;
      _chapters.clear();
      _total = 0;
      _comickPage = 1;
      _activeSource = ChapterSource.mangadex;
      if (clearAvailable) _availableLanguages = [];
    });

    // ── 1. Try MangaDex ──────────────────────────────────────────────────────
    final mdResult = await _mangaDex.fetchChapterList(
      widget.manga.id,
      offset: 0,
      limit: _pageSize,
      language: _effectiveLanguage,
    );
    if (!mounted) return;

    if (mdResult == null) {
      // Network/API error — show error state (don't fall through to ComicK).
      setState(() { _isInitialLoading = false; _hasInitialError = true; });
      return;
    }

    if (mdResult.total > 0) {
      setState(() {
        _isInitialLoading = false;
        _chapters.addAll(mdResult.chapters);
        _total = mdResult.total;
        _activeSource = ChapterSource.mangadex;
      });
      return;
    }

    // ── 2. MangaDex has 0 chapters → try ComicK ──────────────────────────────
    _comickInfo ??= await _comick.findComic(widget.manga.title);
    if (!mounted) return;

    if (_comickInfo != null) {
      final ckResult = await _comick.fetchChapterList(
        _comickInfo!.hid,
        slug: _comickInfo!.slug,
        mangaId: widget.manga.id,
        page: 1,
        limit: _pageSize,
        language: _effectiveLanguage,
      );
      if (!mounted) return;

      if (ckResult != null && ckResult.total > 0) {
        setState(() {
          _isInitialLoading = false;
          _chapters.addAll(ckResult.chapters);
          _total = ckResult.total;
          _comickPage = 1;
          _activeSource = ChapterSource.comick;
        });
        return;
      }
    }

    // ── 3. Both sources have 0 chapters → show language picker ───────────────
    if (_availableLanguages.isEmpty) {
      // First time hitting empty for this manga — fetch available languages.
      final langs = await _mangaDex.fetchAvailableLanguages(widget.manga.id);
      if (!mounted) return;
      setState(() {
        _isInitialLoading = false;
        _availableLanguages = langs.where((l) => l != _effectiveLanguage).toList();
      });
    } else {
      // A chip was tapped and still returned 0 — remove that language from the list.
      setState(() {
        _isInitialLoading = false;
        _availableLanguages =
            _availableLanguages.where((l) => l != _effectiveLanguage).toList();
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    if (_activeSource == ChapterSource.comick && _comickInfo != null) {
      final nextPage = _comickPage + 1;
      final result = await _comick.fetchChapterList(
        _comickInfo!.hid,
        slug: _comickInfo!.slug,
        mangaId: widget.manga.id,
        page: nextPage,
        limit: _pageSize,
        language: _effectiveLanguage,
      );
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        if (result != null) {
          _chapters.addAll(result.chapters);
          _total = result.total;
          _comickPage = nextPage;
        }
      });
    } else {
      final result = await _mangaDex.fetchChapterList(
        widget.manga.id,
        offset: _chapters.length,
        limit: _pageSize,
        language: _effectiveLanguage,
      );
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        if (result != null) {
          _chapters.addAll(result.chapters);
          _total = result.total;
        }
      });
    }
  }

  void _switchLanguage(String code) {
    setState(() => _overrideLanguage = code);
    _loadInitial();
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
                  onPressed: () => _loadInitial(clearAvailable: true),
                  child: const Text('Retry'),
                ),
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
      return _buildEmptyLanguageState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _chapters.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return _buildHeader(theme);
        final idx = i - 1;
        if (idx < _chapters.length) {
          return _ChapterTile(
            chapter: _chapters[idx],
            mangaTitle: widget.manga.title,
          );
        }
        return _isLoadingMore
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              )
            : const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyLanguageState(ThemeData theme) {
    final currentLabel = AppLanguage.labelForCode(_effectiveLanguage);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 48,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              'No $currentLabel chapters found from any source.',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (_availableLanguages.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Available languages:',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outlineVariant),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _availableLanguages.map((code) {
                  return ActionChip(
                    label: Text(AppLanguage.labelForCode(code)),
                    onPressed: () => _switchLanguage(code),
                  );
                }).toList(),
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(
                'The manga may host chapters externally.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.outlineVariant),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _openInBrowser,
              icon: const Icon(Icons.open_in_browser, size: 16),
              label: const Text('View on MangaDex'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final langLabel = AppLanguage.labelForCode(_effectiveLanguage);
    final sourceBadge =
        _activeSource == ChapterSource.comick ? ' · via ComicK' : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Icon(Icons.library_books_rounded,
              size: 15, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            '$_total $langLabel ${_total == 1 ? 'chapter' : 'chapters'}$sourceBadge',
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
