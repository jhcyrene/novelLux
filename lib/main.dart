import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/provider/reading_progress_provider.dart';
import 'core/widgets/header_title.dart';
import 'core/widgets/bottom_nav.dart';
import 'core/provider/metadata_provider.dart';
import 'core/models/book_metadata.dart';
import 'core/widgets/loading_view.dart';
import 'core/widgets/import_options.dart';

import 'features/reader/reader_page.dart';
import 'features/library/library_page.dart';
import 'features/home/home_page.dart';
import 'features/profile/profile_page.dart';
import 'features/search/search_page.dart';
import 'core/widgets/sidemenu.dart';
import 'features/book/book_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TemporaryLibraryProvider()..loadBooks(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReadingProgressProvider()..loadProgress(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = true;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const String appTitle = 'NoveLux';

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appTitle,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: LoadingView(
        child: MyHomePage(
          title: appTitle,
          text: 'Welcome to NoveLuxss!',
          isDarkMode: _isDarkMode,
          onDarkModeChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
          },
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.text,
    required this.isDarkMode,
    required this.onDarkModeChanged,
  });

  final String title;
  final String text;
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedNavIndex = 0;

  SideMenuDestination get _selectedSideMenuDestination {
    return switch (_selectedNavIndex) {
      0 => SideMenuDestination.home,
      1 => SideMenuDestination.library,
      2 => SideMenuDestination.reader,
      3 => SideMenuDestination.settings,
      4 => SideMenuDestination.help,
      _ => SideMenuDestination.home,
    };
  }

  void _selectSideMenuDestination(SideMenuDestination destination) {
    setState(() {
      _selectedNavIndex = switch (destination) {
        SideMenuDestination.home => 0,
        SideMenuDestination.library ||
        SideMenuDestination.favorites ||
        SideMenuDestination.folders => 1,
        SideMenuDestination.reader => 2,
        SideMenuDestination.readingGoals || SideMenuDestination.settings => 3,
        SideMenuDestination.help => 4,
        SideMenuDestination.logout => 0,
      };
    });
  }

  Future<void> _showImportOptions() async {
    if (kIsWeb) {
      await context.read<TemporaryLibraryProvider>().uploadEpub(context);
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return ImportOptions(
          onImportEpub: () {
            Navigator.pop(sheetContext);
            context.read<TemporaryLibraryProvider>().uploadEpub(context);
          },
          onLinkFolder: () {
            Navigator.pop(sheetContext);
            context.read<TemporaryLibraryProvider>().linkEpubDirectory(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;

    Future<void> openReader(BookMetadata book) async {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) {
            return ReaderPage(book: book);
          },
        ),
      );
    }

    Future<void> openBookDetails(BookMetadata book) async {
      final library = context.read<TemporaryLibraryProvider>();

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (bookPageContext) {
            return BookPage(
              book: book,
              loadBookDetails: () => library.loadBookDetails(book),
              onStartReading: () async {
                Navigator.of(bookPageContext).pop();
                await openReader(book);
              },
              bottomNavigationBar: BottomNav(
                currentIndex: _selectedNavIndex,
                navheight: 68,
                iconSize: 23,
                onTap: (index) {
                  Navigator.of(bookPageContext).pop();
                  setState(() {
                    _selectedNavIndex = index;
                  });
                },
                onAddPressed: () async {
                  Navigator.of(bookPageContext).pop();
                  await _showImportOptions();
                },
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: NovelLuxSideMenu(
        selectedDestination: _selectedSideMenuDestination,
        isDarkMode: widget.isDarkMode,
        onDestinationSelected: _selectSideMenuDestination,
        onDarkModeChanged: widget.onDarkModeChanged,
        onOpenFolder: () async {
          await context
              .read<TemporaryLibraryProvider>()
              .openLinkedEpubDirectory(context);
        },
      ),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        centerTitle: false,
        titleSpacing: 4,
        title: NovelLuxHeader(
          text: widget.title,
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Open search
            },
            icon: const Icon(Icons.search, size: iconSize),
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
            onAddBook: _showImportOptions,
            onOpenReader: openReader,
            onOpenBook: openBookDetails,
          ),
          LibraryPage(onOpenBook: openBookDetails),
          Center(child: Text('Reader')),
          const ProfilePage(),
          SearchPage(onOpenBook: openBookDetails),
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
        onAddPressed: _showImportOptions,
      ),
    );
  }
}
