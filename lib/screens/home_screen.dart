import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../services/stats_service.dart';
import '../services/storage_service.dart';
import '../theme_constants.dart';
import '../widgets/soft_ui.dart';

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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: <Widget>[
            _topDateCard(),
            const SizedBox(height: 22),
            _sectionLabel('Sleep'),
            const SizedBox(height: 10),
            InsetContainer(
              child: Column(
                children: <Widget>[
                  _timeRow(label: 'Sleep time', time: _sleepTime, onTap: () => _pickTime(isSleep: true)),
                  const SizedBox(height: 10),
                  _timeRow(label: 'Wake time', time: _wakeTime, onTap: () => _pickTime(isSleep: false)),
                ],
              ),
            ),
            const SizedBox(height: 22),
            _sectionLabel('Naps'),
            const SizedBox(height: 10),
            ..._buildNaps(),
            Align(
              alignment: Alignment.centerRight,
              child: SoftButton.secondary(label: '+', isCircular: true, onTap: _addNapAndSave),
            ),
            const SizedBox(height: 22),
            _sectionLabel('Study sessions'),
            const SizedBox(height: 10),
            ..._buildStudies(),
            Align(
              alignment: Alignment.centerRight,
              child: SoftButton.secondary(label: '+', isCircular: true, onTap: _addStudyAndSave),
            ),
            const SizedBox(height: 22),
            _sectionLabel('Events'),
            const SizedBox(height: 10),
            ..._buildEvents(),
            Align(
              alignment: Alignment.centerRight,
              child: SoftButton.secondary(label: '+', isCircular: true, onTap: _addEventAndSave),
            ),
            const SizedBox(height: 26),
            SoftButton.primary(label: 'Save', onTap: _saveEntry),
          ],
        ),
      ),
    );
  }

  Widget _topDateCard() {
    final DateTime now = DateTime.now();
    final String date = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final String time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    return SoftContainer(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kSecondaryTextColor)),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text(_liveMetrics.classification, style: const TextStyle(fontSize: 14, color: kSecondaryTextColor)),
        ],
      ),
    );
  }

  List<Widget> _buildNaps() {
    return List<Widget>.generate(_naps.length, (int index) {
      final _NapInput nap = _naps[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SoftContainer(
          child: Column(
            children: <Widget>[
              _timeRow(label: 'Start', time: nap.start, onTap: () => _pickNapTime(index)),
              const SizedBox(height: 8),
              InsetContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: TextField(
                  controller: nap.durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Duration (min)', hintStyle: TextStyle(color: kSecondaryTextColor)),
                  onChanged: (_) => _autoSaveDraft(),
                ),
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
        padding: const EdgeInsets.only(bottom: 10),
        child: SoftContainer(
          child: Column(
            children: <Widget>[
              InsetContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: TextField(
                  controller: study.subjectController,
                  decoration: const InputDecoration(hintText: 'Subject', hintStyle: TextStyle(color: kSecondaryTextColor)),
                  onChanged: (_) => _autoSaveDraft(),
                ),
              ),
              const SizedBox(height: 8),
              InsetContainer(
                borderRadius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: TextField(
                  controller: study.durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Duration (min)', hintStyle: TextStyle(color: kSecondaryTextColor)),
                  onChanged: (_) => _autoSaveDraft(),
                ),
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
        padding: const EdgeInsets.only(bottom: 10),
        child: InsetContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: TextField(
            controller: _eventControllers[index],
            decoration: InputDecoration(
              hintText: 'Event ${index + 1}',
              hintStyle: const TextStyle(color: kSecondaryTextColor),
            ),
            onChanged: (_) => _autoSaveDraft(),
          ),
        ),
      );
    });
  }

  Widget _sectionLabel(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  }

  Widget _timeRow({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(label, style: const TextStyle(color: kSecondaryTextColor)),
            Text(_formatTime(time), style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
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
