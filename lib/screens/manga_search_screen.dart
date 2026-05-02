import 'dart:async';

import 'package:flutter/material.dart';

import 'package:oping/models/manga.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/services/tracked_manga_service.dart';

// ── Display helpers for sort order ────────────────────────────────────────────

extension _SortOrderDisplay on MangaSortOrder {
  String get label => switch (this) {
        MangaSortOrder.relevance    => 'Relevance',
        MangaSortOrder.mostFollowed => 'Most Popular',
        MangaSortOrder.highestRated => 'Top Rated',
        MangaSortOrder.recentUpload => 'Recently Updated',
        MangaSortOrder.newest       => 'Newest',
      };

  IconData get icon => switch (this) {
        MangaSortOrder.relevance    => Icons.manage_search,
        MangaSortOrder.mostFollowed => Icons.groups_rounded,
        MangaSortOrder.highestRated => Icons.star_rounded,
        MangaSortOrder.recentUpload => Icons.update_rounded,
        MangaSortOrder.newest       => Icons.fiber_new_rounded,
      };
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class MangaSearchScreen extends StatefulWidget {
  const MangaSearchScreen({super.key});

  @override
  State<MangaSearchScreen> createState() => _MangaSearchScreenState();
}

class _MangaSearchScreenState extends State<MangaSearchScreen> {
  static const _kSuggestDebounce = Duration(milliseconds: 200);
  static const _kSearchDebounce  = Duration(milliseconds: 450);

  final _mangaDex = MangaDexService();
  final _tracked  = TrackedMangaService();
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();

  Timer? _debounceTimer;
  Timer? _suggestionTimer;

  // Tracked state
  Set<String> _trackedIds = {};
  bool _didChange = false;

  // Popular (shown when query is empty)
  List<Manga> _popular = [];
  bool _isLoadingPopular = true;

  // Autocomplete suggestions overlay
  List<Manga> _suggestions = [];
  bool _isLoadingSuggestions = false;
  String _suggestionQuery = '';
  bool _fieldFocused = false;

  // Full search results
  List<Manga> _results = [];
  bool _isSearching = false;
  String _activeQuery = '';
  String? _errorMessage;

  // Active sort filter
  MangaSortOrder _sort = MangaSortOrder.relevance;

