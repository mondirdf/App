import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../theme_constants.dart';
import '../widgets/simple_card.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key, required this.entries});

  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final List<DayEntry> sorted = List<DayEntry>.from(entries)
      ..sort((DayEntry a, DayEntry b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: sorted.isEmpty
              ? const Center(child: Text('No studies yet'))
              : ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final DayEntry day = sorted[index];
                    return SimpleCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_shortDate(day.date), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          if (day.studies.isEmpty) const Text('-') else ...day.studies.map((StudySession s) => Text('- ${s.subject} (${(s.durationMinutes / 60).toStringAsFixed(1)}h)')),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: sorted.length,
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
