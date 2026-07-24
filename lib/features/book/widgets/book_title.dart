import 'package:flutter/material.dart';

import '../../../core/models/book_metadata.dart';
import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';
import 'book_menu.dart';

class BookTitle extends StatelessWidget {
  const BookTitle({
    super.key,
    required this.book,
    required this.onStartReading,
    required this.onFavoritePressed,
    this.cover,
    this.genres = const [],
    this.charCount,
    this.chapterCount,
    this.estimatedReadingTime,
    this.isFavorite = false,
  });

  final BookMetadata book;
  final VoidCallback onStartReading;
  final VoidCallback onFavoritePressed;
  final Widget? cover;
  final List<String> genres;
  final int? charCount;
  final int? chapterCount;
  final Duration? estimatedReadingTime;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final visibleTags = genres.isNotEmpty ? genres : book.tags;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 140,
                height: 200,
                child:
                    cover ??
                    const Image(
                      image: AssetImage('assets/images/book_placeholder.png'),
                      fit: BoxFit.cover,
                    ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 50,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.pageTitle(
                            context,
                            fontSize: 24,
                          ).copyWith(height: 1.05, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 13,
                          color: AppColors.gold,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.author,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.author(
                              context,
                              fontSize: 11,
                              color: AppColors.gold,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    if (visibleTags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 5,
                        children: visibleTags
                            .take(5)
                            .map((genre) => _GenreChip(label: genre))
                            .toList(growable: false),
                      ),
                    ],
                    const Spacer(),
                    Divider(height: 1, color: colors.outlineVariant),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _BookMetric(
                            icon: Icons.text_fields_rounded,
                            value: charCount?.toString() ?? '—',
                            label: 'Characters',
                          ),
                        ),
                        _MetricDivider(color: colors.outlineVariant),
                        Expanded(
                          child: _BookMetric(
                            icon: Icons.menu_book_outlined,
                            value: chapterCount?.toString() ?? '—',
                            label: 'Chapters',
                          ),
                        ),
                        _MetricDivider(color: colors.outlineVariant),
                        Expanded(
                          child: _BookMetric(
                            icon: Icons.schedule_rounded,
                            value: _formatReadingTime(estimatedReadingTime),
                            label: 'Est. Read',
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
        const SizedBox(height: 18),
        BookMenu(
          isFavorite: isFavorite,
          onStartReading: onStartReading,
          onFavoritePressed: onFavoritePressed,
        ),
      ],
    );
  }

  String _formatReadingTime(Duration? duration) {
    if (duration == null) {
      return '—';
    }

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours == 0) {
      return '${minutes}m';
    }

    return minutes == 0 ? '${hours}h' : '${hours}h ${minutes}m';
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.metadata(
            context,
            fontSize: 9,
            color: AppColors.gold,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _BookMetric extends StatelessWidget {
  const _BookMetric({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.gold),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.metadata(context, fontSize: 10).copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.metadata(context, fontSize: 7),
        ),
      ],
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 28, color: color);
  }
}
