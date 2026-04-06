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
          onPrimary: Colors.white,
          surface: kBackgroundColor,
          onSurface: kPrimaryColor,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          foregroundColor: kPrimaryColor,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: kPrimaryColor),
          bodySmall: TextStyle(color: kSecondaryTextColor),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: kSecondaryTextColor,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          type: BottomNavigationBarType.fixed,
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: kPrimaryColor,
          contentTextStyle: TextStyle(color: Colors.white),
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

  static const List<_NavDestination> _destinations = <_NavDestination>[
    _NavDestination(label: 'Home', outlinedIcon: Icons.home_outlined, filledIcon: Icons.home),
    _NavDestination(label: 'Stats', outlinedIcon: Icons.bar_chart_outlined, filledIcon: Icons.bar_chart),
    _NavDestination(label: 'Study Log', outlinedIcon: Icons.menu_book_outlined, filledIcon: Icons.menu_book),
    _NavDestination(label: 'Events', outlinedIcon: Icons.star_outline, filledIcon: Icons.star),
  ];

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
      HomeScreen(storageService: _storageService, statsService: _statsService, onEntrySaved: _loadEntries),
      StatsScreen(entries: _entries, statsService: _statsService),
      StudyScreen(entries: _entries),
      HighlightsScreen(entries: _entries),
    ];

    return Scaffold(
      body: tabs[_currentTabIndex],
      bottomNavigationBar: _SoftBottomNavigationBar(
        currentIndex: _currentTabIndex,
        destinations: _destinations,
        onTap: (int index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}

class _SoftBottomNavigationBar extends StatelessWidget {
  const _SoftBottomNavigationBar({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const Duration animationDuration = Duration(milliseconds: 200);
    const double indicatorWidth = 24;

    return SafeArea(
      top: false,
      child: Container(
        color: kBackgroundColor,
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double itemWidth = constraints.maxWidth / destinations.length;
            final double indicatorLeft = (itemWidth * currentIndex) + ((itemWidth - indicatorWidth) / 2);

            return Stack(
              alignment: Alignment.topLeft,
              children: <Widget>[
                AnimatedPositioned(
                  duration: animationDuration,
                  curve: Curves.easeOut,
                  top: 0,
                  left: indicatorLeft,
                  child: Container(
                    width: indicatorWidth,
                    height: 2,
                    decoration: const BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(1)),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(destinations.length, (int index) {
                    final bool isActive = index == currentIndex;
                    final _NavDestination destination = destinations[index];
                    return Expanded(
                      child: _NavItem(
                        isActive: isActive,
                        destination: destination,
                        onTap: () => onTap(index),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.isActive,
    required this.destination,
    required this.onTap,
  });

  final bool isActive;
  final _NavDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const Duration animationDuration = Duration(milliseconds: 200);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedScale(
                duration: animationDuration,
                curve: Curves.easeOut,
                scale: isActive ? 1.12 : 1,
                child: AnimatedContainer(
                  duration: animationDuration,
                  curve: Curves.easeOut,
                  child: Icon(
                    isActive ? destination.filledIcon : destination.outlinedIcon,
                    color: isActive ? kPrimaryColor : const Color(0xFF888888),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: animationDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final Animation<Offset> offset = Tween<Offset>(
                    begin: const Offset(0, 0.25),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offset, child: child),
                  );
                },
                child: isActive
                    ? Text(
                        destination.label,
                        key: ValueKey<String>('active-label-${destination.label}'),
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : const SizedBox(
                        key: ValueKey<String>('inactive-label'),
                        height: 16,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.outlinedIcon,
    required this.filledIcon,
  });

  final String label;
  final IconData outlinedIcon;
  final IconData filledIcon;
}
