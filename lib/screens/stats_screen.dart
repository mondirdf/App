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
    final StatsSummary sleep7 = statsService.calculateAverages(entries, days: 7);
    final StatsSummary sleep30 = statsService.calculateAverages(entries, days: 30);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              const Text('Stats', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              SimpleCard(child: Text('Average Sleep (7 days): ${sleep7.sleepAverage.toStringAsFixed(1)} h')),
              const SizedBox(height: 10),
              SimpleCard(child: Text('Average Sleep (30 days): ${sleep30.sleepAverage.toStringAsFixed(1)} h')),
              const SizedBox(height: 10),
              SimpleCard(child: Text('Average Study (7 days): ${sleep7.studyAverage.toStringAsFixed(1)} h')),
              const SizedBox(height: 10),
              SimpleCard(child: Text('Average Study (30 days): ${sleep30.studyAverage.toStringAsFixed(1)} h')),
            ],
          ),
        ),
      ),
    );
  }
}
