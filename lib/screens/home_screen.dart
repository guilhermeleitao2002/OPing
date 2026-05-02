import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'package:oping/screens/manga_search_screen.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/tracked_manga_service.dart';
import 'package:oping/widgets/manga_card.dart';
import 'package:oping/workers/chapter_check_worker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = ChapterStorageService();
  final _tracked = TrackedMangaService();

  List<TrackedManga> _items = [];
  DateTime? _lastChecked;
  bool _isLoading = true;
  bool _isChecking = false;
  bool _pollingEnabled = true;

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      _tracked.getAll(),
      _storage.getLastChecked(),
      _storage.getPollingEnabled(),
    ]);
    if (!mounted) return;
    setState(() {
      _items = results[0] as List<TrackedManga>;
      _lastChecked = results[1] as DateTime?;
      _pollingEnabled = results[2] as bool;
      _isLoading = false;
    });
  }

  Future<void> _setPollingEnabled(bool enabled) async {
    await _storage.savePollingEnabled(enabled);
    if (enabled) {
      await Workmanager().registerPeriodicTask(
        WorkerTask.taskName,
        WorkerTask.taskName,
        frequency: const Duration(hours: 1),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } else {
      await Workmanager().cancelByUniqueName(WorkerTask.taskName);
    }
    if (mounted) setState(() => _pollingEnabled = enabled);
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      final result = await Permission.notification.request();
      if (result.isPermanentlyDenied && mounted) {
        _showPermissionDialog();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'OPing needs notification permission to alert you about new chapters. '
          'Please enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkNow() async {
    setState(() => _isChecking = true);
    await WorkerTask().execute();
    await _loadAll();
    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _openSearch() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const MangaSearchScreen()),
    );
    await _loadAll();
  }

  Future<void> _confirmUntrack(TrackedManga manga) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Untrack manga?'),
        content: Text('Stop receiving notifications for ${manga.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Untrack'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _tracked.remove(manga.id);
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPing', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.notifications_active),
            tooltip: 'Check now',
            onPressed: _isChecking || _isLoading ? null : _checkNow,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _loadAll,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: _buildBody(theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openSearch,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add manga'),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tracked manga',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        if (_items.isEmpty)
          _buildEmptyState(theme)
        else
          ..._items.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MangaCard(
                manga: m,
                onUntrack: () => _confirmUntrack(m),
              ),
            ),
          ),
        const SizedBox(height: 12),
        _buildLastChecked(theme),
        const SizedBox(height: 16),
        _buildPollingToggle(theme),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.menu_book, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No manga tracked yet',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to find a manga and start receiving notifications.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastChecked(ThemeData theme) {
    final text = _lastChecked == null
        ? 'Never checked via background'
        : 'Last background check: ${_formatRelative(_lastChecked!)}';

    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPollingToggle(ThemeData theme) {
    return Card(
      child: SwitchListTile(
        title: const Text('Background polling'),
        subtitle: Text(
          _pollingEnabled ? 'Checks for new chapters every hour' : 'Notifications paused',
          style: theme.textTheme.bodySmall,
        ),
        secondary: Icon(
          _pollingEnabled ? Icons.notifications_active : Icons.notifications_off,
          color: _pollingEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        value: _pollingEnabled,
        onChanged: _setPollingEnabled,
      ),
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
