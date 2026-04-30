import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:workmanager/workmanager.dart';

import 'package:oping/models/chapter.dart';
import 'package:oping/services/chapter_storage_service.dart';
import 'package:oping/services/manga_dex_service.dart';
import 'package:oping/widgets/chapter_card.dart';
import 'package:oping/workers/chapter_check_worker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Chapter? _latestChapter;
  DateTime? _lastChecked;
  bool _isLoading = true;
  bool _isChecking = false;
  bool _pollingEnabled = true;
  String? _errorMessage;

  final _mangaDex = MangaDexService();
  final _storage = ChapterStorageService();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    _loadData();
    _loadPollingState();
  }

  Future<void> _loadPollingState() async {
    final enabled = await _storage.getPollingEnabled();
    if (mounted) setState(() => _pollingEnabled = enabled);
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait([
        _mangaDex.fetchLatestChapter(),
        _storage.getLastChecked(),
      ]);
      if (mounted) {
        setState(() {
          _latestChapter = results[0] as Chapter?;
          _lastChecked = results[1] as DateTime?;
          _isLoading = false;
          if (_latestChapter == null) {
            _errorMessage = 'Could not fetch chapter data. Check your connection.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    }
  }

  Future<void> _checkNow() async {
    setState(() => _isChecking = true);
    await WorkerTask().execute();
    await _loadData();
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OPing', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _buildBody(theme),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isChecking ? null : _checkNow,
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: Colors.white,
        icon: _isChecking
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.notifications_active),
        label: Text(_isChecking ? 'Checking...' : 'Check Now'),
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
        _buildHeader(theme),
        const SizedBox(height: 20),
        if (_errorMessage != null) _buildErrorCard(theme) else if (_latestChapter != null) ChapterCard(chapter: _latestChapter!),
        const SizedBox(height: 12),
        _buildLastChecked(theme),
        const SizedBox(height: 16),
        _buildPollingToggle(theme),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Latest Chapter',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Text('\u{2694}', style: TextStyle(fontSize: 22)),
      ],
    );
  }

  Widget _buildErrorCard(ThemeData theme) {
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.wifi_off, color: theme.colorScheme.error, size: 40),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
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
