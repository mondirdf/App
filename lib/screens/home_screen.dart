import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import '../theme_constants.dart';
import '../widgets/simple_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.storageService,
    required this.statsService,
    required this.onEntrySaved,
  });

  final StorageService storageService;
  final StatsService statsService;
  final VoidCallback onEntrySaved;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 30);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 30);

  final List<_NapInput> _naps = <_NapInput>[];
  final List<_StudyInput> _studies = <_StudyInput>[];
  final List<TextEditingController> _eventControllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    _addNap();
    _addStudy();
    _addEvent();
    _loadDraft();
  }

  @override
  void dispose() {
    for (final _NapInput nap in _naps) {
      nap.durationController.dispose();
    }
    for (final _StudyInput study in _studies) {
      study.subjectController.dispose();
      study.durationController.dispose();
    }
    for (final TextEditingController event in _eventControllers) {
      event.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DayMetrics metrics = _liveMetrics;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            _neumorphicContainer(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_todayLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 28, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _pill(
                          icon: Icons.bedtime_outlined,
                          title: 'Sleep',
                          value: _formatTime(_sleepTime),
                          onTap: () => _pickTime(isSleep: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _pill(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Wake',
                          value: _formatTime(_wakeTime),
                          onTap: () => _pickTime(isSleep: false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _neumorphicContainer(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text('Live insight', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
                        const SizedBox(height: 8),
                        Text(metrics.classification, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(metrics.insight, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                      ],
                    ),
                  ),
                  _clockDecoration(),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _sectionTitle('💤 Naps'),
            ..._buildNaps(),
            TextButton.icon(onPressed: _addNapAndSave, icon: const Icon(Icons.add), label: const Text('Add Nap')),
            const SizedBox(height: 8),
            _sectionTitle('📚 Study'),
            ..._buildStudies(),
            TextButton.icon(onPressed: _addStudyAndSave, icon: const Icon(Icons.add), label: const Text('Add Study')),
            const SizedBox(height: 8),
            _sectionTitle('⭐ Events'),
            ..._buildEvents(),
            TextButton.icon(onPressed: _addEventAndSave, icon: const Icon(Icons.add), label: const Text('Add Event')),
            const SizedBox(height: 16),
            _neumorphicButton(label: 'Save day entry', icon: Icons.upload_rounded, onTap: _saveEntry),
          ],
        ),
      ),
    );
  }

  Widget _clockDecoration() {
    final DateTime now = DateTime.now();
    final double minuteAngle = (now.minute / 60) * math.pi * 2;
    final double hourAngle = ((now.hour % 12) / 12 + now.minute / 720) * math.pi * 2;

    return _neumorphicCircle(
      size: 122,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle)),
          Transform.rotate(
            angle: minuteAngle,
            child: const Align(alignment: Alignment.topCenter, child: SizedBox(height: 40, child: VerticalDivider(thickness: 2))),
          ),
          Transform.rotate(
            angle: hourAngle,
            child: const Align(alignment: Alignment.topCenter, child: SizedBox(height: 26, child: VerticalDivider(thickness: 3))),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNaps() {
    return List<Widget>.generate(_naps.length, (int index) {
      final _NapInput nap = _naps[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SimpleCard(
          child: Column(
            children: <Widget>[
              _timeTile(
                label: 'Start',
                time: nap.start,
                onTap: () => _pickNapTime(index),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nap.durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                onChanged: (_) => _autoSaveDraft(),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildStudies() {
    return List<Widget>.generate(_studies.length, (int index) {
      final _StudyInput study = _studies[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SimpleCard(
          child: Column(
            children: <Widget>[
              TextField(
                controller: study.subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
                onChanged: (_) => _autoSaveDraft(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: study.durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (min)'),
                onChanged: (_) => _autoSaveDraft(),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildEvents() {
    return List<Widget>.generate(_eventControllers.length, (int index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: _eventControllers[index],
          decoration: InputDecoration(labelText: 'Event ${index + 1}'),
          onChanged: (_) => _autoSaveDraft(),
        ),
      );
    });
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }

  Widget _timeTile({required String label, required TimeOfDay time, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(label),
          Text(_formatTime(time), style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _pill({required IconData icon, required String title, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: _neumorphicContainer(
        radius: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 18, color: Colors.black54),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _neumorphicButton({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(35),
      child: _neumorphicContainer(
        radius: 35,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _neumorphicCircle({required double size, required Widget child}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        shape: BoxShape.circle,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: Color(0xFFD1D0CD), offset: Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: child,
    );
  }

  Widget _neumorphicContainer({
    required Widget child,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    double radius = 28,
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: kBackgroundColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(-8, -8), blurRadius: 16),
          BoxShadow(color: Color(0xFFD1D0CD), offset: Offset(8, 8), blurRadius: 16),
        ],
      ),
      child: child,
    );
  }

  String get _todayLabel {
    final DateTime now = DateTime.now();
    return '${now.month}/${now.day} ${now.hour > 12 ? now.hour - 12 : now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  DayMetrics get _liveMetrics {
    return widget.statsService.calculateDayMetrics(
      sleepTime: _formatTime(_sleepTime),
      wakeTime: _formatTime(_wakeTime),
      naps: _naps
          .map((e) => NapSession(start: _formatTime(e.start), durationMinutes: int.tryParse(e.durationController.text.trim()) ?? 0))
          .toList(),
      studies: _studies
          .map(
            (e) => StudySession(
              subject: e.subjectController.text.trim(),
              durationMinutes: int.tryParse(e.durationController.text.trim()) ?? 0,
            ),
          )
          .toList(),
      events: _eventControllers.map((TextEditingController e) => e.text.trim()).toList(),
    );
  }

  Future<void> _pickTime({required bool isSleep}) async {
    final TimeOfDay initial = isSleep ? _sleepTime : _wakeTime;
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) {
      return;
    }
    setState(() {
      if (isSleep) {
        _sleepTime = picked;
      } else {
        _wakeTime = picked;
      }
    });
    _autoSaveDraft();
  }

  Future<void> _pickNapTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: _naps[index].start);
    if (picked == null) {
      return;
    }
    setState(() {
      _naps[index].start = picked;
    });
    _autoSaveDraft();
  }

  Future<void> _loadDraft() async {
    final Map<String, dynamic>? draft = await widget.storageService.getDraft();
    if (draft == null || !mounted) {
      return;
    }

    setState(() {
      _sleepTime = _parseTime((draft['sleepTime'] ?? '23:30') as String);
      _wakeTime = _parseTime((draft['wakeTime'] ?? '07:30') as String);

      _resetDynamicControllers();

      final List<Object?> naps = (draft['naps'] as List<Object?>?) ?? <Object?>[];
      for (final Object? nap in naps) {
        final Map<String, dynamic> item = (nap as Map).cast<String, dynamic>();
        _naps.add(
          _NapInput(
            start: _parseTime((item['start'] ?? '13:00') as String),
            durationController: TextEditingController(text: (item['durationMinutes'] ?? 0).toString()),
          ),
        );
      }
      if (_naps.isEmpty) {
        _addNap();
      }

      final List<Object?> studies = (draft['studies'] as List<Object?>?) ?? <Object?>[];
      for (final Object? study in studies) {
        final Map<String, dynamic> item = (study as Map).cast<String, dynamic>();
        _studies.add(
          _StudyInput(
            subjectController: TextEditingController(text: (item['subject'] ?? '') as String),
            durationController: TextEditingController(text: (item['durationMinutes'] ?? 0).toString()),
          ),
        );
      }
      if (_studies.isEmpty) {
        _addStudy();
      }

      final List<Object?> events = (draft['events'] as List<Object?>?) ?? <Object?>[];
      for (final Object? event in events) {
        _eventControllers.add(TextEditingController(text: event?.toString() ?? ''));
      }
      if (_eventControllers.isEmpty) {
        _addEvent();
      }
    });
  }

  Future<void> _saveEntry() async {
    final DayMetrics metrics = _liveMetrics;
    final DayEntry entry = DayEntry(
      date: DateTime.now().toIso8601String(),
      sleepTime: _formatTime(_sleepTime),
      wakeTime: _formatTime(_wakeTime),
      naps: _naps
          .map((e) => NapSession(start: _formatTime(e.start), durationMinutes: int.tryParse(e.durationController.text.trim()) ?? 0))
          .toList(),
      studies: _studies
          .map(
            (e) => StudySession(
              subject: e.subjectController.text.trim(),
              durationMinutes: int.tryParse(e.durationController.text.trim()) ?? 0,
            ),
          )
          .where((StudySession s) => s.subject.isNotEmpty || s.durationMinutes > 0)
          .toList(),
      events: _eventControllers.map((TextEditingController e) => e.text.trim()).where((String e) => e.isNotEmpty).toList(),
      classification: metrics.classification,
      insight: metrics.insight,
      totalSleepHours: metrics.totalSleepHours,
      totalStudyHours: metrics.totalStudyHours,
    );

    await widget.storageService.saveEntry(entry);
    await widget.storageService.saveDraft(<String, dynamic>{});
    widget.onEntrySaved();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  void _addNapAndSave() {
    setState(_addNap);
    _autoSaveDraft();
  }

  void _addStudyAndSave() {
    setState(_addStudy);
    _autoSaveDraft();
  }

  void _addEventAndSave() {
    setState(_addEvent);
    _autoSaveDraft();
  }

  void _addNap() {
    _naps.add(_NapInput(start: const TimeOfDay(hour: 13, minute: 0), durationController: TextEditingController()));
  }

  void _addStudy() {
    _studies.add(_StudyInput(subjectController: TextEditingController(), durationController: TextEditingController()));
  }

  void _addEvent() {
    _eventControllers.add(TextEditingController());
  }

  void _resetDynamicControllers() {
    for (final _NapInput nap in _naps) {
      nap.durationController.dispose();
    }
    for (final _StudyInput study in _studies) {
      study.subjectController.dispose();
      study.durationController.dispose();
    }
    for (final TextEditingController event in _eventControllers) {
      event.dispose();
    }
    _naps.clear();
    _studies.clear();
    _eventControllers.clear();
  }

  Future<void> _autoSaveDraft() async {
    await widget.storageService.saveDraft(
      <String, dynamic>{
        'sleepTime': _formatTime(_sleepTime),
        'wakeTime': _formatTime(_wakeTime),
        'naps': _naps
            .map(
              (_NapInput e) => <String, dynamic>{
                'start': _formatTime(e.start),
                'durationMinutes': int.tryParse(e.durationController.text.trim()) ?? 0,
              },
            )
            .toList(),
        'studies': _studies
            .map(
              (_StudyInput e) => <String, dynamic>{
                'subject': e.subjectController.text.trim(),
                'durationMinutes': int.tryParse(e.durationController.text.trim()) ?? 0,
              },
            )
            .toList(),
        'events': _eventControllers.map((TextEditingController e) => e.text.trim()).toList(),
      },
    );
  }

  String _formatTime(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseTime(String hhmm) {
    final List<String> parts = hhmm.split(':');
    return TimeOfDay(hour: int.tryParse(parts.first) ?? 0, minute: int.tryParse(parts.last) ?? 0);
  }
}

class _NapInput {
  _NapInput({required this.start, required this.durationController});

  TimeOfDay start;
  TextEditingController durationController;
}

class _StudyInput {
  _StudyInput({required this.subjectController, required this.durationController});

  TextEditingController subjectController;
  TextEditingController durationController;
}
