import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import 'book_storage_contract.dart';

class PlatformBookStorage implements BookStorage { // for browser
  final Map<String, _MemoryBook> _books =
      LinkedHashMap<String, _MemoryBook>();

  @override
  Future<void> initialize() async {
    // Browser memory storage needs no initialization.
  }

  @override
  Future<StoredBookFile> saveEpub({
    required String originalName,
    required Uint8List bytes,
  }) async {
    final hash = sha256.convert(bytes).toString();
    final safeName = _sanitizeFilename(originalName);
    final id = '${hash}_$safeName';

    final existingBook = _books[id];

    if (existingBook != null) {
      return existingBook.file;
    }

    final storedFile = StoredBookFile(
      id: id,
      name: safeName,
      size: bytes.length,
      importedAt: DateTime.now(),
    );

    _books[id] = _MemoryBook(
      file: storedFile,
      bytes: Uint8List.fromList(bytes),
    );

    return storedFile;
  }

  @override
  Future<List<StoredBookFile>> listBooks() async {
    final books = _books.values
        .map((book) => book.file)
        .toList();

    books.sort(
      (first, second) =>
          first.importedAt.compareTo(second.importedAt),
    );

    return books;
  }

  @override
  Future<Uint8List> readBytes(String id) async {
    final book = _books[id];

    if (book == null) {
      throw StateError(
        'The EPUB is no longer available in browser memory.',
      );
    }

    return Uint8List.fromList(book.bytes);
  }

  @override
  Future<void> deleteBook(String id) async {
    _books.remove(id);
  }

  String _sanitizeFilename(String filename) {
    return path.basename(filename).replaceAll(
          RegExp(r'[^a-zA-Z0-9._ -]'),
          '_',
        );
  }
}

class _MemoryBook {
  const _MemoryBook({
    required this.file,
    required this.bytes,
  });

  final StoredBookFile file;
  final Uint8List bytes;
}