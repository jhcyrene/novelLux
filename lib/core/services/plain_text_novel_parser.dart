import 'dart:convert';

class PlainTextNovel {
  const PlainTextNovel({
    this.title,
    this.author,
    this.publisher,
    this.language,
    this.publicationDate,
    required this.chapters,
  });

  final String? title;
  final String? author;
  final String? publisher;
  final String? language;
  final String? publicationDate;
  final List<PlainTextChapter> chapters;
}

class PlainTextChapter {
  const PlainTextChapter({required this.title, required this.content});

  final String title;
  final String content;
}

abstract final class PlainTextNovelParser {
  static PlainTextNovel parse(String source) {
    final text = source.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
    final metadata = _readMetadata(text);
    final chapters = _readChapters(text);

    return PlainTextNovel(
      title: metadata['title'],
      author: metadata['author'],
      publisher: metadata['publisher'] ?? _readPublisher(text),
      language: metadata['language'] ?? _inferLanguage(text),
      publicationDate:
          metadata['date of first publication'] ??
          metadata['publication date'] ??
          metadata['published'],
      chapters: chapters.isEmpty
          ? [PlainTextChapter(title: 'Content', content: text.trim())]
          : List.unmodifiable(chapters),
    );
  }

  static String chapterToHtml(String text) {
    final blocks = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split(RegExp(r'\n[ \t]*\n'));
    final html = StringBuffer();

    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty) {
        continue;
      }

      final image = _imageBlockToHtml(trimmed);
      if (image != null) {
        html.write(image);
        continue;
      }

      final paragraph = trimmed
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .join(' ');

      html
        ..write('<p>')
        ..write(const HtmlEscape().convert(paragraph))
        ..write('</p>');
    }

    return html.toString();
  }
}

String? _imageBlockToHtml(String block) {
  final placeholder = RegExp(
    r'^\[(cover[ \t]+)?illustration\]$',
    caseSensitive: false,
  ).firstMatch(block);

  if (placeholder != null) {
    final label = placeholder.group(1) == null
        ? 'Illustration'
        : 'Cover illustration';
    return '<p><em>🖼 $label — image not included in this TXT edition.</em></p>';
  }

  final markdownImage = RegExp(
    r'''^!\[([^\]]*)\]\(([^)\s]+)(?:\s+["'][^"']*["'])?\)$''',
    caseSensitive: false,
  ).firstMatch(block);
  if (markdownImage != null) {
    return _safeImageHtml(
      source: markdownImage.group(2)!,
      description: markdownImage.group(1),
    );
  }

  final htmlImage = RegExp(
    r'''^<img\b[^>]*\bsrc\s*=\s*(["'])(.*?)\1[^>]*>\s*$''',
    caseSensitive: false,
  ).firstMatch(block);
  if (htmlImage != null) {
    final alt = RegExp(
      r'''\balt\s*=\s*(["'])(.*?)\1''',
      caseSensitive: false,
    ).firstMatch(block);
    return _safeImageHtml(
      source: htmlImage.group(2)!,
      description: alt?.group(2),
    );
  }

  if (block.startsWith('data:image/')) {
    return _safeImageHtml(source: block);
  }

  return null;
}

String? _safeImageHtml({required String source, String? description}) {
  final normalizedSource = source.trim();
  final supportedSource =
      normalizedSource.startsWith('data:image/') ||
      normalizedSource.startsWith('https://') ||
      normalizedSource.startsWith('http://');

  if (!supportedSource) {
    return null;
  }

  final escape = const HtmlEscape(HtmlEscapeMode.attribute);
  final safeSource = escape.convert(normalizedSource);
  final safeDescription = escape.convert(
    description?.trim().isNotEmpty == true
        ? description!.trim()
        : 'Illustration',
  );

  return '<p><img src="$safeSource" alt="$safeDescription"></p>';
}

Map<String, String> _readMetadata(String text) {
  final metadata = <String, String>{};
  final matches = RegExp(
    r'^_([^:\n]+):_\s*(.+?)\s*$',
    multiLine: true,
  ).allMatches(text);

  for (final match in matches) {
    final key = match.group(1)?.trim().toLowerCase();
    final value = match.group(2)?.trim();

    if (key != null && key.isNotEmpty && value != null && value.isNotEmpty) {
      metadata[key] = value;
    }
  }

  return metadata;
}

