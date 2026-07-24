import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:epubx/epubx.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_metadata.dart';
import '../services/epub_picker.dart';
import '../services/plain_text_novel_parser.dart';
import '../storage/book_storage.dart';
import '../storage/book_storage_contract.dart';
import '../widgets/import_progress_dialog.dart';
import '../widgets/snackbar.dart';

class TemporaryLibraryProvider extends ChangeNotifier {
  static const String _linkedDirectoryKey = 'novellux_linked_epub_directory';

  TemporaryLibraryProvider({BookStorage? storage})
    : _storage = storage ?? createBookStorage();

  final BookStorage _storage;
  final List<BookMetadata> _books = [];
  final Map<String, String> _linkedBookPaths = {};

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  List<BookMetadata> get books => List.unmodifiable(_books);

  bool get isLoading => _isLoading;

  String? get error => _error;

  Future<void> openLinkedEpubDirectory(BuildContext context) async {
    if (kIsWeb) {
      SnackBarNotif.show(
        context,
        message: 'Opening the linked novel folder is not available on the web.',
        type: SnackBarType.warning,
      );
      return;
    }

    try {
      final preferences = await SharedPreferences.getInstance();
      final linkedDirectoryPath = preferences.getString(_linkedDirectoryKey);

      if (linkedDirectoryPath == null || linkedDirectoryPath.isEmpty) {
        if (context.mounted) {
          SnackBarNotif.show(
            context,
            message: 'Link a novel folder first.',
            type: SnackBarType.warning,
          );
        }
        return;
      }

      await EpubPickerService.openDirectory(linkedDirectoryPath);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      SnackBarNotif.error(context, 'Unable to open the novel folder: $error');
    }
  }

