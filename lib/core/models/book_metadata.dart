class BookMetadata {
  const BookMetadata({
    required this.id,
    required this.filePath,
    required this.title,
    required this.author,
    required this.fileSize,
  });

  final String id;
  final String filePath;
  final String title;
  final String author;
  final int fileSize;
}