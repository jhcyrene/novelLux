import 'package:flutter/material.dart';

import '../../core/models/book_metadata.dart';
import 'widgets/book_header.dart';
import 'widgets/book_tabs.dart';
import 'widgets/book_title.dart';

class BookPage extends StatefulWidget {
  const BookPage({
    super.key,
    required this.book,
    required this.loadBookDetails,
    required this.onStartReading,
    this.bottomNavigationBar,
  });

  final BookMetadata book;
  final Future<BookMetadata> Function() loadBookDetails;
  final VoidCallback onStartReading;
  final Widget? bottomNavigationBar;

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool _isBookmarked = false;
  late Future<BookMetadata> _bookDetails;

  @override
  void initState() {
    super.initState();
    _bookDetails = widget.loadBookDetails();
  }

  @override
  void didUpdateWidget(covariant BookPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.book.id != widget.book.id) {
      _bookDetails = widget.loadBookDetails();
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BookHeader(
        isBookmarked: _isBookmarked,
        onBookmarkPressed: _toggleBookmark,
      ),
      body: SafeArea(
        child: FutureBuilder<BookMetadata>(
          future: _bookDetails,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _BookPageSkeleton();
            }

            final book = snapshot.data ?? widget.book;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookTitle(
                    book: book,
                    isFavorite: _isBookmarked,
                    chapterCount: book.chapterTitles.length,
                    onStartReading: widget.onStartReading,
                    onFavoritePressed: _toggleBookmark,
                  ),
                  const SizedBox(height: 20),
                  BookTabs(book: book, chapters: book.chapterTitles),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: widget.bottomNavigationBar,
    );
  }
}

class _BookPageSkeleton extends StatefulWidget {
  const _BookPageSkeleton();

  @override
  State<_BookPageSkeleton> createState() => _BookPageSkeletonState();
}

class _BookPageSkeletonState extends State<_BookPageSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 0.42,
      end: 0.82,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: FadeTransition(
        opacity: _opacity,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SkeletonBox(width: 140, height: 200, radius: 8),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBox(height: 25),
                      SizedBox(height: 8),
                      _SkeletonBox(width: 110, height: 18),
                      SizedBox(height: 16),
                      _SkeletonBox(width: 145, height: 27, radius: 14),
                      SizedBox(height: 70),
                      _SkeletonBox(height: 34),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _SkeletonBox(height: 42, radius: 7)),
                SizedBox(width: 10),
                Expanded(child: _SkeletonBox(height: 42, radius: 7)),
              ],
            ),
            SizedBox(height: 24),
            _SkeletonBox(height: 52),
            SizedBox(height: 14),
            _SkeletonBox(height: 250, radius: 10),
          ],
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({this.width, required this.height, this.radius = 5});

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: colors.onSurface.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
