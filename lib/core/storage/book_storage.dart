import 'book_storage_contract.dart';
import 'book_storage_memory.dart'
    if (dart.library.io) 'book_file_storage.dart';

BookStorage createBookStorage() {
  return PlatformBookStorage();
}