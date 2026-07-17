import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:novel_lux/core/models/book_metadata.dart';
import 'package:novel_lux/core/theme/app_theme.dart';

class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.book,
    this.progress = 0,
    this.cover,
    this.onTap,
    this.onMenuPressed,
  });

  final BookMetadata book;
  final double progress;
  final Widget? cover;
  final VoidCallback? onTap;
  final VoidCallback? onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final normalizedProgress =
        progress.clamp(0.0, 1.0).toDouble();

    final percentage =
        (normalizedProgress * 100).round();

    final sizeInMb =
        book.fileSize / (1024 * 1024);

    final fileType = path
        .extension(book.filePath)
        .replaceFirst('.', '')
        .toUpperCase();

    return Card(
      elevation: 1,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: theme.dividerColor,
          width: 0.4,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 58,
                  height: 86,
                  child: cover ??
                      const Image(
                        image: AssetImage(
                          'assets/images/book_placeholder.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 86,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              book.title,
                              maxLines: 1,
                              overflow:
                                  TextOverflow.ellipsis,
                              style: theme
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 26,
                            height: 24,
                            child: IconButton(
                              onPressed:
                                  onMenuPressed ?? () {},
                              padding: EdgeInsets.zero,
                              iconSize: 18,
                              visualDensity:
                                  VisualDensity.compact,
                              icon: const Icon(
                                Icons.more_vert,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        book.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$fileType • '
                        '${sizeInMb.toStringAsFixed(2)} MB',
                        style:
                            theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              value: normalizedProgress,
                              minHeight: 3,
                              borderRadius:
                                  BorderRadius.circular(10),
                              backgroundColor:
                                  colors.surfaceContainerHighest,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$percentage%',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}