  Future<void> uploadEpub(BuildContext context) async {
    ValueNotifier<ImportProgressData>? progress;
    BuildContext? progressDialogContext;
    Future<void>? progressDialog;

    void showProgress(int totalFiles) {
      if (!context.mounted || progress != null) {
        return;
      }

      final notifier = ValueNotifier(
        ImportProgressData(
          progress: 0,
          status: kIsWeb
              ? 'Loading files from your browser…'
              : 'Preparing your books…',
          totalFiles: totalFiles,
        ),
      );
      progress = notifier;
      progressDialog = showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          progressDialogContext = dialogContext;
          return ImportProgressDialog(progress: notifier);
        },
      );
    }

    Future<void> closeProgress() async {
      final notifier = progress;
      if (notifier == null) {
        return;
      }

      if (progressDialogContext == null) {
        await WidgetsBinding.instance.endOfFrame;
      }

      final dialogContext = progressDialogContext;
      if (dialogContext != null && dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      final dialog = progressDialog;
      if (dialog != null) {
        await dialog;
      }

      notifier.dispose();
      progress = null;
      progressDialog = null;
      progressDialogContext = null;
    }

    try {
      String? linkedDirectoryPath;

      if (!kIsWeb) {
        final preferences = await SharedPreferences.getInstance();
        linkedDirectoryPath = preferences.getString(_linkedDirectoryKey);

        if (linkedDirectoryPath == null || linkedDirectoryPath.isEmpty) {
          if (context.mounted) {
            SnackBarNotif.show(
              context,
              message: 'Link a novel folder before uploading a book.',
              type: SnackBarType.warning,
            );
          }
          return;
        }
      }

      final selectedBooks = kIsWeb
          ? await EpubPickerService.pickEpubs(
              onSelectionStarted: showProgress,
              onFileRead: (completed, total, fileName) {
                progress?.value = ImportProgressData(
                  progress: completed / (total * 2 + 1),
                  status: 'Loading $completed of $total from your browser',
                  fileName: fileName,
                  currentFile: completed,
                  totalFiles: total,
                );
              },
            )
          : [?await EpubPickerService.pickEpub()];

      if (selectedBooks.isEmpty) {
        return;
      }

      if (!context.mounted) {
        return;
      }

      showProgress(selectedBooks.length);

      await WidgetsBinding.instance.endOfFrame;

      if (kIsWeb) {
        await _ensureInitialized();
      }

      final totalWork = kIsWeb
          ? selectedBooks.length * 2 + 1
          : selectedBooks.length + 1;
      final completedReadWork = kIsWeb ? selectedBooks.length : 0;

      for (var index = 0; index < selectedBooks.length; index++) {
        final selectedBook = selectedBooks[index];
        progress?.value = ImportProgressData(
          progress: (completedReadWork + index) / totalWork,
          status: 'Importing ${index + 1} of ${selectedBooks.length}',
          fileName: selectedBook.name,
          currentFile: index + 1,
          totalFiles: selectedBooks.length,
        );

        if (kIsWeb) {
          await _storage.saveBook(
            originalName: selectedBook.name,
            bytes: selectedBook.bytes,
          );
        } else {
          await EpubPickerService.saveEpubToDirectory(
            directoryPath: linkedDirectoryPath!,
            name: selectedBook.name,
            bytes: selectedBook.bytes,
          );
        }

        progress?.value = ImportProgressData(
          progress: (completedReadWork + index + 1) / totalWork,
          status: 'Imported ${index + 1} of ${selectedBooks.length}',
          fileName: selectedBook.name,
          currentFile: index + 1,
          totalFiles: selectedBooks.length,
        );
      }

      progress?.value = ImportProgressData(
        progress: (totalWork - 1) / totalWork,
        status: 'Updating your library…',
        currentFile: selectedBooks.length,
        totalFiles: selectedBooks.length,
      );

      await loadBooks();

      progress?.value = ImportProgressData(
        progress: 1,
        status: 'Import complete',
        currentFile: selectedBooks.length,
        totalFiles: selectedBooks.length,
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      await closeProgress();

      if (!context.mounted) {
        return;
      }

      SnackBarNotif.success(
        context,
        kIsWeb
            ? selectedBooks.length == 1
                  ? '${selectedBooks.single.name} is ready to read.'
                  : '${selectedBooks.length} novels are ready to read.'
            : '${selectedBooks.single.name} was saved to the linked folder.',
      );
    } catch (error) {
      await closeProgress();

      if (!context.mounted) {
        return;
      }

      SnackBarNotif.error(context, 'Unable to import novel: $error');
    } finally {
      await closeProgress();
    }
  }

  Future<void> linkEpubDirectory(BuildContext context) async {
    try {
      final selectedDirectory = await EpubPickerService.pickEpubDirectory();

      if (selectedDirectory == null) {
        return;
      }

      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_linkedDirectoryKey, selectedDirectory.path);

      await loadBooks();

      if (!context.mounted) {
        return;
      }

      SnackBarNotif.success(
        context,
        selectedDirectory.books.isEmpty
            ? 'Linked the novel folder. Uploaded books will be saved there.'
            : 'Linked ${selectedDirectory.books.length} '
                  '${selectedDirectory.books.length == 1 ? 'book' : 'books'} '
                  'from the selected folder.',
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      SnackBarNotif.error(context, 'Unable to read novel folder: $error');
    }
  }

  Future<void> loadBooks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _ensureInitialized();

      final loadedBooks = <BookMetadata>[];
      _linkedBookPaths.clear();

      final preferences = await SharedPreferences.getInstance();
      final linkedDirectoryPath = kIsWeb
          ? null
          : preferences.getString(_linkedDirectoryKey);

      if (linkedDirectoryPath == null || linkedDirectoryPath.isEmpty) {
        final storedBooks = await _storage.listBooks();

        for (final storedBook in storedBooks) {
          try {
            final bytes = await _storage.readBytes(storedBook.id);
            loadedBooks.add(
              await _readBookMetadata(
                id: storedBook.id,
                fileName: storedBook.name,
                bytes: bytes,
              ),
            );
          } catch (error) {
            debugPrint('Unable to read ${storedBook.name}: $error');
          }
        }
      } else {
        try {
          final linkedBooks = await EpubPickerService.readEpubDirectory(
            linkedDirectoryPath,
          );

          for (final linkedBook in linkedBooks) {
            try {
              final bytes = await linkedBook.readAsBytes();
              final bookId =
                  'linked-${sha256.convert(utf8.encode(linkedBook.filePath))}';

              _linkedBookPaths[bookId] = linkedBook.filePath;

              loadedBooks.add(
                await _readBookMetadata(
                  id: bookId,
                  fileName: linkedBook.name,
                  bytes: bytes,
                ),
              );
            } catch (error) {
              debugPrint('Unable to read ${linkedBook.name}: $error');
            }
          }
        } catch (error) {
          debugPrint('Unable to access linked novel folder: $error');
        }
      }

      loadedBooks.sort((first, second) => first.title.compareTo(second.title));

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

  Future<BookMetadata> loadBookDetails(BookMetadata book) async {
    if (book.id.startsWith('sample-')) {
      return book;
    }

    final bytes = await readBookBytes(book.id);
    return _readBookMetadata(
      id: book.id,
      fileName: book.filePath,
      bytes: bytes,
      fallback: book,
      includeChapters: true,
    );
  }

  Future<Uint8List> readBookBytes(String bookId) async {
    final linkedPath = _linkedBookPaths[bookId];

    if (linkedPath != null) {
      return EpubPickerService.readEpubFile(linkedPath);
    }

    await _ensureInitialized();

    return _storage.readBytes(bookId);
  }

  Future<void> deleteBook(String bookId) async {
    if (_linkedBookPaths.containsKey(bookId)) {
      throw UnsupportedError(
        'Linked books must be removed from their original folder.',
      );
    }

    await _ensureInitialized();
    await _storage.deleteBook(bookId);
    await loadBooks();
  }

  Future<void> _ensureInitialized() async {
    if (_isInitialized) {
      return;
    }

    await _storage.initialize();
    _isInitialized = true;
  }
}

