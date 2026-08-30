import 'package:flutter/material.dart';

class AppStats {
  int totalSessions;
  int xp;
  Map<String, int> dailySessions;

  AppStats({
    this.totalSessions = 0,
    this.xp = 0,
    Map<String, int>? dailySessions,
  }) : dailySessions = dailySessions ?? {};

  int get level => _levelForXp(xp);
  int get currentLevelXp => _levelFloor(level);
  int get nextLevelXp => _levelFloor(level + 1);
  double get levelProgress {
    final span = nextLevelXp - currentLevelXp;
    if (span <= 0) return 1;
    return ((xp - currentLevelXp) / span).clamp(0.0, 1.0);
  }

  static int _levelFloor(int lvl) => (lvl - 1) * 100;

  static int _levelForXp(int xp) {
    if (xp <= 0) return 1;
    return (xp ~/ 100) + 1;
  }

  int todayCount([DateTime? now]) {
    final d = now ?? DateTime.now();
    final key = _dayKey(d);
    return dailySessions[key] ?? 0;
  }

  int countOn(DateTime day) {
    return dailySessions[_dayKey(day)] ?? 0;
  }

  int totalForLastNDays(int n, [DateTime? now]) {
    final d = now ?? DateTime.now();
    var sum = 0;
    for (var i = 0; i < n; i++) {
      final day = d.subtract(Duration(days: i));
      sum += countOn(day);
    }
    return sum;
  }

  int currentStreak([DateTime? now]) {
    final d = now ?? DateTime.now();
    var streak = 0;
    // Start from today if it already has sessions, else yesterday.
    var day = d;
    if (todayCount(d) == 0) {
      day = d.subtract(const Duration(days: 1));
    }
    while (countOn(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _dayKey(DateTime day) {
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return '${day.year}-$m-$d';
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(AppStats stats) condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
  });
}

final achievements = <Achievement>[
  Achievement(
    id: 'first',
    title: 'First Steps',
    description: 'Complete your first pomodoro.',
    icon: Icons.check_circle,
    condition: (s) => s.totalSessions >= 1,
  ),
  Achievement(
    id: 'five',
    title: 'On Fire',
    description: 'Complete 5 pomodoros total.',
    icon: Icons.local_fire_department,
    condition: (s) => s.totalSessions >= 5,
  ),
  Achievement(
    id: 'ten',
    title: 'Focus Machine',
    description: 'Complete 10 pomodoros total.',
    icon: Icons.bolt,
    condition: (s) => s.totalSessions >= 10,
  ),
  Achievement(
    id: 'fifty',
    title: 'Deep Worker',
    description: 'Complete 50 pomodoros total.',
    icon: Icons.military_tech,
    condition: (s) => s.totalSessions >= 50,
  ),
  Achievement(
    id: 'hundred',
    title: 'Productivity Legend',
    description: 'Complete 100 pomodoros total.',
    icon: Icons.emoji_events,
    condition: (s) => s.totalSessions >= 100,
  ),
  Achievement(
    id: 'four',
    title: 'Full Cycle',
    description: 'Complete 4 pomodoros in a single day.',
    icon: Icons.all_inclusive,
    condition: (s) => s.totalForLastNDays(1) >= 4,
  ),
  Achievement(
    id: 'streak3',
    title: 'Consistent',
    description: 'Hit a 3-day streak.',
    icon: Icons.calendar_view_day,
    condition: (s) => s.currentStreak() >= 3,
  ),
  Achievement(
    id: 'streak7',
    title: 'Unstoppable',
    description: 'Hit a 7-day streak.',
    icon: Icons.flag,
    condition: (s) => s.currentStreak() >= 7,
  ),
];

const motivationalQuotes = <String>[
  'You don\'t have to be great to start, but you have to start to be great.',
  'Focus on the process, not the outcome.',
  'Small steps every day add up to big results.',
  'The secret of getting ahead is getting started.',
  'It always seems impossible until it\'s done.',
  'Your focus determines your reality.',
  'One pomodoro at a time. You\'ve got this.',
  'Don\'t watch the clock; do what it does. Keep going.',
  'Great things never come from comfort zones.',
  'Discipline is choosing what you want most over what you want now.',
  'Productivity is never an accident. It is the result of commitment.',
  'You are capable of more than you know.',
  'Every expert was once a beginner.',
  'The best way to predict the future is to create it.',
  'Stay hungry, stay focused.',
];
