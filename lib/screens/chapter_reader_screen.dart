import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/models/chapter_pages.dart';
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
  final _pageController = PageController();

  ChapterPages? _pages;
  bool _hasError = false;
  int _currentPage = 0;
  bool _showOverlay = true;

  // Tracks which page indices have already had their report fired.
  final Set<int> _reported = {};

  @override
  void initState() {
    super.initState();
    _loadPages();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showOverlay = false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPages() async {
    setState(() { _pages = null; _hasError = false; });
    final pages = await _mangaDex.fetchChapterPages(widget.chapter.id);
    if (!mounted) return;
    setState(() {
      _pages = pages;
      _hasError = pages == null;
    });
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
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.broken_image_outlined,
                size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            const Text('Failed to load chapter.',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            FilledButton(onPressed: _loadPages, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_pages == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
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
              // Image finished loading — fire report once per page index.
              if (_reported.add(index)) {
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
            if (_reported.add(index)) {
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
