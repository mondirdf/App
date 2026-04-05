import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../services/stats_service.dart';
import '../theme_constants.dart';
import '../widgets/simple_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({
    super.key,
    required this.entries,
    required this.statsService,
  });

  final List<DayEntry> entries;
  final StatsService statsService;

  @override
  Widget build(BuildContext context) {
    final double studyAverage = statsService.calculateStudyAverage(entries);
    final double sleepAverage = statsService.calculateSleepAverage(entries);
    final int streak = statsService.calculateStreak(entries);
    final DayEntry? bestDay = statsService.getBestDay(List<DayEntry>.from(entries));

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              const Text(
                'Stats',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Study',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor),
              ),
              const SizedBox(height: 8),
              SimpleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Average study hours: ${studyAverage.toStringAsFixed(1)} h'),
                    const SizedBox(height: 6),
                    Text(
                      bestDay == null
                          ? 'Best day: -'
                          : 'Best day: ${_shortDate(bestDay.date)} (${bestDay.studyHours.toStringAsFixed(1)} h)',
                    ),
                    const SizedBox(height: 6),
                    Text('Streak: $streak day${streak == 1 ? '' : 's'}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sleep',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kPrimaryColor),
              ),
              const SizedBox(height: 8),
              SimpleCard(
                child: Text('Average sleep duration: ${sleepAverage.toStringAsFixed(1)} h'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _shortDate(String isoDate) {
    final DateTime d = DateTime.parse(isoDate);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
