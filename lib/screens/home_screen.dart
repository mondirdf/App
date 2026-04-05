import 'package:flutter/material.dart';

import '../models/day_entry.dart';
import '../services/storage_service.dart';
import '../widgets/simple_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.storageService,
    required this.onEntrySaved,
  });

  final StorageService storageService;
  final VoidCallback onEntrySaved;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _studyHoursController = TextEditingController();
  final TextEditingController _subjectsController = TextEditingController();
  final TextEditingController _highlightController = TextEditingController();

  TimeOfDay? _wakeUpTime;
  TimeOfDay? _sleepTime;

  @override
  void dispose() {
    _studyHoursController.dispose();
    _subjectsController.dispose();
    _highlightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: <Widget>[
              const Text(
                'Today',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              SimpleCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildTimePickerField(
                      label: 'Wake up time',
                      selected: _wakeUpTime,
                      onTap: () => _pickTime(isWakeUp: true),
                    ),
                    const SizedBox(height: 12),
                    _buildTimePickerField(
                      label: 'Sleep time',
                      selected: _sleepTime,
                      onTap: () => _pickTime(isWakeUp: false),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _studyHoursController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _inputDecoration('Study hours'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subjectsController,
                      decoration: _inputDecoration('Subjects'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _highlightController,
                      decoration: _inputDecoration('Highlight'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _saveEntry,
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerField({
    required String label,
    required TimeOfDay? selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(label),
        child: Text(
          selected == null ? 'Select time' : selected.format(context),
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black87),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Future<void> _pickTime({required bool isWakeUp}) async {
    final TimeOfDay initialTime = isWakeUp
        ? (_wakeUpTime ?? const TimeOfDay(hour: 7, minute: 0))
        : (_sleepTime ?? const TimeOfDay(hour: 23, minute: 0));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      if (isWakeUp) {
        _wakeUpTime = picked;
      } else {
        _sleepTime = picked;
      }
    });
  }

  Future<void> _saveEntry() async {
    if (_wakeUpTime == null || _sleepTime == null || _studyHoursController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill wake up, sleep and study hours.')),
      );
      return;
    }

    final double? studyHours = double.tryParse(_studyHoursController.text.trim());
    if (studyHours == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Study hours must be a number.')),
      );
      return;
    }

    final DayEntry entry = DayEntry(
      date: DateTime.now().toIso8601String(),
      wakeUp: _formatTime(_wakeUpTime!),
      sleep: _formatTime(_sleepTime!),
      studyHours: studyHours,
      subjects: _subjectsController.text.trim(),
      highlight: _highlightController.text.trim(),
    );

    await widget.storageService.saveEntry(entry);
    widget.onEntrySaved();

    if (!mounted) {
      return;
    }

    setState(() {
      _wakeUpTime = null;
      _sleepTime = null;
      _studyHoursController.clear();
      _subjectsController.clear();
      _highlightController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Entry saved.')),
    );
  }

  String _formatTime(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
