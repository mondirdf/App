import '../models/day_entry.dart';

class StatsService {
  double calculateStudyAverage(List<DayEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    final double total = entries.fold(
      0,
      (double sum, DayEntry entry) => sum + entry.studyHours,
    );
    return total / entries.length;
  }

  double calculateSleepAverage(List<DayEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    final double totalHours = entries.fold(
      0,
      (double sum, DayEntry entry) => sum + _calculateSleepDuration(entry),
    );

    return totalHours / entries.length;
  }

  int calculateStreak(List<DayEntry> entries) {
    if (entries.isEmpty) {
      return 0;
    }

    final List<DateTime> uniqueDates = entries
        .map((DayEntry entry) => DateTime.parse(entry.date))
        .map((DateTime date) => DateTime(date.year, date.month, date.day))
        .toSet()
        .toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    int streak = 1;

    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final DateTime current = uniqueDates[i];
      final DateTime next = uniqueDates[i + 1];
      final int difference = current.difference(next).inDays;

      if (difference == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }

  DayEntry? getBestDay(List<DayEntry> entries) {
    if (entries.isEmpty) {
      return null;
    }

    entries.sort((DayEntry a, DayEntry b) => b.studyHours.compareTo(a.studyHours));
    return entries.first;
  }

  double _calculateSleepDuration(DayEntry entry) {
    final DateTime wakeUpTime = _timeToDate(entry.wakeUp);
    DateTime sleepTime = _timeToDate(entry.sleep);

    if (sleepTime.isBefore(wakeUpTime) || sleepTime.isAtSameMomentAs(wakeUpTime)) {
      sleepTime = sleepTime.add(const Duration(days: 1));
    }

    return sleepTime.difference(wakeUpTime).inMinutes / 60;
  }

  DateTime _timeToDate(String hhmm) {
    final List<String> parts = hhmm.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hour, minute);
  }
}
