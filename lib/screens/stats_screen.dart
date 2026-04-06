import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../services/stats_service.dart';
import '../theme_constants.dart';
import '../widgets/soft_ui.dart';

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
    final List<double> sleepData = _latestValues(entries.map((DayEntry e) => e.totalSleepHours).toList());
    final List<double> studyData = _latestValues(entries.map((DayEntry e) => e.totalStudyHours).toList());

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            const Text('Stats', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            _statCard('Average Sleep (7 days)', '${sleep7.sleepAverage.toStringAsFixed(1)} h'),
            const SizedBox(height: 12),
            _statCard('Average Sleep (30 days)', '${sleep30.sleepAverage.toStringAsFixed(1)} h'),
            const SizedBox(height: 12),
            _statCard('Average Study (7 days)', '${sleep7.studyAverage.toStringAsFixed(1)} h'),
            const SizedBox(height: 12),
            _statCard('Average Study (30 days)', '${sleep30.studyAverage.toStringAsFixed(1)} h'),
            const SizedBox(height: 18),
            SoftContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Sleep trend', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  InsetContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(height: 120, child: _LineChart(values: sleepData)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SoftContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('Study trend', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  InsetContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(height: 120, child: _LineChart(values: studyData)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value) {
    return SoftContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label, style: const TextStyle(color: kSecondaryTextColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  List<double> _latestValues(List<double> values) {
    final List<double> clean = values.where((double v) => v.isFinite && v >= 0).toList();
    if (clean.isEmpty) {
      return <double>[0, 0, 0, 0, 0, 0, 0];
    }
    return clean.reversed.take(7).toList().reversed.toList();
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _LineChartPainter(values));
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    final Paint linePaint = Paint()
      ..color = kPrimaryColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i <= 3; i++) {
      final double y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Path path = Path();
    final double maxValue = values.isEmpty ? 1 : values.reduce((double a, double b) => a > b ? a : b).clamp(1, 24);

    for (int i = 0; i < values.length; i++) {
      final double x = values.length <= 1 ? 0 : (i / (values.length - 1)) * size.width;
      final double normalized = (values[i] / maxValue).clamp(0, 1);
      final double y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.values != values;
}