  bool get _showSuggestions =>
      _fieldFocused &&
      _controller.text.trim().isNotEmpty &&
      !_isSearching &&
      (_isLoadingSuggestions || _suggestions.isNotEmpty);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _loadTrackedIds();
    _loadPopular();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _suggestionTimer?.cancel();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Short delay so tapping a suggestion row fires before clearing
      Future.delayed(const Duration(milliseconds: 120), () {
        if (mounted) setState(() { _fieldFocused = false; _suggestions = []; });
      });
    } else {
      setState(() => _fieldFocused = true);
    }
  }

  // ── Data loading ───────────────────────────────────────────────────────────

  Future<void> _loadTrackedIds() async {
    final list = await _tracked.getAll();
    if (!mounted) return;
    setState(() => _trackedIds = list.map((m) => m.id).toSet());
  }

  Future<void> _loadPopular() async {
    setState(() => _isLoadingPopular = true);
    final results = await _mangaDex.fetchPopularManga();
    if (!mounted) return;
    setState(() { _popular = results; _isLoadingPopular = false; });
  }

  // ── Input handling ─────────────────────────────────────────────────────────

  void _onQueryChanged(String value) {
    setState(() {}); // rebuild suffix icon

    // Suggestions: fast
    _suggestionTimer?.cancel();
    if (value.trim().isNotEmpty) {
      setState(() => _isLoadingSuggestions = true);
      _suggestionTimer = Timer(_kSuggestDebounce, () => _runSuggestion(value));
    } else {
      setState(() { _suggestions = []; _isLoadingSuggestions = false; });
    }

    // Full search: slower
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_kSearchDebounce, () => _runSearch(value));
  }

  void _onSubmitted(String value) {
    _suggestionTimer?.cancel();
    _debounceTimer?.cancel();
    setState(() { _suggestions = []; _isLoadingSuggestions = false; });
    _runSearch(value);
  }

  void _selectSuggestion(Manga manga) {
    _suggestionTimer?.cancel();
    _debounceTimer?.cancel();
    _controller.text = manga.title;
    _controller.selection = TextSelection.collapsed(offset: manga.title.length);
    setState(() { _suggestions = []; _isLoadingSuggestions = false; });
    _focusNode.unfocus();
    _runSearch(manga.title);
  }

  // ── Search logic ───────────────────────────────────────────────────────────

  Future<void> _runSuggestion(String text) async {
    final trimmed = text.trim();
    if (trimmed == _suggestionQuery) return;
    _suggestionQuery = trimmed;

    if (trimmed.isEmpty) {
      setState(() { _suggestions = []; _isLoadingSuggestions = false; });
      return;
    }

    final results = await _mangaDex.searchManga(trimmed, limit: 5);
    if (!mounted || _suggestionQuery != trimmed) return;
    setState(() { _suggestions = results; _isLoadingSuggestions = false; });
  }

  Future<void> _runSearch(String text) async {
    final trimmed = text.trim();
    if (trimmed == _activeQuery) return;
    _activeQuery = trimmed;

    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _errorMessage = null;
        _suggestions = [];
        _isLoadingSuggestions = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _suggestions = [];
      _isLoadingSuggestions = false;
    });

    final results = await _mangaDex.searchManga(trimmed, sort: _sort);
    if (!mounted || _activeQuery != trimmed) return;

    setState(() {
      _isSearching = false;
      _results = results;
      _errorMessage = results.isEmpty ? 'No results for "$trimmed"' : null;
    });
  }

  Future<void> _changeSort(MangaSortOrder sort) async {
    if (sort == _sort) return;
    setState(() => _sort = sort);
    if (_activeQuery.isNotEmpty) {
      setState(() { _isSearching = true; _errorMessage = null; });
      final results = await _mangaDex.searchManga(_activeQuery, sort: sort);
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _results = results;
        _errorMessage = results.isEmpty ? 'No results for "$_activeQuery"' : null;
      });
    } else {
      setState(() => _isLoadingPopular = true);
      final results = await _mangaDex.fetchPopularManga(sort: sort);
      if (!mounted) return;
      setState(() { _popular = results; _isLoadingPopular = false; });
    }
  }

  // ── Track action ───────────────────────────────────────────────────────────

  Future<void> _track(Manga manga) async {
    await _tracked.add(manga);
    if (!mounted) return;
    setState(() { _trackedIds = {..._trackedIds, manga.id}; _didChange = true; });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Now tracking ${manga.title}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope<Object?>(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) Navigator.of(context).maybePop(_didChange);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: const Text('Add manga'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                textInputAction: TextInputAction.search,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search MangaDex by title…',
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _controller.clear();
                            _onQueryChanged('');
                            _focusNode.requestFocus();
                          },
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: _onQueryChanged,
                onSubmitted: _onSubmitted,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // ── Main content ────────────────────────────────────────────────
            GestureDetector(
              onTap: _suggestions.isNotEmpty ? () => setState(() => _suggestions = []) : null,
              behavior: HitTestBehavior.translucent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FilterChips(
                    selected: _sort,
                    onChanged: _changeSort,
                  ),
                  Expanded(child: _buildMainContent(theme)),
                ],
              ),
            ),
            // ── Autocomplete overlay ────────────────────────────────────────
            if (_showSuggestions)
              _SuggestionsPanel(
                suggestions: _suggestions,
                isLoading: _isLoadingSuggestions,
                trackedIds: _trackedIds,
                onSelect: _selectSuggestion,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme) {
    if (_activeQuery.isEmpty) {
      return _PopularSection(
        manga: _popular,
        isLoading: _isLoadingPopular,
        trackedIds: _trackedIds,
        onTrack: _track,
      );
    }
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48,
                color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _results.length,
      itemBuilder: (_, i) => _ResultTile(
        manga: _results[i],
        isTracked: _trackedIds.contains(_results[i].id),
        onTrack: () => _track(_results[i]),
      ),
    );
  }
}

