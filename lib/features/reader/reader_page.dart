import 'dart:async';

import 'package:epubx/epubx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

import '../../core/models/book_metadata.dart';
import '../../core/provider/metadata_provider.dart';
import '../../core/provider/reading_progress_provider.dart';
import '../../core/theme/app_font.dart';
import '../../core/theme/app_theme.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({
    super.key,
    required this.book,
  });

  final BookMetadata book;

  @override
  State<ReaderPage> createState() =>
      _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage>
    with WidgetsBindingObserver {
  bool _isClosing = false;
  bool _didStartLoading = false;

  final ScrollController _scrollController =
      ScrollController();

  late ReadingProgressProvider _progressProvider;
  late TemporaryLibraryProvider _libraryProvider;

  List<EpubChapter> _chapters = [];

  int _currentChapterIndex = 0;
  double _restoredChapterProgress = 0;

  bool _isLoading = true;
  String? _error;

  ReadingFontFamily _readingFont =
      AppFonts.defaultReadingFont;

  double _fontSize = 20;

  EpubChapter? get _currentChapter {
    if (_chapters.isEmpty) {
      return null;
    }

    return _chapters[_currentChapterIndex];
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _progressProvider =
        context.read<ReadingProgressProvider>();

    _libraryProvider =
        context.read<TemporaryLibraryProvider>();

    if (!_didStartLoading) {
      _didStartLoading = true;
      unawaited(_loadBook());
    }
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_saveProgress());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _loadBook() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final bytes =
          await _libraryProvider.readBookBytes(
        widget.book.id,
      );

      final epubBook =
          await EpubReader.readBook(bytes);

      final chapters = <EpubChapter>[];

      _flattenChapters(
        epubBook.Chapters ?? const [],
        chapters,
      );

      chapters.removeWhere(
        (chapter) =>
            chapter.HtmlContent == null ||
            chapter.HtmlContent!.trim().isEmpty,
      );

      if (chapters.isEmpty) {
        throw Exception(
          'No readable chapters were found.',
        );
      }

      final savedProgress =
          _progressProvider.progressFor(
        widget.book.id,
      );

      final savedChapterIndex =
          savedProgress?.chapterIndex ?? 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _chapters = chapters;

        _currentChapterIndex =
            savedChapterIndex
                .clamp(0, chapters.length - 1)
                .toInt();

        _restoredChapterProgress =
            savedProgress?.chapterProgress ?? 0;

        _isLoading = false;
      });

      _restoreScrollPosition();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _error =
            'Unable to open this book: $error';
        _isLoading = false;
      });
    }
  }

  void _flattenChapters(
    List<EpubChapter> source,
    List<EpubChapter> destination,
  ) {
    for (final chapter in source) {
      destination.add(chapter);

      final subChapters = chapter.SubChapters;

      if (subChapters != null &&
          subChapters.isNotEmpty) {
        _flattenChapters(
          subChapters,
          destination,
        );
      }
    }
  }

  void _restoreScrollPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(
        const Duration(milliseconds: 250),
        () {
          if (!mounted ||
              !_scrollController.hasClients) {
            return;
          }

          final maximum = _scrollController
              .position.maxScrollExtent;

          if (maximum <= 0) {
            return;
          }

          final target =
              maximum * _restoredChapterProgress;

          _scrollController.jumpTo(
            target
                .clamp(0.0, maximum)
                .toDouble(),
          );
        },
      );
    });
  }

  double _currentScrollProgress() {
    if (!_scrollController.hasClients) {
      return _restoredChapterProgress;
    }

    final position = _scrollController.position;
    final maximum = position.maxScrollExtent;

    if (maximum <= 0) {
      return 0;
    }

    return (position.pixels / maximum)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Future<void> _saveProgress({
    double? forcedChapterProgress,
  }) async {
    final chapter = _currentChapter;

    if (chapter == null || _chapters.isEmpty) {
      return;
    }

    await _progressProvider.saveProgress(
      bookId: widget.book.id,
      chapterTitle: _chapterTitle(chapter),
      chapterIndex: _currentChapterIndex,
      totalChapters: _chapters.length,
      chapterProgress:
          forcedChapterProgress ??
              _currentScrollProgress(),
    );
  }

  Future<void> _changeChapter(int index) async {
    if (index < 0 ||
        index >= _chapters.length ||
        index == _currentChapterIndex) {
      return;
    }

    final movingForward =
        index > _currentChapterIndex;

    await _saveProgress(
      forcedChapterProgress:
          movingForward ? 1 : null,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _currentChapterIndex = index;
      _restoredChapterProgress = 0;
    });

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });

    await _saveProgress(
      forcedChapterProgress: 0,
    );
  }

  String _chapterTitle(EpubChapter chapter) {
    final title = chapter.Title?.trim();

    if (title == null || title.isEmpty) {
      return 'Chapter '
          '${_currentChapterIndex + 1}';
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
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.sizeOf(context).height *
                    0.72,
            child: Column(
              children: [
                Text(
                  'Contents',
                  style: AppFonts.sectionHeading(
                    context,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chapters.length,
                    itemBuilder:
                        (context, index) {
                      final selected =
                          index ==
                              _currentChapterIndex;

                      return ListTile(
                        selected: selected,
                        selectedColor:
                            AppColors.gold,
                        leading: Text(
                          '${index + 1}',
                          style:
                              AppFonts.metadata(
                            context,
                            color: selected
                                ? AppColors.gold
                                : null,
                          ),
                        ),
                        title: Text(
                          _chapterTitle(
                            _chapters[index],
                          ),
                          maxLines: 2,
                          overflow:
                              TextOverflow.ellipsis,
                          style: AppFonts.body(
                            context,
                            fontSize: 14,
                            color: selected
                                ? AppColors.gold
                                : null,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(
                            sheetContext,
                          ).pop();

                          _changeChapter(index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading appearance',
                      style:
                          AppFonts.sectionHeading(
                        context,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Font',
                      style: AppFonts.body(
                        context,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<
                        ReadingFontFamily>(
                      initialValue: _readingFont,
                      decoration:
                          const InputDecoration(
                        isDense: true,
                      ),
                      items: ReadingFontFamily.values
                          .map(
                            (font) =>
                                DropdownMenuItem(
                              value: font,
                              child: Text(
                                font.displayName,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (font) {
                        if (font == null) {
                          return;
                        }

                        setSheetState(() {
                          _readingFont = font;
                        });

                        setState(() {
                          _readingFont = font;
                        });
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'A',
                          style: AppFonts.body(
                            context,
                            fontSize: 14,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _fontSize,
                            min: 16,
                            max: 28,
                            divisions: 12,
                            activeColor:
                                AppColors.gold,
                            label: _fontSize
                                .round()
                                .toString(),
                            onChanged: (value) {
                              setSheetState(() {
                                _fontSize = value;
                              });

                              setState(() {
                                _fontSize = value;
                              });
                            },
                          ),
                        ),
                        Text(
                          'A',
                          style: AppFonts.body(
                            context,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _currentChapter;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        if (didPop) {
          return;
        }

        unawaited(_closeReader());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: _closeReader,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
            ),
          ),
          centerTitle: true,
          title: Column(
            children: [
              Text(
                widget.book.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: AppFonts.bookTitle(
                  context,
                  fontSize: 15,
                ),
              ),
              if (chapter != null)
                Text(
                  _chapterTitle(chapter),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: AppFonts.metadata(
                    context,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                // Add bookmark later.
              },
              icon: const Icon(
                Icons.bookmark_border,
              ),
            ),
            IconButton(
              onPressed: () {
                // More actions later.
              },
              icon: const Icon(
                Icons.more_vert,
              ),
            ),
          ],
        ),
        body: _buildBody(context),
        bottomNavigationBar:
            chapter == null
                ? null
                : _ReaderControls(
                    currentChapter:
                        _currentChapterIndex,
                    totalChapters:
                        _chapters.length,
                    onContents:
                        _showContents,
                    onPrevious:
                        _currentChapterIndex >
                                0
                            ? () =>
                                _changeChapter(
                                  _currentChapterIndex -
                                      1,
                                )
                            : null,
                    onNext:
                        _currentChapterIndex <
                                _chapters.length -
                                    1
                            ? () =>
                                _changeChapter(
                                  _currentChapterIndex +
                                      1,
                                )
                            : null,
                    onSettings:
                        _showReaderSettings,
                  ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.menu_book_outlined,
                size: 48,
                color: AppColors.gold,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppFonts.body(context),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loadBook,
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final chapter = _currentChapter;

    if (chapter == null) {
      return const Center(
        child: Text(
          'No chapter available.',
        ),
      );
    }

    final readingStyle =
        AppFonts.readingContent(
      context,
      fontFamily: _readingFont,
      fontSize: _fontSize,
    );

    return NotificationListener<
        ScrollEndNotification>(
      onNotification: (notification) {
        unawaited(_saveProgress());
        return false;
      },
      child: SelectionArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding:
              const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            48,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              Text(
                _chapterTitle(chapter),
                textAlign: TextAlign.center,
                style: AppFonts.chapterTitle(
                  context,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 14),
              const _ChapterDivider(),
              const SizedBox(height: 18),
              Html(
                data:
                    chapter.HtmlContent ?? '',
                style: {
                  'html':
                      Style.fromTextStyle(
                    readingStyle,
                  ),
                  'body':
                      Style.fromTextStyle(
                    readingStyle,
                  ),
                  'p': Style.fromTextStyle(
                    readingStyle,
                  ),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChapterDivider
    extends StatelessWidget {
  const _ChapterDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: AppColors.gold,
            thickness: 0.7,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Icon(
            Icons.auto_awesome,
            size: 15,
            color: AppColors.gold,
          ),
        ),
        const Expanded(
          child: Divider(
            color: AppColors.gold,
            thickness: 0.7,
          ),
        ),
      ],
    );
  }
}

class _ReaderControls
    extends StatelessWidget {
  const _ReaderControls({
    required this.currentChapter,
    required this.totalChapters,
    required this.onContents,
    required this.onPrevious,
    required this.onNext,
    required this.onSettings,
  });

  final int currentChapter;
  final int totalChapters;

  final VoidCallback onContents;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final percentage = totalChapters <= 0
        ? 0
        : (((currentChapter + 1) /
                    totalChapters) *
                100)
            .round();

    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                tooltip: 'Contents',
                onPressed: onContents,
                icon: const Icon(
                  Icons.format_list_bulleted,
                ),
              ),
              IconButton(
                tooltip:
                    'Previous chapter',
                onPressed: onPrevious,
                icon: const Icon(
                  Icons.chevron_left,
                ),
              ),
              Text(
                '$percentage%',
                style: AppFonts.metadata(
                  context,
                  color: AppColors.gold,
                ),
              ),
              IconButton(
                tooltip: 'Next chapter',
                onPressed: onNext,
                icon: const Icon(
                  Icons.chevron_right,
                ),
              ),
              IconButton(
                tooltip:
                    'Reader settings',
                onPressed: onSettings,
                icon: const Icon(
                  Icons.settings_outlined,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}