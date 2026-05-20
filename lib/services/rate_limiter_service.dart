import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RateLimiterService {
  static const _keyDate = 'rate_limiter_date';
  static const _keyCount = 'rate_limiter_count';
  static const int maxPerDay = 5;

  Future<bool> canAnalyze() async {
    final prefs = await SharedPreferences.getInstance();
    final isGold = prefs.getBool('is_gold_member') ?? false;
    if (isGold) return true; // Gold members have unlimited scans!

    final today = _todayString();
    final storedDate = prefs.getString(_keyDate);
    int count = prefs.getInt(_keyCount) ?? 0;
    if (storedDate != today) {
      // reset for new day
      await prefs.setString(_keyDate, today);
      await prefs.setInt(_keyCount, 0);
      count = 0;
    }
    return count < maxPerDay;
  }

  Future<void> recordAnalysis() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final storedDate = prefs.getString(_keyDate);
    int count = prefs.getInt(_keyCount) ?? 0;
    if (storedDate != today) {
      await prefs.setString(_keyDate, today);
      count = 0;
    }
    await prefs.setInt(_keyCount, count + 1);
  }

  String _todayString() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }
}