Future<BookMetadata> _readBookMetadata({
  required String id,
  required String fileName,
  required Uint8List bytes,
  BookMetadata? fallback,
  bool includeChapters = false,
}) async {
  final extension = path.extension(fileName).toLowerCase();
  final fallbackTitle =
      fallback?.title ?? path.basenameWithoutExtension(fileName);

  if (extension == '.epub') {
    final epubReference = await EpubReader.openBook(bytes);
    final metadata = epubReference.Schema?.Package?.Metadata;
    final tags = _normalizeTags(metadata?.Subjects);
    final title = epubReference.Title?.trim();
    final author = epubReference.Author?.trim();

    return BookMetadata(
      id: id,
      filePath: fileName,
      title: title?.isNotEmpty == true ? title! : fallbackTitle,
      author: author?.isNotEmpty == true
          ? author!
          : fallback?.author ?? 'Unknown author',
      fileSize: bytes.length,
      tags: tags.isEmpty ? fallback?.tags ?? const [] : tags,
      chapterTitles: includeChapters
          ? _readChapterTitles(await epubReference.getChapters())
          : const [],
      description:
          _cleanDescription(metadata?.Description) ?? fallback?.description,
      publisher:
          _firstMetadataValue(metadata?.Publishers) ?? fallback?.publisher,
      language: _firstMetadataValue(metadata?.Languages) ?? fallback?.language,
      publicationDate: fallback?.publicationDate,
    );
  }

  if (extension == '.html' || extension == '.htm') {
    final html = utf8.decode(bytes, allowMalformed: true);
    final title = _htmlElement(html, 'title');
    final author = _htmlMetadata(html, 'author');
    final description = _htmlMetadata(html, 'description');
    final keywords = _htmlMetadata(html, 'keywords');
    final language = _htmlAttribute(html, 'html', 'lang') ?? fallback?.language;

    return BookMetadata(
      id: id,
      filePath: fileName,
      title: title ?? fallbackTitle,
      author: author ?? fallback?.author ?? 'Unknown author',
      fileSize: bytes.length,
      tags: keywords == null
          ? fallback?.tags ?? const []
          : _normalizeTags(keywords.split(RegExp(r'[,;]'))),
      chapterTitles: includeChapters ? const ['Content'] : const [],
      description: description ?? fallback?.description,
      publisher: _htmlMetadata(html, 'publisher') ?? fallback?.publisher,
      language: language,
      publicationDate: _htmlMetadata(html, 'date') ?? fallback?.publicationDate,
    );
  }

  if (extension == '.txt') {
    final novel = PlainTextNovelParser.parse(
      utf8.decode(bytes, allowMalformed: true),
    );

    return BookMetadata(
      id: id,
      filePath: fileName,
      title: novel.title ?? fallbackTitle,
      author: novel.author ?? fallback?.author ?? 'Unknown author',
      fileSize: bytes.length,
      tags: fallback?.tags ?? const [],
      chapterTitles: includeChapters
          ? List.unmodifiable(novel.chapters.map((chapter) => chapter.title))
          : const [],
      description: fallback?.description,
      publisher: novel.publisher ?? fallback?.publisher,
      language: novel.language ?? fallback?.language,
      publicationDate: novel.publicationDate ?? fallback?.publicationDate,
    );
  }

  throw UnsupportedError('Unsupported novel format: $extension');
}

