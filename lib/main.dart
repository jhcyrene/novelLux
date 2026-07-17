import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/provider/reading_progress_provider.dart';
import 'core/widgets/header_title.dart';
import 'core/widgets/bottom_nav.dart';
import 'core/provider/metadata_provider.dart';
import 'core/models/book_metadata.dart';
import 'core/widgets/loading_view.dart';

import 'features/reader/reader_page.dart';
import 'features/library/library_page.dart';
import 'features/home/home_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              TemporaryLibraryProvider()..loadBooks(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ReadingProgressProvider()..loadProgress(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String appTitle = 'NoveLux';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const LoadingView(
        child: MyHomePage(
          title: appTitle,
          text: 'Welcome to NoveLuxss!',
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;

    Future<void> openReader(
      BookMetadata book,
    ) async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) {
            return ReaderPage(
              book: book,
            );
          },
        ),
      );
    }



    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        centerTitle: false,
        leadingWidth: 48,
        title: NovelLuxBrand(
          text: widget.title,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Open search
            },
            icon: const Icon(
              Icons.search,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          HomePage(
            onViewLibrary: () {
              setState(() {
                _selectedNavIndex = 1;
              });
            },
            
            onOpenReader: openReader,
          ),
          LibraryPage(
            onOpenBook: openReader,
          ),
          Center(child: Text('Reader')),
          Center(child: Text('Profile')),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _selectedNavIndex,
        navheight: 68,
        iconSize: 23,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        onAddPressed: () async {
          await context
              .read<TemporaryLibraryProvider>()
              .uploadEpub(context);
        },
      ),
    
    );
  }
}