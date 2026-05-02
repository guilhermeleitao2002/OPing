import 'dart:async';

import 'package:flutter/material.dart';

import 'package:oping/models/manga.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/tracked_manga_service.dart';

class MangaSearchScreen extends StatefulWidget {
  const MangaSearchScreen({super.key});

  @override
  State<MangaSearchScreen> createState() => _MangaSearchScreenState();
}

class _MangaSearchScreenState extends State<MangaSearchScreen> {
  static const Duration _debounce = Duration(milliseconds: 400);

  final _mangaDex = MangaDexService();
  final _tracked = TrackedMangaService();
  final _controller = TextEditingController();

  Timer? _debounceTimer;
  String _activeQuery = '';
  bool _isSearching = false;
  bool _didChange = false;
  String? _errorMessage;
  List<Manga> _results = [];
  Set<String> _trackedIds = {};

  @override
  void initState() {
    super.initState();
    _loadTrackedIds();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTrackedIds() async {
    final tracked = await _tracked.getAll();
    if (!mounted) return;
    setState(() => _trackedIds = tracked.map((m) => m.id).toSet());
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounce, () => _runSearch(value));
  }

  Future<void> _runSearch(String value) async {
    final trimmed = value.trim();
    if (trimmed == _activeQuery) return;
    _activeQuery = trimmed;

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    final results = await _mangaDex.searchManga(trimmed);
    if (!mounted || _activeQuery != trimmed) return;

    setState(() {
      _isSearching = false;
      _results = results;
      _errorMessage = results.isEmpty ? 'No manga found for "$trimmed"' : null;
    });
  }

  Future<void> _track(Manga manga) async {
    await _tracked.add(manga);
    if (!mounted) return;
    setState(() {
      _trackedIds = {..._trackedIds, manga.id};
      _didChange = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tracking ${manga.title}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) Navigator.of(context).maybePop(_didChange);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add manga'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _controller,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search MangaDex by title',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _onQueryChanged('');
                          },
                        ),
                ),
                onChanged: (v) {
                  setState(() {});
                  _onQueryChanged(v);
                },
                onSubmitted: _runSearch,
              ),
            ),
            Expanded(child: _buildResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_activeQuery.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Type a manga title to start searching.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final m = _results[i];
        final tracked = _trackedIds.contains(m.id);
        return ListTile(
          leading: _Cover(coverUrl: m.coverUrl),
          title: Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: tracked
              ? const Chip(
                  label: Text('Tracked'),
                  visualDensity: VisualDensity.compact,
                )
              : IconButton(
                  icon: const Icon(Icons.add_circle),
                  tooltip: 'Track',
                  onPressed: () => _track(m),
                ),
        );
      },
    );
  }
}

class _Cover extends StatelessWidget {
  final String? coverUrl;
  const _Cover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 44,
        height: 60,
        child: coverUrl == null
            ? _placeholder(theme)
            : Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(theme),
              ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.menu_book, color: theme.colorScheme.onSurfaceVariant),
      );
}
