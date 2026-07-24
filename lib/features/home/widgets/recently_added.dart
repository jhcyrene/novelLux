import 'package:flutter/material.dart';

import '../../../core/models/book_metadata.dart';
import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/skeleton_loader.dart';

typedef RecentlyAddedCoverBuilder =
    Widget Function(BuildContext context, BookMetadata book);

class RecentlyAddedSection extends StatefulWidget {
  const RecentlyAddedSection({
    super.key,
    required this.books,
    required this.onViewAll,
    required this.onOpenBook,
    this.coverBuilder,
    this.isLoading = false,
  });

  final List<BookMetadata> books;
  final VoidCallback onViewAll;
  final ValueChanged<BookMetadata> onOpenBook;
  final RecentlyAddedCoverBuilder? coverBuilder;
  final bool isLoading;

  @override
  State<RecentlyAddedSection> createState() => _RecentlyAddedSectionState();
}

class _RecentlyAddedSectionState extends State<RecentlyAddedSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recently Added',
                style: AppFonts.sectionHeading(context, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: widget.onViewAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gold,
                padding: EdgeInsets.zero,
                minimumSize: const Size(55, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
        SizedBox(
          height: 200,
          child: widget.isLoading
              ? const _RecentlyAddedSkeleton()
              : widget.books.isEmpty
              ? const _EmptyRecentlyAdded()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.books.length,
                  clipBehavior: Clip.none,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final book = widget.books[index];

                    return _RecentlyAddedBook(
                      book: book,
                      cover: widget.coverBuilder?.call(context, book),
                      onTap: () => widget.onOpenBook(book),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _RecentlyAddedSkeleton extends StatelessWidget {
  const _RecentlyAddedSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        clipBehavior: Clip.none,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return const SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 150, borderRadius: 7),
                SizedBox(height: 8),
                SkeletonBox(height: 11),
                SizedBox(height: 5),
                SkeletonBox(width: 68, height: 9),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmptyRecentlyAdded extends StatelessWidget {
  const _EmptyRecentlyAdded();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No books have been added yet.',
        textAlign: TextAlign.center,
        style: AppFonts.body(context, fontSize: 12),
      ),
    );
  }
}

class _RecentlyAddedBook extends StatelessWidget {
  const _RecentlyAddedBook({
    required this.book,
    required this.onTap,
    this.cover,
  });

  final BookMetadata book;
  final VoidCallback onTap;
  final Widget? cover;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: 100,
      child: Semantics(
        button: true,
        label: 'Open ${book.title} by ${book.author}',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 100,
                  height: 150,
                  child:
                      cover ??
                      Image.asset(
                        'assets/images/book_placeholder.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return ColoredBox(
                            color: colors.surface,
                            child: const Center(
                              child: Icon(
                                Icons.auto_stories_outlined,
                                color: AppColors.gold,
                                size: 30,
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ),
              const SizedBox(height: 7),
              Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.bookTitle(
                  context,
                  fontSize: 11,
                ).copyWith(height: 1.18),
              ),
              const SizedBox(height: 3),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.author(context, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
