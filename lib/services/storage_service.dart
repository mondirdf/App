import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/day_entry.dart';

class StorageService {
  static const String _entriesKey = 'daily_entries';
  static const String _draftKey = 'home_draft';

  Future<void> saveEntry(DayEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<DayEntry> entries = await getAllEntries();

    final DateTime incomingDate = DateTime.parse(entry.date);
    final String incomingKey = _dateKey(incomingDate);
    final int existingIndex = entries.indexWhere(
      (DayEntry e) => _dateKey(DateTime.parse(e.date)) == incomingKey,
    );

    if (existingIndex >= 0) {
      entries[existingIndex] = entry;
    } else {
      entries.add(entry);
    }

    final List<String> encodedEntries = entries.map((DayEntry item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_entriesKey, encodedEntries);
  }

  Future<List<DayEntry>> getAllEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawEntries = prefs.getStringList(_entriesKey) ?? <String>[];

    return rawEntries
        .map((String rawEntry) => DayEntry.fromJson(jsonDecode(rawEntry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveDraft(Map<String, dynamic> draft) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_draftKey, jsonEncode(draft));
  }

  Future<Map<String, dynamic>?> getDraft() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(_draftKey);
    if (raw == null) {
      return null;
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }

  String _dateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> deleteAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
    await prefs.remove(_draftKey);
  }
}
