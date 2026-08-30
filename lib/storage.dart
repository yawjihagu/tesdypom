import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class StatsStore {
  static const _xpKey = 'pomodoro.xp';
  static const _totalKey = 'pomodoro.total';
  static const _dailyKey = 'pomodoro.daily';

  Future<AppStats> load() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_xpKey) ?? 0;
    final total = prefs.getInt(_totalKey) ?? 0;
    final dailyRaw = prefs.getString(_dailyKey);
    Map<String, int> daily = {};
    if (dailyRaw != null) {
      try {
        final decoded = jsonDecode(dailyRaw) as Map<String, dynamic>;
        daily = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
      } catch (_) {}
    }
    return AppStats(totalSessions: total, xp: xp, dailySessions: daily);
  }

  Future<void> save(AppStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_xpKey, stats.xp);
    await prefs.setInt(_totalKey, stats.totalSessions);
    await prefs.setString(_dailyKey, jsonEncode(stats.dailySessions));
  }
}
