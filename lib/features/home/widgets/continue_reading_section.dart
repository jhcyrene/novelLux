import 'package:flutter/material.dart';

import '../../../core/models/book_metadata.dart';
import '../../../core/models/reading_progress.dart';
import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';

class ContinueReadingSection extends StatelessWidget {
  const ContinueReadingSection({
    super.key,
    required this.onViewAll,
    required this.onOpenLibrary,
    required this.onAddBook,
    required this.onContinueReading,
    this.book,
    this.progress,
  });

  final BookMetadata? book;
  final ReadingProgress? progress;

  final VoidCallback onViewAll;
  final VoidCallback onOpenLibrary;
  final VoidCallback onAddBook;
  final VoidCallback onContinueReading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final hasReadingHistory =
        book != null && progress != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Continue Reading',
                style: AppFonts.sectionHeading(
                  context,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
                padding: EdgeInsets.zero,
                minimumSize: const Size(55, 32),
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: AppFonts.button(
                  context,
                  fontSize: 12,
                  color: AppColors.gold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.gold.withValues(
                alpha: 0.25,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: hasReadingHistory
              ? _CurrentReadingContent(
                  book: book!,
                  progress: progress!,
                  onPressed: onContinueReading,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 290) {
                      return Column(
                        children: [
                          const _EmptyBookIllustration(
                            size: 110,
                          ),
                          const SizedBox(height: 12),
                          _EmptyReadingContent(
                            onOpenLibrary:
                                onOpenLibrary,
                            onAddBook: onAddBook,
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        const _EmptyBookIllustration(
                          size: 110,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _EmptyReadingContent(
                            onOpenLibrary:
                                onOpenLibrary,
                            onAddBook: onAddBook,
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyReadingContent extends StatelessWidget {
  const _EmptyReadingContent({
    required this.onOpenLibrary,
    required this.onAddBook,
  });

  final VoidCallback onOpenLibrary;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'No current reading yet',
          style: AppFonts.emptyStateTitle(
            context,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Open a book from your library and continue your story here.',
          style: AppFonts.body(
            context,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: onOpenLibrary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.deepBlack,
                textStyle: AppFonts.button(
                  context,
                  fontSize: 11,
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(
                Icons.local_library_outlined,
                size: 16,
              ),
              label: const Text('Open Library'),
            ),
            OutlinedButton.icon(
              onPressed: onAddBook,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                textStyle: AppFonts.button(
                  context,
                  fontSize: 11,
                ),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                side: const BorderSide(
                  color: AppColors.gold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(
                Icons.add,
                size: 17,
              ),
              label: const Text('Add Book'),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyBookIllustration extends StatelessWidget {
  const _EmptyBookIllustration({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/images/bookMoon1.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Icon(
            Icons.auto_stories_outlined,
            size: size * 0.65,
            color: AppColors.gold,
          );
        },
      ),
    );
  }
}

class _CurrentReadingContent extends StatelessWidget {
  const _CurrentReadingContent({
    required this.book,
    required this.progress,
    required this.onPressed,
  });

  final BookMetadata book;
  final ReadingProgress progress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final percentage =
        (progress.percentage * 100).round();

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              'assets/images/book_placeholder.png',
              width: 72,
              height: 105,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 72,
                  height: 105,
                  color: AppColors.deepBlack,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.auto_stories,
                    color: AppColors.gold,
                    size: 32,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.bookTitle(
                    context,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.author(
                    context,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  progress.chapterTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.metadata(
                    context,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: LinearProgressIndicator(
                          value: progress.percentage,
                          minHeight: 4,
                          backgroundColor:
                              AppColors.gold.withValues(
                            alpha: 0.15,
                          ),
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percentage%',
                      style: AppFonts.metadata(
                        context,
                        fontSize: 12,
                        color: AppColors.gold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}