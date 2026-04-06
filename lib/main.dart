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
        navigationBarTheme: NavigationBarThemeData(
          height: 72,
          backgroundColor: kBackgroundColor,
          indicatorColor: kPrimaryColor.withOpacity(0.1),
          labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(fontWeight: FontWeight.w700, color: kPrimaryColor);
            }
            return const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54);
          }),
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
  final PageController _pageController = PageController();

  int _currentTabIndex = 0;
  List<DayEntry> _entries = <DayEntry>[];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
      HomeScreen(storageService: _storageService, statsService: _statsService, onEntrySaved: _loadEntries),
      StatsScreen(entries: _entries, statsService: _statsService),
      StudyScreen(entries: _entries),
      HighlightsScreen(entries: _entries),
    ];

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int index) {
          if (_currentTabIndex == index) {
            return;
          }
          setState(() {
            _currentTabIndex = index;
          });
        },
        children: tabs,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: kBorderColor),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-6, -6), blurRadius: 12),
            BoxShadow(color: Color(0xFFD1D0CD), offset: Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBar(
            selectedIndex: _currentTabIndex,
            onDestinationSelected: (int index) {
              if (index == _currentTabIndex) {
                return;
              }
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeInOutCubic,
              );
              setState(() {
                _currentTabIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
              NavigationDestination(
                icon: Icon(Icons.insert_chart_outlined),
                selectedIcon: Icon(Icons.insert_chart_rounded),
                label: 'Stats',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Study Log',
              ),
              NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star_rounded), label: 'Events'),
            ],
          },
        ),
      ),
    );
  }
}
