import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'book_storage_contract.dart';

class PlatformBookStorage implements BookStorage {
  Directory? _booksDirectory;

  @override
  Future<void> initialize() async {
    if (_booksDirectory != null) {
      return;
    }

    final temporaryDirectory =
        await getTemporaryDirectory();

    final booksDirectory = Directory(
      path.join(
        temporaryDirectory.path,
        'NovelLux',
        'books',
      ),
    );

    if (!await booksDirectory.exists()) {
      await booksDirectory.create(recursive: true);
    }

    _booksDirectory = booksDirectory;
  }

  @override
  Future<StoredBookFile> saveEpub({
    required String originalName,
    required Uint8List bytes,
  }) async {
    await initialize();

    final hash = sha256.convert(bytes).toString();
    final safeName = _sanitizeFilename(originalName);
    final id = '${hash}_$safeName';

    final file = File(
      path.join(_booksDirectory!.path, id),
    );

    if (!await file.exists()) {
      await file.writeAsBytes(
        bytes,
        flush: true,
      );
    }

    final statistics = await file.stat();

    return StoredBookFile(
      id: id,
      name: safeName,
      size: statistics.size,
      importedAt: statistics.modified,
    );
  }

  @override
  Future<List<StoredBookFile>> listBooks() async {
    await initialize();

    final books = <StoredBookFile>[];

    await for (final entity
        in _booksDirectory!.list()) {
      if (entity is! File) {
        continue;
      }

      if (path.extension(entity.path).toLowerCase() !=
          '.epub') {
        continue;
      }

      final statistics = await entity.stat();
      final id = path.basename(entity.path);

      books.add(
        StoredBookFile(
          id: id,
          name: _filenameWithoutHash(id),
          size: statistics.size,
          importedAt: statistics.modified,
        ),
      );
    }

    books.sort(
      (first, second) =>
          first.importedAt.compareTo(second.importedAt),
    );

    return books;
  }

  @override
  Future<Uint8List> readBytes(String id) async {
    await initialize();

    final safeId = path.basename(id);

    if (safeId != id) {
      throw ArgumentError('Invalid book identifier.');
    }

    final file = File(
      path.join(_booksDirectory!.path, safeId),
    );

    if (!await file.exists()) {
      throw StateError(
        'The EPUB file is no longer available.',
      );
    }

    return file.readAsBytes();
  }

  @override
  Future<void> deleteBook(String id) async {
    await initialize();

    final safeId = path.basename(id);

    if (safeId != id) {
      throw ArgumentError('Invalid book identifier.');
    }

    final file = File(
      path.join(_booksDirectory!.path, safeId),
    );

    if (await file.exists()) {
      await file.delete();
    }
  }

  String _filenameWithoutHash(String filename) {
    final separator = filename.indexOf('_');

    if (separator == -1) {
      return filename;
    }

    return filename.substring(separator + 1);
  }

  String _sanitizeFilename(String filename) {
    return path.basename(filename).replaceAll(
          RegExp(r'[^a-zA-Z0-9._ -]'),
          '_',
        );
  }
}