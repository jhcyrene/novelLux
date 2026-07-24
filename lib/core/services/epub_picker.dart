import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

import 'epub_directory_reader.dart';

typedef NovelSelectionStarted = void Function(int totalFiles);
typedef NovelFileRead =
    void Function(int completedFiles, int totalFiles, String fileName);

class PickedEpub {
  const PickedEpub({required this.name, required this.bytes});

  final String name;
  final Uint8List bytes;
}

class PickedEpubReference {
  const PickedEpubReference({required this.name, required this.filePath});

  final String name;
  final String filePath;

  Future<Uint8List> readAsBytes() {
    return readLinkedEpubFile(filePath);
  }
}

class PickedEpubDirectory {
  const PickedEpubDirectory({required this.path, required this.books});

  final String path;
  final List<PickedEpubReference> books;
}

class EpubPickerService {
  static const XTypeGroup _novelType = XTypeGroup(
    label: 'Novel files',
    extensions: ['epub', 'html', 'htm', 'txt'],
    mimeTypes: ['application/epub+zip', 'text/html', 'text/plain'],
    uniformTypeIdentifiers: [
      'org.idpf.epub-container',
      'public.html',
      'public.plain-text',
    ],
  );

  static Future<PickedEpub?> pickEpub() async {
    final selectedFile = await openFile(
      acceptedTypeGroups: const [_novelType],
      confirmButtonText: 'Import',
    );

    if (selectedFile == null) {
      return null;
    }

    final bytes = await selectedFile.readAsBytes();

    return PickedEpub(name: selectedFile.name, bytes: bytes);
  }

  static Future<List<PickedEpub>> pickEpubs({
    NovelSelectionStarted? onSelectionStarted,
    NovelFileRead? onFileRead,
  }) async {
    final selectedFiles = await openFiles(
      acceptedTypeGroups: const [_novelType],
      confirmButtonText: 'Import',
    );
    final selectedBooks = <PickedEpub>[];

    if (selectedFiles.isNotEmpty) {
      onSelectionStarted?.call(selectedFiles.length);
    }

    for (var index = 0; index < selectedFiles.length; index++) {
      final selectedFile = selectedFiles[index];
      selectedBooks.add(
        PickedEpub(
          name: selectedFile.name,
          bytes: await selectedFile.readAsBytes(),
        ),
      );
      onFileRead?.call(index + 1, selectedFiles.length, selectedFile.name);
    }

    return selectedBooks;
  }

  static Future<PickedEpubDirectory?> pickEpubDirectory() async {
    final directoryPath = await pickEpubDirectoryPath();

    if (directoryPath == null) {
      return null;
    }

    return PickedEpubDirectory(
      path: directoryPath,
      books: await readEpubDirectory(directoryPath),
    );
  }

  static Future<List<PickedEpubReference>> readEpubDirectory(
    String directoryPath,
  ) async {
    final files = await findEpubFiles(directoryPath);

    return files
        .map(
          (file) => PickedEpubReference(name: file.name, filePath: file.path),
        )
        .toList(growable: false);
  }

  static Future<void> openDirectory(String directoryPath) {
    return openEpubDirectory(directoryPath);
  }

  static Future<Uint8List> readEpubFile(String filePath) {
    return readLinkedEpubFile(filePath);
  }

  static Future<String> saveEpubToDirectory({
    required String directoryPath,
    required String name,
    required Uint8List bytes,
  }) {
    return writeLinkedEpubFile(
      directoryPath: directoryPath,
      name: name,
      bytes: bytes,
    );
  }
}
