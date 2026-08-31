import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class StatsStore {
  static const _xpKey = 'pomodoro.xp';
  static const _totalKey = 'pomodoro.total';
  static const _dailyKey = 'pomodoro.daily';
  static const _sessionsKey = 'pomodoro.sessions';
  static const _goalKey = 'pomodoro.dailyGoal';
  static const _autoKey = 'pomodoro.autoStart';
  static const _tasksKey = 'pomodoro.tasks';

  Future<AppStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_xpKey) ?? 0;
    final total = prefs.getInt(_totalKey) ?? 0;
    final goal = prefs.getInt(_goalKey) ?? 8;
    final autoStart = prefs.getBool(_autoKey) ?? false;
    final dailyRaw = prefs.getString(_dailyKey);
    Map<String, int> daily = {};
    if (dailyRaw != null) {
      try {
        final decoded = jsonDecode(dailyRaw) as Map<String, dynamic>;
        daily = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
    final sessions = _decodeSessions(prefs.getString(_sessionsKey));
    final tasks = prefs.getStringList(_tasksKey) ?? <String>[];
    return AppStats(
      totalSessions: total,
      xp: xp,
      dailySessions: daily,
      sessions: sessions,
      tasks: tasks,
      dailyGoal: goal,
      autoStart: autoStart,
    );
  }

  List<SessionRecord> _decodeSessions(String? raw) {
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SessionRecord.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(AppStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, stats.xp);
    await prefs.setInt(_totalKey, stats.totalSessions);
    await prefs.setInt(_goalKey, stats.dailyGoal);
    await prefs.setBool(_autoKey, stats.autoStart);
    await prefs.setStringList(_tasksKey, stats.tasks);
    await prefs.setString(_dailyKey, jsonEncode(stats.dailySessions));
    await prefs.setString(
        _sessionsKey,
        jsonEncode(stats.sessions.map((s) => s.toJson()).toList()));
  }
}
