import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../theme_constants.dart';
import '../widgets/soft_ui.dart';

class HighlightsScreen extends StatelessWidget {
  const HighlightsScreen({super.key, required this.entries});

  final List<DayEntry> entries;

  @override
  Widget build(BuildContext context) {
    final List<DayEntry> sorted = List<DayEntry>.from(entries)
      ..sort((DayEntry a, DayEntry b) => DateTime.parse(b.date).compareTo(DateTime.parse(a.date)));

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: sorted.isEmpty
              ? const Center(child: Text('No events yet', style: TextStyle(color: kSecondaryTextColor)))
              : ListView.separated(
                  itemBuilder: (BuildContext context, int index) {
                    final DayEntry day = sorted[index];
                    return SoftContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_shortDate(day.date), style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          if (day.events.isEmpty)
                            const Text('-', style: TextStyle(color: kSecondaryTextColor))
                          else
                            ...day.events.map(
                              (String e) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(e),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
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
