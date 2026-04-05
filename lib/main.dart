import 'package:flutter/material.dart';

import 'models/day_entry.dart';
import 'screens/highlights_screen.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/study_screen.dart';
import 'services/stats_service.dart';
import 'services/storage_service.dart';
import 'theme_constants.dart';

void main() {
  runApp(const DailyTrackerApp());
}

class DailyTrackerApp extends StatelessWidget {
  const DailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'fday',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: kBackgroundColor,
        colorScheme: const ColorScheme.light(
          primary: kPrimaryColor,
          onPrimary: kBackgroundColor,
          surface: kBackgroundColor,
          onSurface: kPrimaryColor,
          outline: kBorderColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          foregroundColor: kPrimaryColor,
        ),
        cardColor: kBackgroundColor,
        dividerColor: kBorderColor,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.black54,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kPrimaryColor,
          contentTextStyle: TextStyle(color: kBackgroundColor),
          behavior: SnackBarBehavior.floating,
        ),
        useMaterial3: true,
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final StorageService _storageService = StorageService();
  final StatsService _statsService = StatsService();

  int _currentTabIndex = 0;
  List<DayEntry> _entries = <DayEntry>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final List<DayEntry> data = await _storageService.getAllEntries();
    if (!mounted) {
      return;
    }
    setState(() {
      _entries = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = <Widget>[
      HomeScreen(storageService: _storageService, onEntrySaved: _loadEntries),
      StatsScreen(entries: _entries, statsService: _statsService),
      StudyScreen(entries: _entries),
      HighlightsScreen(entries: _entries),
    ];

    return Scaffold(
      body: tabs[_currentTabIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: kBorderColor)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (int index) {
            setState(() {
              _currentTabIndex = index;
            });
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.insert_chart_outlined), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'Study Log'),
            BottomNavigationBarItem(icon: Icon(Icons.highlight_outlined), label: 'Highlights'),
          ],
        ),
      ),
    );
  }
}
