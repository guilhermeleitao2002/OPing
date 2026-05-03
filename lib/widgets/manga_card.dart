import 'package:flutter/material.dart';
import 'package:oping/services/tracked_manga_service.dart';
import 'package:oping/widgets/app_scope.dart';

class MangaCard extends StatelessWidget {
  final TrackedManga manga;
  final VoidCallback? onTap;
  final VoidCallback? onUntrack;

  const MangaCard({super.key, required this.manga, this.onTap, this.onUntrack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppScope.of(context).strings;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: _Cover(coverUrl: manga.coverUrl, theme: theme),
              ),
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
                    manga.lastSeenChapter > 0
                        ? RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              children: [
                                TextSpan(
                                  text: '${_labelPrefix(s)} ',
                                ),
                                TextSpan(
                                  text: _formatNumber(manga.lastSeenChapter),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Text(
                            s.noChaptersSeen,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ],
                ),
              ),
              if (onUntrack != null)
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error.withValues(alpha: 0.7),
                  ),
                  tooltip: s.untrack,
                  onPressed: onUntrack,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Returns the label part before the chapter number, e.g. "Last seen: Chapter"
  String _labelPrefix(dynamic s) {
    // Extract the label portion (everything before the chapter number placeholder)
    final full = s.lastSeenChapter(_formatNumber(manga.lastSeenChapter));
    final num = _formatNumber(manga.lastSeenChapter);
    final idx = full.lastIndexOf(num);
    return idx > 0 ? full.substring(0, idx).trimRight() : full;
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
      borderRadius: BorderRadius.circular(6),
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
