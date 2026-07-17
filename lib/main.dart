import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/header_title.dart';
import 'core/widgets/bottom_nav.dart';
import 'features/library/services/epub_picker.dart';



void main() {
  runApp(const MyApp());
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
      home: const MyHomePage(
        title: appTitle, 
        text: 'Welcome to NoveLuxss!',
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

  void _incrementCounter() {
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    const double iconSize = 25;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
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
      bottomNavigationBar: BottomNav(
        navheight: 60,
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          EpubPickerService.pickAndSaveEpub(context);
        },
        tooltip: 'Import EPUB',
        child: const Icon(Icons.add),
      ),
    );
  }
}