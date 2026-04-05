import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/day_entry.dart';

class StorageService {
  static const String _entriesKey = 'daily_entries';

  Future<void> saveEntry(DayEntry entry) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<DayEntry> entries = await getAllEntries();
    entries.add(entry);

    final List<String> encodedEntries = entries
        .map((DayEntry item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList(_entriesKey, encodedEntries);
  }

  Future<List<DayEntry>> getAllEntries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> rawEntries = prefs.getStringList(_entriesKey) ?? <String>[];

    return rawEntries
        .map((String rawEntry) => DayEntry.fromJson(jsonDecode(rawEntry) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
  }
}
