import '../models/day_entry.dart';

class StatsSummary {
  const StatsSummary({required this.sleepAverage, required this.studyAverage});

  final double sleepAverage;
  final double studyAverage;
}

class DayMetrics {
  const DayMetrics({
    required this.totalSleepHours,
    required this.totalStudyHours,
    required this.classification,
    required this.insight,
  });

  final double totalSleepHours;
  final double totalStudyHours;
  final String classification;
  final String insight;
}

class StatsService {
  DayMetrics calculateDayMetrics({
    required String sleepTime,
    required String wakeTime,
    required List<NapSession> naps,
    required List<StudySession> studies,
    required List<String> events,
  }) {
    final double mainSleep = calculateMainSleep(sleepTime: sleepTime, wakeTime: wakeTime);
    final double napsSleep = naps.fold<double>(
      0,
      (double sum, NapSession nap) => sum + (nap.durationMinutes / 60),
    );

    final double totalSleep = mainSleep + napsSleep;
    final double totalStudy = studies.fold<double>(
      0,
      (double sum, StudySession s) => sum + (s.durationMinutes / 60),
    );

    final String classification = classify(
      totalSleepHours: totalSleep,
      totalStudyHours: totalStudy,
      eventsCount: events.where((String e) => e.trim().isNotEmpty).length,
    );

    return DayMetrics(
      totalSleepHours: totalSleep,
      totalStudyHours: totalStudy,
      classification: classification,
      insight: buildInsight(totalSleepHours: totalSleep, totalStudyHours: totalStudy),
    );
  }

  double calculateMainSleep({required String sleepTime, required String wakeTime}) {
    DateTime sleep = _timeToDate(sleepTime);
    DateTime wake = _timeToDate(wakeTime);

    if (!wake.isAfter(sleep)) {
      wake = wake.add(const Duration(days: 1));
    }

    return wake.difference(sleep).inMinutes / 60;
  }

  String classify({
    required double totalSleepHours,
    required double totalStudyHours,
    required int eventsCount,
  }) {
    int score = 0;
    if (totalSleepHours >= 7 && totalSleepHours <= 8) {
      score++;
    }
    if (totalStudyHours >= 4) {
      score++;
    }
    if (eventsCount > 0) {
      score++;
    }

    if (score <= 1) {
      return 'ضعيف';
    }
    if (score == 2) {
      return 'متوسط';
    }
    return 'جيد';
  }

  String buildInsight({required double totalSleepHours, required double totalStudyHours}) {
    if (totalSleepHours < 6) {
      return 'نومك قليل';
    }
    if (totalStudyHours < 2) {
      return 'دراستك اليوم ضعيفة';
    }
    if (totalSleepHours >= 7 && totalStudyHours >= 4) {
      return 'ممتاز، يوم متوازن';
    }
    return 'أكمل على نفس النسق';
  }

  StatsSummary calculateAverages(List<DayEntry> entries, {required int days}) {
    final DateTime now = DateTime.now();
    final DateTime fromDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: days - 1));

    final List<DayEntry> filtered = entries.where((DayEntry entry) {
      final DateTime d = DateTime.parse(entry.date);
      final DateTime onlyDate = DateTime(d.year, d.month, d.day);
      if (onlyDate.isBefore(fromDate)) {
        return false;
      }

      final bool hasData = entry.totalSleepHours > 0 || entry.totalStudyHours > 0;
      return hasData;
    }).toList();

    if (filtered.isEmpty) {
      return const StatsSummary(sleepAverage: 0, studyAverage: 0);
    }

    final double totalSleep = filtered.fold<double>(
      0,
      (double sum, DayEntry e) => sum + e.totalSleepHours,
    );

    final double totalStudy = filtered.fold<double>(
      0,
      (double sum, DayEntry e) => sum + e.totalStudyHours,
    );

    return StatsSummary(
      sleepAverage: totalSleep / filtered.length,
      studyAverage: totalStudy / filtered.length,
    );
  }

  DateTime _timeToDate(String hhmm) {
    final List<String> parts = hhmm.split(':');
    final int hour = int.tryParse(parts.first) ?? 0;
    final int minute = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
    return DateTime(2000, 1, 1, hour, minute);
  }
}