List<String> _normalizeTags(Iterable<String>? subjects) {
  if (subjects == null) {
    return const [];
  }

  final tags = <String>[];
  final normalizedTags = <String>{};

  for (final subject in subjects) {
    final tag = subject.trim();
    final normalizedTag = tag.toLowerCase();

    if (tag.isEmpty || !normalizedTags.add(normalizedTag)) {
      continue;
    }

    tags.add(tag);
  }

  return List.unmodifiable(tags);
}

List<String> _readChapterTitles(List<EpubChapterRef> chapters) {
  final titles = <String>[];

  void addChapters(List<EpubChapterRef> chapterList) {
    for (final chapter in chapterList) {
      final title = chapter.Title?.trim();

      if (title?.isNotEmpty == true) {
        titles.add(title!);
      }

      final subChapters = chapter.SubChapters;
      if (subChapters != null && subChapters.isNotEmpty) {
        addChapters(subChapters);
      }
    }
  }

  addChapters(chapters);
  return List.unmodifiable(titles);
}

String? _cleanDescription(String? description) {
  if (description == null) {
    return null;
  }

  final cleaned = description
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  return cleaned.isEmpty ? null : cleaned;
}

String? _firstMetadataValue(Iterable<String>? values) {
  if (values == null) {
    return null;
  }

  for (final value in values) {
    final cleaned = value.trim();
    if (cleaned.isNotEmpty) {
      return cleaned;
    }
  }

  return null;
}

String? _htmlElement(String html, String element) {
  final match = RegExp(
    '<$element\\b[^>]*>(.*?)</$element>',
    caseSensitive: false,
    dotAll: true,
  ).firstMatch(html);

  return _cleanDescription(match?.group(1));
}

String? _htmlMetadata(String html, String name) {
  for (final match in RegExp(
    r'<meta\b[^>]*>',
    caseSensitive: false,
  ).allMatches(html)) {
    final tag = match.group(0)!;
    final metadataName =
        _attributeValue(tag, 'name') ?? _attributeValue(tag, 'property');

    if (metadataName?.toLowerCase() == name.toLowerCase()) {
      return _cleanDescription(_attributeValue(tag, 'content'));
    }
  }

  return null;
}

String? _htmlAttribute(String html, String element, String attribute) {
  final tag = RegExp(
    '<$element\\b[^>]*>',
    caseSensitive: false,
  ).firstMatch(html)?.group(0);

  return tag == null ? null : _attributeValue(tag, attribute);
}

String? _attributeValue(String tag, String attribute) {
  final match = RegExp(
    '$attribute\\s*=\\s*([\'"])(.*?)\\1',
    caseSensitive: false,
  ).firstMatch(tag);
  final value = match?.group(2)?.trim();

  return value?.isNotEmpty == true ? value : null;
}
