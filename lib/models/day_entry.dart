class NapSession {
  NapSession({required this.start, required this.durationMinutes});

  final String start;
  final int durationMinutes;

  factory NapSession.fromJson(Map<String, dynamic> json) {
    return NapSession(
      start: (json['start'] ?? '00:00') as String,
      durationMinutes: (json['durationMinutes'] ?? json['duration'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'start': start,
      'durationMinutes': durationMinutes,
    };
  }
}

class StudySession {
  StudySession({required this.subject, required this.durationMinutes});

  final String subject;
  final int durationMinutes;

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      subject: (json['subject'] ?? json['subjects'] ?? '') as String,
      durationMinutes: (json['durationMinutes'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'subject': subject,
      'durationMinutes': durationMinutes,
    };
  }
}

class DayEntry {
  DayEntry({
    required this.date,
    required this.sleepTime,
    required this.wakeTime,
    required this.naps,
    required this.studies,
    required this.events,
    required this.classification,
    required this.insight,
    required this.totalSleepHours,
    required this.totalStudyHours,
  });

  final String date;
  final String sleepTime;
  final String wakeTime;
  final List<NapSession> naps;
  final List<StudySession> studies;
  final List<String> events;
  final String classification;
  final String insight;
  final double totalSleepHours;
  final double totalStudyHours;

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    final Object? napsRaw = json['naps'];
    final Object? studiesRaw = json['studies'];
    final Object? eventsRaw = json['events'];

    final List<NapSession> naps = napsRaw is List
        ? napsRaw
              .whereType<Map<String, dynamic>>()
              .map(NapSession.fromJson)
              .toList()
        : <NapSession>[];

    final List<StudySession> studies = studiesRaw is List
        ? studiesRaw
              .whereType<Map<String, dynamic>>()
              .map(StudySession.fromJson)
              .toList()
        : <StudySession>[];

    final List<String> events = eventsRaw is List
        ? eventsRaw.map<String>((Object? e) => e.toString()).toList()
        : <String>[];

    final double legacyStudyHours = ((json['studyHours'] as num?) ?? 0).toDouble();
    if (studies.isEmpty && legacyStudyHours > 0) {
      studies.add(
        StudySession(
          subject: (json['subjects'] ?? 'Study') as String,
          durationMinutes: (legacyStudyHours * 60).round(),
        ),
      );
    }

    if (events.isEmpty && (json['highlight'] as String?)?.isNotEmpty == true) {
      events.add((json['highlight'] as String).trim());
    }

    return DayEntry(
      date: (json['date'] ?? DateTime.now().toIso8601String()) as String,
      sleepTime: (json['sleepTime'] ?? json['sleep'] ?? '23:00') as String,
      wakeTime: (json['wakeTime'] ?? json['wakeUp'] ?? '07:00') as String,
      naps: naps,
      studies: studies,
      events: events,
      classification: (json['classification'] ?? 'متوسط') as String,
      insight: (json['insight'] ?? '') as String,
      totalSleepHours: ((json['totalSleepHours'] as num?) ?? 0).toDouble(),
      totalStudyHours: ((json['totalStudyHours'] as num?) ?? legacyStudyHours).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'date': date,
      'sleepTime': sleepTime,
      'wakeTime': wakeTime,
      'naps': naps.map((NapSession item) => item.toJson()).toList(),
      'studies': studies.map((StudySession item) => item.toJson()).toList(),
      'events': events,
      'classification': classification,
      'insight': insight,
      'totalSleepHours': totalSleepHours,
      'totalStudyHours': totalStudyHours,
    };
  }
}
