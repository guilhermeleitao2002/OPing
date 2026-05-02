import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:oping/services/tracked_manga_service.dart';

class MangaCard extends StatelessWidget {
  final TrackedManga manga;
  final VoidCallback? onUntrack;

  const MangaCard({super.key, required this.manga, this.onUntrack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openMangaDex('https://mangadex.org/title/${manga.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Cover(coverUrl: manga.coverUrl, theme: theme),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      manga.lastSeenChapter > 0
                          ? 'Last seen: Chapter ${_formatNumber(manga.lastSeenChapter)}'
                          : 'No chapters seen yet',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (onUntrack != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Untrack',
                  onPressed: onUntrack,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMangaDex(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _formatNumber(double number) {
    if (number == number.truncateToDouble()) return number.toInt().toString();
    return number.toString();
  }
}

class _Cover extends StatelessWidget {
  final String? coverUrl;
  final ThemeData theme;

  const _Cover({required this.coverUrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 56,
        height: 80,
        child: coverUrl == null
            ? _placeholder()
            : Image.network(
                coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              ),
      ),
    );
  }

  Widget _placeholder() => Container(
        color: theme.colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(Icons.menu_book, color: theme.colorScheme.onSurfaceVariant),
      );
}
