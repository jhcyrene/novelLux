import 'dart:io';

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import '../models/book_metadata.dart';
import '../services/epub_picker.dart';

class TemporaryLibraryProvider extends ChangeNotifier {
  final List<BookMetadata> _books = [];

  bool _isLoading = false;
  String? _error;

  List<BookMetadata> get books =>
      List.unmodifiable(_books);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> uploadEpub(BuildContext context) async {
    final savedFile =
        await EpubPickerService.pickAndSaveEpub(
      context,
    );

    if (savedFile != null) {
      await loadBooks();
    }
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final booksDirectory =
          await EpubPickerService.getBooksDirectory();

      final loadedBooks = <BookMetadata>[];

      await for (final entity in booksDirectory.list()) {
        if (entity is! File) {
          continue;
        }

        if (path.extension(entity.path).toLowerCase() !=
            '.epub') {
          continue;
        }

        try {
          final bytes = await entity.readAsBytes();

          // Reads metadata without loading all chapters,
          // images, CSS, and fonts.
          final epubReference =
              await EpubReader.openBook(bytes);

          final title = epubReference.Title?.trim();
          final author = epubReference.Author?.trim();

          loadedBooks.add(
            BookMetadata(
              id: path.basename(entity.path),
              filePath: entity.path,
              title: title?.isNotEmpty == true
                  ? title!
                  : _filenameWithoutHash(entity.path),
              author: author?.isNotEmpty == true
                  ? author!
                  : 'Unknown author',
              fileSize: await entity.length(),
            ),
          );
        } catch (error) {
          debugPrint(
            'Unable to read ${entity.path}: $error',
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

  String _filenameWithoutHash(String filePath) {
    final filename =
        path.basenameWithoutExtension(filePath);

    final separator = filename.indexOf('_');

    if (separator == -1) {
      return filename;
    }

    return filename.substring(separator + 1);
  }
}