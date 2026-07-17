import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class EpubPickerService {
  static const XTypeGroup _epubType = XTypeGroup(
    label: 'EPUB books',
    extensions: ['epub'],
    mimeTypes: ['application/epub+zip'],
    uniformTypeIdentifiers: ['org.idpf.epub-container'],
  );

  static Future<File?> pickAndSaveEpub(
    BuildContext context,
  ) async {
    try {
      final selectedFile = await openFile(
        acceptedTypeGroups: const [_epubType],
        confirmButtonText: 'Import',
      );

      if (selectedFile == null) {
        return null;
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

      final selectedBytes = await selectedFile.readAsBytes();
      final selectedHash =
      sha256.convert(selectedBytes).toString();

      final duplicateFile = await _findDuplicate(
        booksDirectory,
        selectedHash,
      );

      if (duplicateFile != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${selectedFile.name} is already uploaded.',
              ),
            ),
          );
        }

        return duplicateFile;
      }

      final safeFilename =
      _sanitizeFilename(selectedFile.name);

      final destinationPath = path.join(
        booksDirectory.path,
        '${selectedHash}_$safeFilename',
      );

      final savedFile = File(destinationPath);

      await savedFile.writeAsBytes(
        selectedBytes,
        flush: true,
      );

      if (!context.mounted) {
        return savedFile;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saved temporarily: ${selectedFile.name}',
          ),
        ),
      );

      return savedFile;
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to import EPUB: $error',
            ),
          ),
        );
      }

      return null;
    }
  }

  static Future<File?> _findDuplicate(
      Directory booksDirectory,
      String selectedHash,
      ) async {
    await for (final entity in booksDirectory.list()) {
      if (entity is! File) {
        continue;
      }

      if (path.extension(entity.path).toLowerCase() !=
          '.epub') {
        continue;
      }

      final existingBytes = await entity.readAsBytes();
      final existingHash =
      sha256.convert(existingBytes).toString();

      if (existingHash == selectedHash) {
        return entity;
      }
    }

    return null;
  }

  static String _sanitizeFilename(String filename) {
    return path.basename(filename).replaceAll(
          RegExp(r'[^a-zA-Z0-9._ -]'),
          '_',
        );
  }
}