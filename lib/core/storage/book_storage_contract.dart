import 'dart:typed_data';

class StoredBookFile {
  const StoredBookFile({
    required this.id,
    required this.name,
    required this.size,
    required this.importedAt,
  });

  final String id;
  final String name;
  final int size;
  final DateTime importedAt;
}

abstract interface class BookStorage {
  Future<void> initialize();

  Future<StoredBookFile> saveBook({
    required String originalName,
    required Uint8List bytes,
  });

  Future<List<StoredBookFile>> listBooks();

  Future<Uint8List> readBytes(String id);

  Future<void> deleteBook(String id);
}
