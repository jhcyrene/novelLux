import 'package:flutter_test/flutter_test.dart';
import 'package:novel_lux/core/services/plain_text_novel_parser.dart';

void main() {
  test('reads Faded Page metadata and numbered story headings', () {
    const source = '''
=* A Distributed Proofreaders Canada eBook *=

_Title:_ The Flying Canoe
_Date of first publication:_ 1929
_Author:_ J. E. Le Rossignol

McCLELLAND AND STEWART
LIMITED
PUBLISHERS      TORONTO

I

THE FLYING CANOE

First story text.

[Illustration]

II

MARKET DAY

Second story text.
''';

    final novel = PlainTextNovelParser.parse(source);

    expect(novel.title, 'The Flying Canoe');
    expect(novel.author, 'J. E. Le Rossignol');
    expect(novel.publicationDate, '1929');
    expect(novel.publisher, 'McCLELLAND AND STEWART LIMITED');
    expect(novel.language, isNull);
    expect(novel.chapters.map((chapter) => chapter.title), [
      'The Flying Canoe',
      'Market Day',
    ]);
    expect(novel.chapters.first.content, 'First story text.');
    expect(novel.chapters.last.content, startsWith('[Illustration]'));
    expect(novel.chapters.last.content, endsWith('Second story text.'));
  });

  test('reads conventional chapter headings', () {
    const source = '''
CHAPTER I

The first chapter.

CHAPTER II: A NEW ROAD

The second chapter.
''';

    final novel = PlainTextNovelParser.parse(source);

    expect(novel.chapters, hasLength(2));
    expect(novel.chapters.first.title, 'CHAPTER I');
    expect(novel.chapters.last.title, 'CHAPTER II: A NEW ROAD');
  });

  test('renders illustration placeholders and embedded images', () {
    final placeholder = PlainTextNovelParser.chapterToHtml('[Illustration]');
    final embedded = PlainTextNovelParser.chapterToHtml(
      '![Map](data:image/png;base64,AAAA)',
    );

    expect(placeholder, contains('image not included'));
    expect(embedded, contains('<img src="data:image/png;base64,AAAA"'));
    expect(embedded, contains('alt="Map"'));
  });
}
