import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:novel_lux/core/models/book_metadata.dart';
import 'package:novel_lux/core/provider/metadata_provider.dart';
import 'package:novel_lux/core/provider/reading_progress_provider.dart';

import 'book_card.dart';

class TemporaryBookList extends StatelessWidget {
  const TemporaryBookList({
    super.key,
    required this.onOpenBook,
  });

  final ValueChanged<BookMetadata> onOpenBook;

  @override
  Widget build(BuildContext context) {
    return Consumer2<
        TemporaryLibraryProvider,
        ReadingProgressProvider>(
      builder: (context, library, readingProgress, child) {
        if (library.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (library.error != null) {
          return Center(
            child: Text(library.error!),
          );
        }

        if (library.books.isEmpty) {
          return const Center(
            child: Text('No EPUB books uploaded.'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: library.books.length,
          separatorBuilder: (_, _) =>
              const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final book = library.books[index];
            final progress =
                readingProgress.progressFor(book.id);

            return BookCard(
              book: book,
              progress: progress?.percentage ?? 0,
              onTap: () {
                onOpenBook(book);
              },
              onMenuPressed: () {
                // Show rename, details, or delete options later.
              },
            );
          },
        );
      },
    );
  }
}