class BookMetadata {
  const BookMetadata({
    required this.id,
    required this.filePath,
    required this.title,
    required this.author,
    required this.fileSize,
    this.tags = const [],
    this.chapterTitles = const [],
    this.description,
    this.publisher,
    this.language,
    this.publicationDate,
  });

  final String id;
  final String filePath;
  final String title;
  final String author;
  final int fileSize;
  final List<String> tags;
  final List<String> chapterTitles;
  final String? description;
  final String? publisher;
  final String? language;
  final String? publicationDate;
}
