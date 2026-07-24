import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/library_shortcut.dart';
import '../../core/models/book_metadata.dart';
import '../../core/provider/metadata_provider.dart';
import '../../core/provider/reading_progress_provider.dart';
import 'widgets/continue_reading_section.dart';
import 'widgets/recently_added.dart';
import 'widgets/welcome_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onViewLibrary,
    required this.onOpenReader,
    required this.onOpenBook,
    required this.onAddBook,
  });

  final VoidCallback onViewLibrary;
  final ValueChanged<BookMetadata> onOpenReader;
  final ValueChanged<BookMetadata> onOpenBook;
  final VoidCallback onAddBook;

  @override
  Widget build(BuildContext context) {
    final library = context.watch<TemporaryLibraryProvider>();

    final readingHistory = context.watch<ReadingProgressProvider>();

    final latestProgress = readingHistory.mostRecent;

    final recentlyAddedBooks = library.books.take(10).toList(growable: false);

    BookMetadata? currentBook;

    if (latestProgress != null) {
      for (final book in library.books) {
        if (book.id == latestProgress.bookId) {
          currentBook = book;
          break;
        }
      }
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        WelcomeTab(totalBooks: library.books.length),
        const SizedBox(height: 22),
        ContinueReadingSection(
          isLoading: library.isLoading || readingHistory.isLoading,
          book: currentBook,
          progress: currentBook == null ? null : latestProgress,
          onViewAll: onViewLibrary,
          onOpenLibrary: onViewLibrary,
          onContinueReading: () {
            if (currentBook != null) {
              onOpenReader(currentBook);
            }
          },
          onAddBook: onAddBook,
        ),
        const SizedBox(height: 22),
        LibraryShortcutSection(
          totalBooks: library.books.length,
          favoriteCount: 0,
          bookmarkCount: 0,
          recentCount: readingHistory.history.length,
          onViewAll: onViewLibrary,
          onAllBooks: onViewLibrary,
          onFavorites: onViewLibrary,
          onBookmarks: onViewLibrary,
          onRecent: onViewLibrary,
        ),
        const SizedBox(height: 22),
        RecentlyAddedSection(
          isLoading: library.isLoading,
          books: recentlyAddedBooks,
          onViewAll: onViewLibrary,
          onOpenBook: onOpenBook,
        ),
      ],
    );
  }
}
