import 'package:flutter/material.dart';

import '../../../core/models/book_metadata.dart';
import '../../../core/theme/app_font.dart';
import '../../../core/theme/app_theme.dart';
import 'book_summary.dart';

enum BookTab { chapters, details }

class BookTabs extends StatefulWidget {
  const BookTabs({
    super.key,
    required this.book,
    this.publisher,
    this.publishedDate,
    this.language,
    this.genres = const [],
    this.pageCount,
    this.isbn,
    this.edition,
    this.chapters = const [],
  });

  final BookMetadata book;
  final String? publisher;
  final String? publishedDate;
  final String? language;
  final List<String> genres;
  final int? pageCount;
  final String? isbn;
  final String? edition;
  final List<String> chapters;

  @override
  State<BookTabs> createState() => _BookTabsState();
}

class _BookTabsState extends State<BookTabs> {
  static const int _chaptersPerPage = 100;

  BookTab _selectedTab = BookTab.chapters;
  int _chapterPage = 0;

  @override
  void didUpdateWidget(covariant BookTabs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!identical(oldWidget.chapters, widget.chapters)) {
      _chapterPage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabBar(
          selectedTab: _selectedTab,
          onSelected: (tab) {
            setState(() {
              _selectedTab = tab;
            });
          },
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(_selectedTab),
            child: _buildSelectedTab(),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedTab() {
    return switch (_selectedTab) {
      BookTab.chapters => _buildChapters(),
      BookTab.details => _buildDetails(),
    };
  }

  Widget _buildChapters() {
    if (widget.chapters.isEmpty) {
      return const _EmptyTab(
        icon: Icons.menu_book_outlined,
        title: 'No chapters available',
        message: 'Chapter information has not been loaded for this book.',
      );
    }

    final pageCount =
        (widget.chapters.length + _chaptersPerPage - 1) ~/ _chaptersPerPage;
    final startIndex = _chapterPage * _chaptersPerPage;
    final requestedEnd = startIndex + _chaptersPerPage;
    final endIndex = requestedEnd < widget.chapters.length
        ? requestedEnd
        : widget.chapters.length;
    final pageChapters = widget.chapters.sublist(startIndex, endIndex);

    return _SectionCard(
      title: 'Chapters (${widget.chapters.length})',
      icon: Icons.menu_book_outlined,
      child: Column(
        children: [
          for (var index = 0; index < pageChapters.length; index++)
            _ChapterRow(
              number: startIndex + index + 1,
              title: pageChapters[index],
              showDivider: index != pageChapters.length - 1,
            ),
          if (pageCount > 1) ...[
            const SizedBox(height: 12),
            _ChapterPagination(
              currentPage: _chapterPage,
              pageCount: pageCount,
              onPrevious: _chapterPage == 0
                  ? null
                  : () {
                      setState(() {
                        _chapterPage--;
                      });
                    },
              onNext: _chapterPage == pageCount - 1
                  ? null
                  : () {
                      setState(() {
                        _chapterPage++;
                      });
                    },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return BookSummary(
      book: widget.book,
      publisher: widget.publisher,
      language: widget.language,
      genres: widget.genres,
    );
  }
}

class _ChapterPagination extends StatelessWidget {
  const _ChapterPagination({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded, size: 17),
            label: const Text('Previous'),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${currentPage + 1} / $pageCount',
          style: AppFonts.metadata(context, fontSize: 10),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNext,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 17),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedTab, required this.onSelected});

  final BookTab selectedTab;
  final ValueChanged<BookTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 0.6),
        ),
      ),
      child: Row(
        children: [
          _TabItem(
            tab: BookTab.chapters,
            label: 'Chapters',
            icon: Icons.menu_book_outlined,
            selected: selectedTab == BookTab.chapters,
            onTap: onSelected,
          ),
          _TabItem(
            tab: BookTab.details,
            label: 'Details',
            icon: Icons.info_outline_rounded,
            selected: selectedTab == BookTab.details,
            onTap: onSelected,
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final BookTab tab;
  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<BookTab> onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.gold
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(tab),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.only(top: 9, bottom: 7),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.gold : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    AppFonts.navigationLabel(
                      context,
                      fontSize: 12,
                      color: color,
                    ).copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outlineVariant, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 23, color: AppColors.gold),
                const SizedBox(width: 7),
                Text(
                  title,
                  style: AppFonts.sectionHeading(
                    context,
                    fontSize: 15,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  const _ChapterRow({
    required this.number,
    required this.title,
    required this.showDivider,
  });

  final int number;
  final String title;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$number',
                  style: AppFonts.metadata(
                    context,
                    fontSize: 10,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Expanded(
                child: Text(title, style: AppFonts.body(context, fontSize: 13)),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 17,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: .5),
          ),
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Column(
        children: [
          Icon(icon, size: 32, color: colors.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.sectionHeading(context, fontSize: 14),
          ),
          const SizedBox(height: 5),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppFonts.metadata(context, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
