import 'package:flutter/material.dart';
import '../../core/models/book_metadata.dart';

import 'widgets/book_list.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({
    super.key,
    required this.onOpenBook,
  });

  final ValueChanged<BookMetadata> onOpenBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Material(
            color: theme.scaffoldBackgroundColor,
            child: TabBar(
              indicatorColor: theme.colorScheme.primary,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurfaceVariant,
              dividerColor: theme.dividerColor,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Epub'),
                Tab(text: 'Pdf'),
                Tab(text: 'Txt'),
                Tab(text: 'Other'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                TemporaryBookList(
                  onOpenBook: onOpenBook,
                ),
                TemporaryBookList(
                  onOpenBook: onOpenBook,
                ),
                const _EmptyLibraryType(
                  message: 'No PDF books uploaded.',
                ),
                const _EmptyLibraryType(
                  message: 'No TXT books uploaded.',
                ),
                const _EmptyLibraryType(
                  message: 'No other books uploaded.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibraryType extends StatelessWidget {
  const _EmptyLibraryType({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
      ),
    );
  }
}