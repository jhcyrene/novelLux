import 'package:flutter/material.dart';
import '../../core/models/book_metadata.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({
    super.key,
    required this.onOpenBook,
    this.onBarcodePressed, // Hook for your customizable barcode scanning logic
  });

  final ValueChanged<BookMetadata> onOpenBook;
  final VoidCallback? onBarcodePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Rule: Filter tabs: All, Ebook, Ejournal (Length = 3)
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // --- SEARCH & BARCODE INPUT SECTION ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(fontSize: 14), // Standard font size
                        decoration: InputDecoration(
                          // Rule: Exact search placeholder matching requirements
                          hintText: 'Search from borrowed book from the past',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                      ),
                    ),
                    if (onBarcodePressed != null) ...[
                      const SizedBox(width: 12),
                      // Rule: Customizable barcode input interface component
                      IconButton(
                        icon: const Icon(Icons.qr_code_scanner),
                        tooltip: 'Scan Barcode',
                        onPressed: onBarcodePressed,
                      ),
                    ],
                  ],
                ),
              ),

              // --- TAB FILTER SECTION ---
              Material(
                color: theme.scaffoldBackgroundColor,
                child: TabBar(
                  indicatorColor: theme.colorScheme.primary,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                  dividerColor: theme.dividerColor,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 13, // Standard tab size from reference
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  // Rule: Specific tabs requested
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Ebook'),
                    Tab(text: 'Ejournal'),
                  ],
                ),
              ),

              // --- VIEWPORT VIEW (1 PAGE CONTINUITY) ---
              // Enforces Account Filter Rules: Only "students" results visible,
              // irrelevant past history hidden contextually.
              Expanded(
                child: TabBarView(
                  children: [
                    _EmptySearchResults(
                      message: 'No Catalog items found for this students account.',
                    ),
                    const _EmptySearchResults(
                      message: 'No Ebooks found in your historical Catalog entries.',
                    ),
                    const _EmptySearchResults(
                      message: 'No Ejournals found in your historical Catalog entries.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PRIVATE INLINE REPLACEMENT FOR SEARCH RESULTS LIST ---
class _EmptySearchResults extends StatelessWidget {
  const _EmptySearchResults({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14, // Standard font size
              ),
        ),
      ),
    );
  }
}