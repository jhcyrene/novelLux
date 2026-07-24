import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import 'epub_directory_file.dart';

const MethodChannel _androidDirectoryChannel = MethodChannel(
  'novellux/epub_directory',
);

Future<String?> pickEpubDirectoryPath() async {
  if (Platform.isAndroid) {
    return _androidDirectoryChannel.invokeMethod<String>('pickDirectory');
  }

  return getDirectoryPath(confirmButtonText: 'Choose folder');
}

Future<void> openEpubDirectory(String directoryPath) async {
  if (Platform.isAndroid) {
    await _androidDirectoryChannel.invokeMethod<void>(
      'openDirectory',
      directoryPath,
    );
    return;
  }

  final directory = Directory(directoryPath);

  if (!await directory.exists()) {
    throw FileSystemException(
      'The linked novel folder is unavailable.',
      directoryPath,
    );
  }

  if (Platform.isWindows) {
    await Process.start('explorer.exe', [
      directoryPath,
    ], mode: ProcessStartMode.detached);
    return;
  }

  if (Platform.isMacOS) {
    await Process.start('open', [
      directoryPath,
    ], mode: ProcessStartMode.detached);
    return;
  }

  if (Platform.isLinux) {
    await Process.start('xdg-open', [
      directoryPath,
    ], mode: ProcessStartMode.detached);
    return;
  }

  throw UnsupportedError(
    'Opening linked novel folders is not supported on this platform.',
  );
}

Future<List<EpubDirectoryFile>> findEpubFiles(String directoryPath) async {
  if (Platform.isAndroid) {
    final entries = await _androidDirectoryChannel.invokeListMethod<Object?>(
      'listEpubFiles',
      directoryPath,
    );

    final files = <EpubDirectoryFile>[];

    for (final entry in entries ?? const []) {
      if (entry is! Map) {
        continue;
      }

      final name = entry['name'];
      final filePath = entry['path'];

      if (name is String && filePath is String) {
        files.add(EpubDirectoryFile(name: name, path: filePath));
      }
    }

    return files;
  }

  final directory = Directory(directoryPath);

  if (!await directory.exists()) {
    throw FileSystemException(
      'The selected directory is unavailable.',
      directoryPath,
    );
  }

  final epubFiles = <EpubDirectoryFile>[];

  await for (final entity in directory.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is File &&
        const {
          '.epub',
          '.html',
          '.htm',
          '.txt',
        }.contains(path.extension(entity.path).toLowerCase())) {
      epubFiles.add(
        EpubDirectoryFile(name: path.basename(entity.path), path: entity.path),
      );
    }
  }

  epubFiles.sort(
    (first, second) =>
        first.name.toLowerCase().compareTo(second.name.toLowerCase()),
  );

  return epubFiles;
}

Future<Uint8List> readLinkedEpubFile(String filePath) async {
  if (Platform.isAndroid) {
    final bytes = await _androidDirectoryChannel.invokeMethod<Uint8List>(
      'readEpubFile',
      filePath,
    );

    if (bytes == null) {
      throw FileSystemException('Unable to read the linked novel.', filePath);
    }

    return bytes;
  }

  return File(filePath).readAsBytes();
}

Future<String> writeLinkedEpubFile({
  required String directoryPath,
  required String name,
  required Uint8List bytes,
}) async {
  if (Platform.isAndroid) {
    final fileUri = await _androidDirectoryChannel.invokeMethod<String>(
      'writeEpubFile',
      <String, Object>{
        'directoryPath': directoryPath,
        'name': name,
        'bytes': bytes,
      },
    );

    if (fileUri == null) {
      throw FileSystemException(
        'Unable to save the novel in the linked folder.',
        directoryPath,
      );
    }

    return fileUri;
  }

  final safeName = path.basename(name);
  final file = File(path.join(directoryPath, safeName));
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}
