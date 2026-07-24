import 'dart:async';
import 'dart:convert';

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

import '../../core/models/book_metadata.dart';
import '../../core/provider/metadata_provider.dart';
import '../../core/provider/reading_progress_provider.dart';
import '../../core/services/plain_text_novel_parser.dart';
import '../../core/theme/app_font.dart';
import 'widgets/contents_sheet.dart';
import 'widgets/reader_content.dart';
import 'widgets/reader_controls.dart';
import 'widgets/reader_status.dart';
import 'widgets/settings.dart';
import 'widgets/topbar.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key, required this.book});

  final BookMetadata book;

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<double> _liveReadingProgress = ValueNotifier(0);

  late ReadingProgressProvider _progressProvider;
  late TemporaryLibraryProvider _libraryProvider;

  List<_ReaderChapter> _chapters = [];
  String _chapterHtml = '';
  int _chapterLoadRequest = 0;
  int _currentChapterIndex = 0;
  double _restoredChapterProgress = 0;

  bool _isClosing = false;
  bool _didStartLoading = false;
  bool _isLoading = true;
  bool _isBookmarked = false;
  String? _error;

  ReadingFontFamily _readingFont = AppFonts.defaultReadingFont;
  double _fontSize = 16;

  _ReaderChapter? get _currentChapter {
    if (_chapters.isEmpty) {
      return null;
    }

    return _chapters[_currentChapterIndex];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_updateLiveReadingProgress);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _progressProvider = context.read<ReadingProgressProvider>();
    _libraryProvider = context.read<TemporaryLibraryProvider>();

    if (!_didStartLoading) {
      _didStartLoading = true;
      unawaited(_loadBook());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveProgress());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_updateLiveReadingProgress);
    _scrollController.dispose();
    _liveReadingProgress.dispose();
    super.dispose();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bytes = await _libraryProvider.readBookBytes(widget.book.id);
      final chapters = await _readChapters(bytes);

      if (chapters.isEmpty) {
        throw Exception('No readable chapters were found.');
      }

      final savedProgress = _progressProvider.progressFor(widget.book.id);
      final savedChapterIndex = savedProgress?.chapterIndex ?? 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _chapters = chapters;
        _currentChapterIndex = savedChapterIndex
            .clamp(0, chapters.length - 1)
            .toInt();
        _restoredChapterProgress = savedProgress?.chapterProgress ?? 0;
        _chapterHtml = '';
      });

      _setLiveReadingProgress(_restoredChapterProgress);
      await _loadCurrentChapter(restorePosition: true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error = 'Unable to open this book: $error';
        _isLoading = false;
      });
    }
  }

  Future<List<_ReaderChapter>> _readChapters(List<int> bytes) async {
    final extension = path.extension(widget.book.filePath).toLowerCase();

    if (extension == '.epub') {
      final epubBook = await EpubReader.openBook(bytes);
      final chapterReferences = <EpubChapterRef>[];
      final chapters = <_ReaderChapter>[];

      _flattenChapterReferences(
        await epubBook.getChapters(),
        chapterReferences,
      );
      chapterReferences.removeWhere(
        (chapter) => chapter.epubTextContentFileRef == null,
      );

      for (var index = 0; index < chapterReferences.length; index++) {
        final chapter = chapterReferences[index];
        final nextFileName = index + 1 < chapterReferences.length
            ? chapterReferences[index + 1].ContentFileName
            : null;

        chapters.add(
          _ReaderChapter(
            title: chapter.Title,
            loadContent: () => _readEpubChapterHtml(
              epubBook,
              chapter,
              nextContentFileName: nextFileName,
            ),
          ),
        );
      }

      return chapters;
    }

    if (extension == '.html' || extension == '.htm') {
      final html = utf8.decode(bytes, allowMalformed: true);
      return [
        _ReaderChapter(title: widget.book.title, loadContent: () async => html),
      ];
    }

    if (extension == '.txt') {
      final text = utf8.decode(bytes, allowMalformed: true);
      final novel = PlainTextNovelParser.parse(text);

      return [
        for (final chapter in novel.chapters)
          _ReaderChapter(
            title: chapter.title,
            loadContent: () async =>
                PlainTextNovelParser.chapterToHtml(chapter.content),
          ),
      ];
    }

    throw UnsupportedError('Unsupported novel format: $extension');
  }

  void _flattenChapterReferences(
    List<EpubChapterRef> source,
    List<EpubChapterRef> destination,
  ) {
    for (final chapter in source) {
      destination.add(chapter);

      final subChapters = chapter.SubChapters;
      if (subChapters != null && subChapters.isNotEmpty) {
        _flattenChapterReferences(subChapters, destination);
      }
    }
  }

  Future<bool> _loadCurrentChapter({required bool restorePosition}) async {
    final chapter = _currentChapter;
    if (chapter == null) {
      return false;
    }

    final request = ++_chapterLoadRequest;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final html = await chapter.loadContent();

      if (!mounted || request != _chapterLoadRequest) {
        return false;
      }

      if (html.trim().isEmpty) {
        throw Exception('This chapter has no readable content.');
      }

      setState(() {
        _chapterHtml = html;
        _isLoading = false;
      });

      if (restorePosition) {
        _restoreScrollPosition();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(0);
          }
          _updateLiveReadingProgress();
        });
      }

      return true;
    } catch (error) {
      if (!mounted || request != _chapterLoadRequest) {
        return false;
      }

      setState(() {
        _error = 'Unable to load this chapter: $error';
        _isLoading = false;
      });
      return false;
    }
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 250), () {
        if (!mounted || !_scrollController.hasClients) {
          return;
        }

        final maximum = _scrollController.position.maxScrollExtent;
        if (maximum <= 0) {
          return;
        }

        final target = maximum * _restoredChapterProgress;
        _scrollController.jumpTo(target.clamp(0.0, maximum).toDouble());
        _updateLiveReadingProgress();
      });
    });
  }

  void _updateLiveReadingProgress() {
    _setLiveReadingProgress(_currentScrollProgress());
  }

  void _refreshProgressAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateLiveReadingProgress();
      }
    });
  }

  void _setLiveReadingProgress(double chapterProgress) {
    if (_chapters.isEmpty) {
      _liveReadingProgress.value = 0;
      return;
    }

    final overallProgress =
        (_currentChapterIndex + chapterProgress) / _chapters.length;
    final normalized = overallProgress.clamp(0.0, 1.0).toDouble();
    final currentPercentage = (_liveReadingProgress.value * 100).round();
    final nextPercentage = (normalized * 100).round();

    if (currentPercentage != nextPercentage) {
      _liveReadingProgress.value = normalized;
    }
  }

  double _currentScrollProgress() {
    if (!_scrollController.hasClients) {
      return _restoredChapterProgress;
    }

    final position = _scrollController.position;
    final maximum = position.maxScrollExtent;

    if (maximum <= 0) {
      return 1;
    }

    return (position.pixels / maximum).clamp(0.0, 1.0).toDouble();
  }

  Future<void> _saveProgress({double? forcedChapterProgress}) async {
    final chapter = _currentChapter;

    if (chapter == null || _chapters.isEmpty) {
      return;
    }

    await _progressProvider.saveProgress(
      bookId: widget.book.id,
      chapterTitle: _chapterTitle(chapter),
      chapterIndex: _currentChapterIndex,
      totalChapters: _chapters.length,
      chapterProgress: forcedChapterProgress ?? _currentScrollProgress(),
    );
  }

  Future<void> _changeChapter(int index) async {
    if (index < 0 ||
        index >= _chapters.length ||
        index == _currentChapterIndex) {
      return;
    }

    final movingForward = index > _currentChapterIndex;
    await _saveProgress(forcedChapterProgress: movingForward ? 1 : null);

    if (!mounted) {
      return;
    }

    setState(() {
      _currentChapterIndex = index;
      _restoredChapterProgress = 0;
      _chapterHtml = '';
    });
    _setLiveReadingProgress(0);

    final loaded = await _loadCurrentChapter(restorePosition: false);
    if (loaded) {
      await _saveProgress(forcedChapterProgress: 0);
    }
  }

  String _chapterTitle(_ReaderChapter chapter, {int? index}) {
    final title = chapter.title?.trim();

    if (title == null || title.isEmpty) {
      return 'Chapter ${(index ?? _currentChapterIndex) + 1}';
    }

    return title;
  }

  Future<void> _closeReader() async {
    if (_isClosing) {
      return;
    }

    _isClosing = true;
    await _saveProgress();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showContents() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return ReaderContentsSheet(
          chapterTitles: [
            for (var index = 0; index < _chapters.length; index++)
              _chapterTitle(_chapters[index], index: index),
          ],
          currentChapter: _currentChapterIndex,
          onChapterSelected: (index) {
            Navigator.of(sheetContext).pop();
            unawaited(_changeChapter(index));
          },
        );
      },
    );
  }

  void _showReaderSettings() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ReaderSettingsSheet(
              readingFont: _readingFont,
              fontSize: _fontSize,
              onFontChanged: (font) {
                setSheetState(() {
                  _readingFont = font;
                });
                setState(() {
                  _readingFont = font;
                });
                _refreshProgressAfterLayout();
              },
              onFontSizeChanged: (fontSize) {
                setSheetState(() {
                  _fontSize = fontSize;
                });
                setState(() {
                  _fontSize = fontSize;
                });
                _refreshProgressAfterLayout();
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _currentChapter;
    final chapterTitle = chapter == null ? null : _chapterTitle(chapter);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          unawaited(_closeReader());
        }
      },
      child: Scaffold(
        appBar: ReaderTopBar(
          bookTitle: widget.book.title,
          chapterTitle: chapterTitle,
          isBookmarked: _isBookmarked,
          onBack: () => unawaited(_closeReader()),
          onBookmark: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
          },
          onMore: () {
            // Additional reader actions can be connected here.
          },
        ),
        body: _buildBody(),
        bottomNavigationBar: chapter == null
            ? null
            : ReaderControls(
                readingProgress: _liveReadingProgress,
                onContents: _showContents,
                onStart: !_isLoading && _currentChapterIndex > 0
                    ? () => unawaited(_changeChapter(0))
                    : null,
                onPrevious: !_isLoading && _currentChapterIndex > 0
                    ? () => unawaited(_changeChapter(_currentChapterIndex - 1))
                    : null,
                onNext:
                    !_isLoading && _currentChapterIndex < _chapters.length - 1
                    ? () => unawaited(_changeChapter(_currentChapterIndex + 1))
                    : null,
                onEnd:
                    !_isLoading && _currentChapterIndex < _chapters.length - 1
                    ? () => unawaited(_changeChapter(_chapters.length - 1))
                    : null,
                onSettings: _showReaderSettings,
              ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ReaderLoadingView();
    }

    if (_error != null) {
      return ReaderErrorView(
        message: _error!,
        onRetry: () => unawaited(_loadBook()),
      );
    }

    final chapter = _currentChapter;
    if (chapter == null) {
      return const ReaderEmptyView();
    }

    return ReaderContent(
      scrollController: _scrollController,
      chapterTitle: _chapterTitle(chapter),
      htmlContent: _chapterHtml,
      readingFont: _readingFont,
      fontSize: _fontSize,
      onScrollEnd: _saveProgress,
    );
  }
}

