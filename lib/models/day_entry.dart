class DayEntry {
  DayEntry({
    required this.date,
    required this.wakeUp,
    required this.sleep,
    required this.studyHours,
    required this.subjects,
    required this.highlight,
  });

  final String date;
  final String wakeUp;
  final String sleep;
  final double studyHours;
  final String subjects;
  final String highlight;

  factory DayEntry.fromJson(Map<String, dynamic> json) {
    return DayEntry(
      date: json['date'] as String,
      wakeUp: json['wakeUp'] as String,
      sleep: json['sleep'] as String,
      studyHours: (json['studyHours'] as num).toDouble(),
      subjects: json['subjects'] as String,
      highlight: json['highlight'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'wakeUp': wakeUp,
      'sleep': sleep,
      'studyHours': studyHours,
      'subjects': subjects,
      'highlight': highlight,
    };
  }
}
