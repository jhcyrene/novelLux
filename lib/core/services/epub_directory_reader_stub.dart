import 'dart:typed_data';

import 'epub_directory_file.dart';

Future<String?> pickEpubDirectoryPath() async {
  return null;
}

Future<void> openEpubDirectory(String directoryPath) {
  throw UnsupportedError(
    'Opening EPUB folders is not supported on this platform.',
  );
}

Future<List<EpubDirectoryFile>> findEpubFiles(String directoryPath) async {
  return const [];
}

Future<Uint8List> readLinkedEpubFile(String filePath) {
  throw UnsupportedError(
    'Linked EPUB folders are not supported on this platform.',
  );
}

Future<String> writeLinkedEpubFile({
  required String directoryPath,
  required String name,
  required Uint8List bytes,
}) {
  throw UnsupportedError(
    'Linked EPUB folders are not supported on this platform.',
  );
}
