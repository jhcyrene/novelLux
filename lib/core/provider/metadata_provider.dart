import 'dart:typed_data';

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../models/book_metadata.dart';
import '../services/epub_picker.dart';
import '../storage/book_storage.dart';
import '../storage/book_storage_contract.dart';

class TemporaryLibraryProvider
    extends ChangeNotifier {
  TemporaryLibraryProvider({
    BookStorage? storage,
  }) : _storage = storage ?? createBookStorage();

  final BookStorage _storage;
  final List<BookMetadata> _books = [];

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  List<BookMetadata> get books =>
      List.unmodifiable(_books);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> uploadEpub(
    BuildContext context,
  ) async {
    try {
      final selectedBook =
          await EpubPickerService.pickEpub();

      if (selectedBook == null) {
        return;
      }

      await _ensureInitialized();

      final storedBook = await _storage.saveEpub(
        originalName: selectedBook.name,
        bytes: selectedBook.bytes,
      );

      await loadBooks();

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${storedBook.name} is available temporarily.',
          ),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to import EPUB: $error',
          ),
        ),
      );
    }
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureInitialized();

      final storedBooks =
          await _storage.listBooks();

      final loadedBooks = <BookMetadata>[];

      for (final storedBook in storedBooks) {
        try {
          final bytes = await _storage.readBytes(
            storedBook.id,
          );

          final epubReference =
              await EpubReader.openBook(bytes);

          final title =
              epubReference.Title?.trim();
          final author =
              epubReference.Author?.trim();

          loadedBooks.add(
            BookMetadata(
              id: storedBook.id,
              filePath: storedBook.name,
              title: title?.isNotEmpty == true
                  ? title!
                  : path.basenameWithoutExtension(
                      storedBook.name,
                    ),
              author: author?.isNotEmpty == true
                  ? author!
                  : 'Unknown author',
              fileSize: storedBook.size,
            ),
          );
        } catch (error) {
          debugPrint(
            'Unable to read ${storedBook.name}: '
            '$error',
          );
        }
      }

      loadedBooks.sort(
        (first, second) =>
            first.title.compareTo(second.title),
      );

      _books
        ..clear()
        ..addAll(loadedBooks);
    } catch (error) {
      _error = 'Unable to load books: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Uint8List> readBookBytes(
    String bookId,
  ) async {
    await _ensureInitialized();

    return _storage.readBytes(bookId);
  }

  Future<void> deleteBook(String bookId) async {
    await _ensureInitialized();
    await _storage.deleteBook(bookId);
    await loadBooks();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    await _storage.initialize();
    _isInitialized = true;
  }
}