// ── Filter chips ───────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final MangaSortOrder selected;
  final ValueChanged<MangaSortOrder> onChanged;

  const _FilterChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: MangaSortOrder.values.map((sort) {
          final isSelected = sort == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(sort.label),
              avatar: Icon(sort.icon, size: 14),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) => onChanged(sort),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Autocomplete suggestion overlay ───────────────────────────────────────────

class _SuggestionsPanel extends StatelessWidget {
  final List<Manga> suggestions;
  final bool isLoading;
  final Set<String> trackedIds;
  final ValueChanged<Manga> onSelect;

  const _SuggestionsPanel({
    required this.suggestions,
    required this.isLoading,
    required this.trackedIds,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Material(
        elevation: 6,
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: isLoading && suggestions.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < suggestions.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 1,
                        indent: 64,
                        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                    InkWell(
                      onTap: () => onSelect(suggestions[i]),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            _SmallCover(coverUrl: suggestions[i].coverUrl),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                suggestions[i].title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (trackedIds.contains(suggestions[i].id))
                              Icon(Icons.check_circle_outline,
                                  size: 16,
                                  color: theme.colorScheme.primary)
                            else
                              Icon(Icons.north_west,
                                  size: 14,
                                  color: theme.colorScheme.outlineVariant),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

// ── Popular section ────────────────────────────────────────────────────────────

class _PopularSection extends StatelessWidget {
  final List<Manga> manga;
  final bool isLoading;
  final Set<String> trackedIds;
  final Future<void> Function(Manga) onTrack;

  const _PopularSection({
    required this.manga,
    required this.isLoading,
    required this.trackedIds,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (manga.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 16),
            Text(
              'Search for a manga above',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.trending_up_rounded,
                    size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Popular on MangaDex',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.62,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _PopularCard(
                manga: manga[i],
                isTracked: trackedIds.contains(manga[i].id),
                onTrack: () => onTrack(manga[i]),
              ),
              childCount: manga.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularCard extends StatelessWidget {
  final Manga manga;
  final bool isTracked;
  final VoidCallback onTrack;

  const _PopularCard({
    required this.manga,
    required this.isTracked,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cover image
          manga.coverUrl != null
              ? Image.network(
                  manga.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _coverPlaceholder(theme),
                )
              : _coverPlaceholder(theme),

          // Bottom gradient + title
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(6, 20, 6, 6),
              child: Text(
                manga.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 2)],
                ),
              ),
            ),
          ),

          // Track button (top-right)
          Positioned(
            top: 4,
            right: 4,
            child: isTracked
                ? Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  )
                : GestureDetector(
                    onTap: onTrack,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 16),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder(ThemeData theme) => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.menu_book_rounded,
            color: theme.colorScheme.onSurfaceVariant, size: 32),
      );
}

// ── Result tile (full search list) ────────────────────────────────────────────

class _ResultTile extends StatelessWidget {
  final Manga manga;
  final bool isTracked;
  final VoidCallback onTrack;

  const _ResultTile({
    required this.manga,
    required this.isTracked,
    required this.onTrack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Cover(coverUrl: manga.coverUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  manga.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 8),
              isTracked
                  ? Chip(
                      label: const Text('Tracked'),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                      side: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4)),
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.08),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    )
                  : FilledButton.tonal(
                      onPressed: onTrack,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        minimumSize: const Size(0, 34),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Track'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared cover widgets ───────────────────────────────────────────────────────

class _Cover extends StatelessWidget {
  final String? coverUrl;
  const _Cover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 66,
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
        child: Icon(Icons.menu_book,
            color: theme.colorScheme.onSurfaceVariant, size: 20),
      );
}

class _SmallCover extends StatelessWidget {
  final String? coverUrl;
  const _SmallCover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: 32,
        height: 44,
        child: coverUrl == null
            ? Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(Icons.menu_book,
                    size: 14, color: theme.colorScheme.onSurfaceVariant),
              )
            : Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
      ),
    );
  }
}