class _ReaderChapter {
  const _ReaderChapter({required this.title, required this.loadContent});

  final String? title;
  final Future<String> Function() loadContent;
}

Future<String> _readEpubChapterHtml(
  EpubBookRef book,
  EpubChapterRef chapter, {
  String? nextContentFileName,
}) async {
  final chapterFileName = chapter.ContentFileName;
  final spineFiles = _epubSpineFiles(book);
  final chapterIndex = chapterFileName == null
      ? -1
      : spineFiles.indexOf(chapterFileName);
  final nextChapterIndex = nextContentFileName == null
      ? spineFiles.length
      : spineFiles.indexOf(nextContentFileName);
  final filesToRead = chapterIndex >= 0
      ? spineFiles.sublist(
          chapterIndex,
          nextChapterIndex > chapterIndex ? nextChapterIndex : chapterIndex + 1,
        )
      : <String>[];

  if (filesToRead.isEmpty && chapterFileName != null) {
    filesToRead.add(chapterFileName);
  }

  final sections = <String>[];
  final htmlFiles = book.Content?.Html;

  for (final fileName in filesToRead) {
    final contentReference = htmlFiles?[fileName];
    final rawHtml = contentReference == null
        ? fileName == chapterFileName
              ? await chapter.readHtmlContent()
              : null
        : await contentReference.readContentAsText();

    if (rawHtml == null) {
      continue;
    }

    final resolvedHtml = await _resolveEpubImages(book, rawHtml, fileName);
    sections.add(_htmlBody(resolvedHtml));
  }

  return sections.isEmpty ? chapter.readHtmlContent() : sections.join('\n');
}

