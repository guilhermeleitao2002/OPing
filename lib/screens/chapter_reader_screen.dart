import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/models/chapter_pages.dart';
import 'package:oping/models/chapter_source.dart';
import 'package:oping/services/comick_service.dart';
import 'package:oping/services/manga_dex_service.dart';

class ChapterReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final String mangaTitle;

  const ChapterReaderScreen({
    super.key,
    required this.chapter,
    required this.mangaTitle,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  final _mangaDex = MangaDexService();
  final _comick = ComickService();
  final _pageController = PageController();

  ChapterPages? _pages;
  bool _hasError = false;
  int _currentPage = 0;
  bool _showOverlay = true;

  // For external chapters: holds the ComicK chapter found as fallback.
  bool _checkingComickFallback = false;
  Chapter? _comickChapter;

  // Tracks which page indices have already had their report fired.
  final Set<int> _reported = {};

  @override
  void initState() {
    super.initState();
    if (widget.chapter.isExternal) {
      _tryComickFallback();
    } else {
      _loadPages();
    }
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _tryComickFallback() async {
    setState(() => _checkingComickFallback = true);
    try {
      final comicInfo = await _comick.findComic(widget.mangaTitle);
      if (comicInfo == null) {
        if (mounted) setState(() => _checkingComickFallback = false);
        return;
      }
      final chapter = await _comick.findChapterByNumber(
        comicInfo.hid,
        slug: comicInfo.slug,
        mangaId: widget.chapter.mangaId,
        chapterNumber: widget.chapter.number,
      );
      if (chapter == null) {
        if (mounted) setState(() => _checkingComickFallback = false);
        return;
      }
      if (mounted) setState(() { _comickChapter = chapter; _checkingComickFallback = false; });
      await _loadPages();
    } catch (_) {
      if (mounted) setState(() => _checkingComickFallback = false);
    }
  }

  Future<void> _loadPages() async {
    setState(() { _pages = null; _hasError = false; });
    final effectiveChapter = _comickChapter ?? widget.chapter;
    final pages = effectiveChapter.source == ChapterSource.comick
        ? await _comick.fetchChapterPages(effectiveChapter.id)
        : await _mangaDex.fetchChapterPages(effectiveChapter.id);
    if (!mounted) return;
    setState(() {
      _pages = pages;
      _hasError = pages == null;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _toggleOverlay() => setState(() => _showOverlay = !_showOverlay);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // External chapter — try ComicK first, only fall back to external link if needed.
    if (widget.chapter.isExternal && _comickChapter == null) {
      if (_checkingComickFallback) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      // ComicK check complete and failed — show external link.
      return _buildExternalView(widget.chapter.externalUrl!);
    }

    final effectiveChapter = _comickChapter ?? widget.chapter;
    final isComick = effectiveChapter.source == ChapterSource.comick;
    final sourceName = isComick ? 'ComicK' : 'MangaDex';
    final sourceUrl = effectiveChapter.mangaDexUrl;

    if (_hasError) {
      return _buildMessage(
        icon: Icons.broken_image_outlined,
        text: 'Failed to load chapter.',
        actions: [
          FilledButton(onPressed: _loadPages, child: const Text('Retry')),
          const SizedBox(width: 12),
          _BrowserButton(
            label: 'Open in $sourceName',
            onPressed: () => _openUrl(sourceUrl),
          ),
        ],
      );
    }

    if (_pages == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }

    // Chapter loaded but has no hosted pages (publisher controls the content).
    if (_pages!.count == 0) {
      return _buildMessage(
        icon: Icons.no_photography_outlined,
        text: 'Pages are not hosted on $sourceName for this chapter.',
        actions: [
          _BrowserButton(
            label: 'Open in $sourceName',
            onPressed: () => _openUrl(sourceUrl),
          ),
        ],
      );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleOverlay,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _pages!.count,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _buildPage(i),
          ),
        ),
        if (_showOverlay) ...[
          _TopBar(mangaTitle: widget.mangaTitle, chapterTitle: widget.chapter.formattedTitle),
          _BottomBar(current: _currentPage + 1, total: _pages!.count),
        ],
      ],
    );
  }

  Widget _buildExternalView(String url) {
    return _buildMessage(
      icon: Icons.launch_rounded,
      text: 'This chapter is hosted on an external site.',
      actions: [
        _BrowserButton(label: 'Open chapter', onPressed: () => _openUrl(url)),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String text,
    required List<Widget> actions,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    final url = _pages!.pageUrl(index);
    return InteractiveViewer(
      minScale: 0.8,
      maxScale: 4.0,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          loadingBuilder: (_, child, progress) {
            if (progress == null) {
              if (_reported.add(index) &&
                  widget.chapter.source == ChapterSource.mangadex) {
                _mangaDex.reportPageLoad(url: url, success: true);
              }
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: progress.expectedTotalBytes != null
                    ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                    : null,
                color: Colors.white,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            if (_reported.add(index) &&
                widget.chapter.source == ChapterSource.mangadex) {
              _mangaDex.reportPageLoad(url: url, success: false);
            }
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: Colors.white38, size: 48),
                  SizedBox(height: 8),
                  Text('Failed to load page',
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _BrowserButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BrowserButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_browser, size: 16, color: Colors.white70),
        label: Text(label, style: const TextStyle(color: Colors.white70)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white30),
        ),
      );
}

// ── Overlay widgets ────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final String mangaTitle;
  final String chapterTitle;

  const _TopBar({required this.mangaTitle, required this.chapterTitle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(mangaTitle,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
                Text(chapterTitle,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int current;
  final int total;

  const _BottomBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              '$current / $total',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ),
    );
  }
}
