import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

class PickedEpub {
  const PickedEpub({
    required this.name,
    required this.bytes,
  });

  final String name;
  final Uint8List bytes;
}

class EpubPickerService {
  static const XTypeGroup _epubType = XTypeGroup(
    label: 'EPUB books',
    extensions: ['epub'],
    mimeTypes: ['application/epub+zip'],
    uniformTypeIdentifiers: [
      'org.idpf.epub-container',
    ],
  );

  static Future<PickedEpub?> pickEpub() async {
    final selectedFile = await openFile(
      acceptedTypeGroups: const [_epubType],
      confirmButtonText: 'Import',
    );

    if (selectedFile == null) {
      return null;
    }

    final bytes = await selectedFile.readAsBytes();

    return PickedEpub(
      name: selectedFile.name,
      bytes: bytes,
    );
  }
}