List<String> _epubSpineFiles(EpubBookRef book) {
  final spineItems = book.Schema?.Package?.Spine?.Items ?? const [];
  final manifestItems = book.Schema?.Package?.Manifest?.Items ?? const [];
  final files = <String>[];

  for (final spineItem in spineItems) {
    for (final manifestItem in manifestItems) {
      if (manifestItem.Id == spineItem.IdRef &&
          manifestItem.Href != null &&
          book.Content?.Html?.containsKey(manifestItem.Href) == true) {
        files.add(manifestItem.Href!);
        break;
      }
    }
  }

  return files;
}

String _htmlBody(String html) {
  return RegExp(
        r'<body\b[^>]*>(.*?)</body>',
        caseSensitive: false,
        dotAll: true,
      ).firstMatch(html)?.group(1) ??
      html;
}

Future<String> _resolveEpubImages(
  EpubBookRef book,
  String sourceHtml,
  String contentFileName,
) async {
  var html = sourceHtml;
  final images = book.Content?.Images;

  if (images == null || images.isEmpty) {
    return html;
  }

  final imageSources = RegExp(
    r'''(?:src|href)\s*=\s*(["'])(.*?)\1''',
    caseSensitive: false,
  ).allMatches(html).map((match) => match.group(2)!).toSet();
  final chapterDirectory = path.posix.dirname(contentFileName);

  for (final source in imageSources) {
    if (source.startsWith('data:') ||
        source.startsWith('http://') ||
        source.startsWith('https://')) {
      continue;
    }

    final sourcePath = source.split(RegExp(r'[?#]')).first;
    String decodedSource;
    try {
      decodedSource = Uri.decodeComponent(sourcePath);
    } on FormatException {
      decodedSource = sourcePath;
    }

    final resolvedPath = path.posix.normalize(
      path.posix.join(chapterDirectory, decodedSource),
    );
    var imageReference = images[resolvedPath] ?? images[decodedSource];

    if (imageReference == null) {
      for (final entry in images.entries) {
        if (entry.key.toLowerCase() == resolvedPath.toLowerCase()) {
          imageReference = entry.value;
          break;
        }
      }
    }

    if (imageReference == null) {
      continue;
    }

    final imageBytes = await imageReference.readContent();
    final mimeType =
        imageReference.ContentMimeType ?? _imageMimeType(resolvedPath);
    final dataUri = 'data:$mimeType;base64,${base64Encode(imageBytes)}';

    html = html
        .replaceAll('"$source"', '"$dataUri"')
        .replaceAll("'$source'", "'$dataUri'");
  }

  return html;
}

String _imageMimeType(String fileName) {
  switch (path.posix.extension(fileName).toLowerCase()) {
    case '.png':
      return 'image/png';
    case '.gif':
      return 'image/gif';
    case '.svg':
      return 'image/svg+xml';
    case '.webp':
      return 'image/webp';
    case '.bmp':
      return 'image/bmp';
    default:
      return 'image/jpeg';
  }
}