List<PlainTextChapter> _readChapters(String text) {
  final numberedHeadings = RegExp(
    r"^[ \t]*[IVXLCDM]+[ \t]*\n(?:[ \t]*\n)*[ \t]*([A-ZÀ-ÖØ-Þ][A-ZÀ-ÖØ-Þ0-9 .,'’()\-]+)[ \t]*$",
    multiLine: true,
  ).allMatches(text).toList();

  if (numberedHeadings.length >= 2) {
    return _chaptersFromMatches(text, numberedHeadings);
  }

  final conventionalHeadings = RegExp(
    r'^[ \t]*(CHAPTER[ \t]+(?:[IVXLCDM]+|\d+)(?:[ \t]*[:.\-—]?[ \t]*[^\n]+)?)[ \t]*$',
    caseSensitive: false,
    multiLine: true,
  ).allMatches(text).toList();

  if (conventionalHeadings.length >= 2) {
    return _chaptersFromMatches(text, conventionalHeadings);
  }

  return const [];
}

List<PlainTextChapter> _chaptersFromMatches(
  String text,
  List<RegExpMatch> matches,
) {
  final chapters = <PlainTextChapter>[];
  final boundaries = [
    for (final match in matches) _chapterBoundary(text, match.start),
  ];

  for (var index = 0; index < matches.length; index++) {
    final match = matches[index];
    final contentEnd = index + 1 < matches.length
        ? boundaries[index + 1].start
        : text.length;
    final title = _displayTitle(match.group(1)!.trim());
    final content = [
      if (boundaries[index].hasIllustration) '[Illustration]',
      text.substring(match.end, contentEnd).trim(),
    ].where((part) => part.isNotEmpty).join('\n\n');

    if (content.isNotEmpty) {
      chapters.add(PlainTextChapter(title: title, content: content));
    }
  }

  return chapters;
}

({int start, bool hasIllustration}) _chapterBoundary(
  String text,
  int headingStart,
) {
  final lookBehindStart = headingStart > 180 ? headingStart - 180 : 0;
  final precedingText = text.substring(lookBehindStart, headingStart);
  final illustration = RegExp(
    r'\[Illustration\][ \t]*(?:\n[ \t]*)*$',
    caseSensitive: false,
  ).firstMatch(precedingText);

  if (illustration == null) {
    return (start: headingStart, hasIllustration: false);
  }

  return (start: lookBehindStart + illustration.start, hasIllustration: true);
}

String _displayTitle(String title) {
  final letters = title.replaceAll(RegExp(r'[^A-Za-zÀ-ÖØ-öø-ÿ]'), '');
  final isUppercase = letters.isNotEmpty && letters == letters.toUpperCase();

  if (!isUppercase) {
    return title;
  }

  return title
      .toLowerCase()
      .split(' ')
      .map(
        (word) => word
            .split('-')
            .map(
              (part) => part.isEmpty
                  ? part
                  : '${part.substring(0, 1).toUpperCase()}${part.substring(1)}',
            )
            .join('-'),
      )
      .join(' ');
}

String? _readPublisher(String text) {
  final lines = text.split('\n');

  for (var index = 0; index < lines.length && index < 120; index++) {
    if (!lines[index].toUpperCase().contains('PUBLISHER')) {
      continue;
    }

    final publisherLines = <String>[];
    for (
      var previous = index - 1;
      previous >= 0 && publisherLines.length < 2;
      previous--
    ) {
      final line = lines[previous].trim();
      if (line.isEmpty) {
        continue;
      }
      final looksLikePublisherName =
          line.length <= 80 &&
          RegExp(r'[A-Za-z]').hasMatch(line) &&
          RegExp(r"^[A-Za-zÀ-ÿ0-9 &.,'’()\-]+$").hasMatch(line);

      if (looksLikePublisherName) {
        publisherLines.insert(0, line);
      } else {
        break;
      }
    }

    if (publisherLines.isNotEmpty) {
      return _displayTitle(publisherLines.join(' '));
    }
  }

  return null;
}

String? _inferLanguage(String text) {
  final sample = text.length > 20000 ? text.substring(0, 20000) : text;
  final englishWords = RegExp(
    r'\b(the|and|that|with|from|this|was|were|for|not|you|his|her)\b',
    caseSensitive: false,
  ).allMatches(sample).length;

  return englishWords >= 12 ? 'English' : null;
}
