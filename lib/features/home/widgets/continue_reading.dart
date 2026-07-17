// import 'package:flutter/material.dart';

// import '../models/continue_reading_book.dart';

// class ContinueReadingSection extends StatelessWidget {
//   const ContinueReadingSection({
//     super.key,
//     required this.books,
//     this.onViewAll,
//     this.onBookPressed,
//   });

//   final List<ContinueReadingBook> books;
//   final VoidCallback? onViewAll;
//   final ValueChanged<ContinueReadingBook>? onBookPressed;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (books.isEmpty) {
//       return const SizedBox.shrink();
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Continue Reading',
//               style: theme.textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             TextButton(
//               onPressed: onViewAll,
//               child: const Text('View all'),
//             ),
//           ],
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 142,
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               final cardWidth = constraints.maxWidth * 0.92;

//               return ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: books.length,
//                 separatorBuilder: (_, _) => const SizedBox(width: 12),
//                 itemBuilder: (context, index) {
//                   final book = books[index];

//                   return SizedBox(
//                     width: cardWidth,
//                     child: _ContinueReadingCard(
//                       book: book,
//                       onPressed: () => onBookPressed?.call(book),
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _ContinueReadingCard extends StatelessWidget {
//   const _ContinueReadingCard({
//     required this.book,
//     required this.onPressed,
//   });

//   final ContinueReadingBook book;
//   final VoidCallback onPressed;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colors = theme.colorScheme;
//     final percentage = (book.progress * 100).round();

//     return Material(
//       color: colors.surfaceContainerLow,
//       borderRadius: BorderRadius.circular(12),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onPressed,
//         child: Padding(
//           padding: const EdgeInsets.all(10),
//           child: Row(
//             children: [
//               _BookCover(
//                 coverAsset: book.coverAsset,
//                 title: book.title,
//               ),
//               const SizedBox(width: 14),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       book.title,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: theme.textTheme.titleSmall?.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       book.author,
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colors.onSurfaceVariant,
//                       ),
//                     ),
//                     const Spacer(),
//                     Text(
//                       book.chapter,
//                       style: theme.textTheme.bodySmall,
//                     ),
//                     const SizedBox(height: 7),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: LinearProgressIndicator(
//                             value: book.progress,
//                             minHeight: 4,
//                             borderRadius: BorderRadius.circular(10),
//                             backgroundColor:
//                                 colors.surfaceContainerHighest,
//                             color: colors.secondary,
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Text(
//                           '$percentage%',
//                           style: theme.textTheme.labelSmall?.copyWith(
//                             color: colors.secondary,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _BookCover extends StatelessWidget {
//   const _BookCover({
//     required this.coverAsset,
//     required this.title,
//   });

//   final String? coverAsset;
//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     const width = 76.0;
//     const height = 116.0;

//     if (coverAsset != null) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(7),
//         child: Image.asset(
//           coverAsset!,
//           width: width,
//           height: height,
//           fit: BoxFit.cover,
//           errorBuilder: (_, _, _) {
//             return _CoverPlaceholder(title: title);
//           },
//         ),
//       );
//     }

//     return _CoverPlaceholder(title: title);
//   }
// }

// class _CoverPlaceholder extends StatelessWidget {
//   const _CoverPlaceholder({
//     required this.title,
//   });

//   final String title;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 76,
//       height: 116,
//       padding: const EdgeInsets.all(8),
//       alignment: Alignment.bottomCenter,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(7),
//         gradient: const LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF0C1830),
//             Color(0xFF29456E),
//           ],
//         ),
//       ),
//       child: Text(
//         title,
//         maxLines: 3,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 9,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }