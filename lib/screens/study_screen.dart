import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../theme_constants.dart';
import '../widgets/simple_card.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({
    super.key,
    required this.entries,
  });

  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final List<DayEntry> sortedEntries = List<DayEntry>.from(entries)
      ..sort((DayEntry a, DayEntry b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Study Log',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: sortedEntries.isEmpty
                    ? const Center(child: Text('No study logs yet.', style: TextStyle(color: kPrimaryColor)))
                    : ListView.separated(
                        itemCount: sortedEntries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (BuildContext context, int index) {
                          final DayEntry entry = sortedEntries[index];
                          return SimpleCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _shortDate(entry.date),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Text(entry.subjects.isEmpty ? '-' : entry.subjects),
                              ],
                            ),
                          );
                        },
                      ),
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
